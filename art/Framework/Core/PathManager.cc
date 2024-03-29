#include "art/Framework/Core/PathManager.h"
// vim: set sw=2 expandtab :

#include "art/Framework/Core/EDProducer.h"
#include "art/Framework/Core/ModuleBase.h"
#include "art/Framework/Core/ModuleMacros.h"
#include "art/Framework/Core/Path.h"
#include "art/Framework/Core/PathsInfo.h"
#include "art/Framework/Core/UpdateOutputCallbacks.h"
#include "art/Framework/Core/WorkerInPath.h"
#include "art/Framework/Core/WorkerT.h"
#include "art/Framework/Core/detail/ModuleGraphInfoMap.h"
#include "art/Framework/Core/detail/consumed_products.h"
#include "art/Framework/Core/detail/graph_algorithms.h"
#include "art/Framework/Principal/Actions.h"
#include "art/Framework/Principal/Worker.h"
#include "art/Framework/Principal/WorkerParams.h"
#include "art/Framework/Services/Registry/ActivityRegistry.h"
#include "art/Persistency/Provenance/ModuleDescription.h"
#include "art/Persistency/Provenance/ModuleType.h"
#include "art/Utilities/Globals.h"
#include "art/Utilities/PerScheduleContainer.h"
#include "art/Utilities/PluginSuffixes.h"
#include "art/Utilities/ScheduleID.h"
#include "art/Utilities/ScheduleIteration.h"
#include "art/Utilities/bold_fontify.h"
#include "art/Version/GetReleaseVersion.h"
#include "canvas/Persistency/Common/HLTGlobalStatus.h"
#include "canvas/Utilities/DebugMacros.h"
#include "canvas/Utilities/Exception.h"
#include "cetlib/HorizontalRule.h"
#include "cetlib/LibraryManager.h"
#include "cetlib/container_algorithms.h"
#include "cetlib/detail/wrapLibraryManagerException.h"
#include "cetlib/ostream_handle.h"
#include "fhiclcpp/ParameterSet.h"
#include "fhiclcpp/types/detail/validationException.h"
#include "hep_concurrency/tsan.h"

#include <algorithm>
#include <cstddef>
#include <fstream>
#include <map>
#include <memory>
#include <regex>
#include <set>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

using namespace std;
using namespace std::string_literals;

using fhicl::ParameterSet;

namespace art {

  namespace {
    std::vector<std::string>
    sorted_module_labels(std::vector<WorkerInPath::ConfigInfo> const& wcis)
    {
      std::vector<std::string> sorted_modules;
      cet::transform_all(
        wcis, back_inserter(sorted_modules), [](auto const& wci) {
          return wci.moduleConfigInfo->moduleLabel;
        });
      std::sort(begin(sorted_modules), end(sorted_modules));
      return sorted_modules;
    }
  } // anonymous namespace

  PathManager::~PathManager() noexcept
  {
    for (auto& label_and_workers : workers_) {
      for (auto wkr : label_and_workers.second) {
        delete wkr;
        wkr = nullptr;
      }
    }
  }

  PathManager::PathManager(
    ParameterSet const& procPS,
    UpdateOutputCallbacks& outputCallbacks,
    ProductDescriptions& productsToProduce,
    ActionTable const& exceptActions,
    ActivityRegistry const& actReg,
    std::map<std::string, detail::ModuleKeyAndType> const& enabled_modules)
    : outputCallbacks_{outputCallbacks}
    , exceptActions_{exceptActions}
    , actReg_{actReg}
    , procPS_{procPS}
    , triggerPathsInfo_(Globals::instance()->nschedules())
    , endPathInfo_(Globals::instance()->nschedules())
    , productsToProduce_{productsToProduce}
    , processName_{procPS.get<string>("process_name"s, ""s)}
  {
    triggerResultsInserter_.expand_to_num_schedules();
    //
    //  Collect trigger_paths and end_paths.
    {
      vector<string> tmp;
      if (procPS_.get_if_present("physics.trigger_paths", tmp)) {
        trigger_paths_config_ = std::set<string>(tmp.cbegin(), tmp.cend());
      }
      tmp.clear();
      if (procPS_.get_if_present("physics.end_paths", tmp)) {
        end_paths_config_ = std::set<string>(tmp.cbegin(), tmp.cend());
      }
    }
    //
    //  Collect all the module information.
    //
    {
      ostringstream es;
      for (auto const& [module_label, key_and_type] : enabled_modules) {
        try {
          auto const& [key, module_type] = key_and_type;
          auto const& module_pset = procPS_.get<fhicl::ParameterSet>(key);
          auto const lib_spec = module_pset.get<string>("module_type");
          auto const actualModType = loadModuleType_(lib_spec);
          if (actualModType != module_type) {
            es << "  ERROR: Module with label " << module_label << " of type "
               << lib_spec << " is configured as a " << to_string(module_type)
               << " but defined in code as a " << to_string(actualModType)
               << ".\n";
          }
          detail::ModuleConfigInfo mci{module_label,
                                       module_type,
                                       loadModuleThreadingType_(lib_spec),
                                       module_pset,
                                       lib_spec};
          allModules_.emplace(module_label, move(mci));
        }
        catch (exception const& e) {
          es << "  ERROR: Configuration of module with label " << module_label
             << " encountered the following error:\n"
             << e.what() << "\n";
        }
      }
      if (!es.str().empty()) {
        throw Exception(errors::Configuration)
          << "The following were encountered while processing the module "
             "configurations:\n"
          << es.str();
      }
    }
    //
    //  Collect all the path information.
    //
    {
      ostringstream es;
      //
      //  Get the physics table.
      //
      auto const physics = procPS_.get<ParameterSet>("physics", {});
      //
      //  Get the non-special entries, should be user-specified paths
      //  (labeled fhicl sequences of module labels).
      //
      // Note: The ParameterSet::get_names() routine returns
      // vector<string> by value, so we must make sure to iterate over
      // the same returned object.
      auto const physics_names = physics.get_names();
      set<string> const special_parms{
        "producers"s, "filters"s, "analyzers"s, "trigger_paths"s, "end_paths"s};
      vector<string> path_names;
      set_difference(physics_names.cbegin(),
                     physics_names.cend(),
                     special_parms.cbegin(),
                     special_parms.cend(),
                     back_inserter(path_names));
      //
      //  Check that each path in trigger_paths and end_paths actually exists.
      //
      if (trigger_paths_config_) {
        vector<string> unknown_paths;
        set_difference(trigger_paths_config_->cbegin(),
                       trigger_paths_config_->cend(),
                       path_names.cbegin(),
                       path_names.cend(),
                       back_inserter(unknown_paths));
        for (auto const& path : unknown_paths) {
          es << "ERROR: Unknown path " << path
             << " specified by user in trigger_paths.\n";
        }
      }
      if (end_paths_config_) {
        vector<string> missing_paths;
        set_difference(end_paths_config_->cbegin(),
                       end_paths_config_->cend(),
                       path_names.cbegin(),
                       path_names.cend(),
                       back_inserter(missing_paths));
        for (auto const& path : missing_paths) {
          es << "ERROR: Unknown path " << path
             << " specified by user in end_paths.\n";
        }
      }
      //
      //  Make sure the path names are keys to fhicl sequences.
      //
      {
        map<string, string> bad_names;
        for (auto const& name : path_names) {
          if (physics.is_key_to_sequence(name)) {
            continue;
          }
          string const type = physics.is_key_to_table(name) ? "table" : "atom";
          bad_names.emplace(name, type);
        }
        if (!bad_names.empty()) {
          string msg =
            "\nYou have specified the following unsupported parameters in the\n"
            "\"physics\" block of your configuration:\n\n";
          cet::for_all(bad_names, [&msg](auto const& name) {
            msg.append("   \"physics." + name.first + "\"   (" + name.second +
                       ")\n");
          });
          msg.append("\n");
          msg.append("Supported parameters include the following tables:\n");
          msg.append("   \"physics.producers\"\n");
          msg.append("   \"physics.filters\"\n");
          msg.append("   \"physics.analyzers\"\n");
          msg.append("and sequences. Atomic configuration parameters are not "
                     "allowed.\n\n");
          throw Exception(errors::Configuration) << msg;
        }
      }
      //
      // Process each path.
      //
      // FIXME: All of this information is readily available from the
      // configuration-pruning infrastructure.  We should be able to
      // remove it.
      //
      auto remove_filter_action = [](auto const& spec) {
        auto pos = spec.find_first_not_of("!-");
        if (pos > 1) {
          throw Exception(errors::Configuration)
            << "Module label " << spec << " is illegal.\n";
        }
        return spec.substr(pos);
      };
      {
        enum class mod_cat_t { UNSET, OBSERVER, MODIFIER };
        size_t num_end_paths = 0;
        for (auto const& path_name : path_names) {
          mod_cat_t cat = mod_cat_t::UNSET;
          auto const path = physics.get<vector<string>>(path_name);
          for (auto const& modname_filterAction : path) {
            auto const label = remove_filter_action(modname_filterAction);
            // map<string, ModuleConfigInfo>
            auto iter = allModules_.find(label);
            if (iter == allModules_.end()) {
              // This is the case where a path has been configured but
              // not enabled for execution.
              continue;
            }
            auto const& mci = iter->second;
            auto mtype = is_observer(mci.moduleType) ? mod_cat_t::OBSERVER :
                                                       mod_cat_t::MODIFIER;
            if (cat != mod_cat_t::UNSET) {
              // The configuration-pruning code ensures that there are
              // no mixed paths.
              assert(cat == mtype);
            }
            if (cat == mod_cat_t::UNSET) {
              // We now know path is not empty, categorize it.
              cat = mtype;
              // If optional triggers_paths or end_paths used, and this path is
              // not on them, ignore it.
              if (cat == mod_cat_t::MODIFIER) {
                if (trigger_paths_config_ &&
                    (trigger_paths_config_->find(path_name) ==
                     trigger_paths_config_->cend())) {
                  mf::LogInfo("DeactivatedPath")
                    << "Detected trigger path \"" << path_name
                    << "\" which was not found in\n"
                    << "parameter \"physics.trigger_paths\". Path will be "
                       "ignored.";
                  break;
                }
                if (end_paths_config_ && (end_paths_config_->find(path_name) !=
                                          end_paths_config_->cend())) {
                  es << "  ERROR: Path '" << path_name
                     << "' is configured as an end path but is actually a "
                        "trigger path.";
                }
                triggerPathNames_.push_back(path_name);
              } else {
                if (end_paths_config_ && (end_paths_config_->find(path_name) ==
                                          end_paths_config_->cend())) {
                  mf::LogInfo("DeactivatedPath")
                    << "Detected end path \"" << path_name
                    << "\" which was not found in\n"
                    << "parameter \"physics.end_paths\". "
                    << "Path will be ignored.";
                  break;
                }
                if (trigger_paths_config_ &&
                    (trigger_paths_config_->find(path_name) !=
                     trigger_paths_config_->cend())) {
                  es << "  ERROR: Path '" << path_name
                     << "' is configured as a trigger path but is actually an "
                        "end path.";
                }
              }
            }
            auto filteract = WorkerInPath::FilterAction::Normal;
            if (modname_filterAction[0] == '!') {
              filteract = WorkerInPath::FilterAction::Veto;
            } else if (modname_filterAction[0] == '-') {
              filteract = WorkerInPath::FilterAction::Ignore;
            }
            if (mci.moduleType != ModuleType::filter &&
                filteract != WorkerInPath::Normal) {
              es << "  ERROR: Module " << label << " in path " << path_name
                 << " is" << (cat == mod_cat_t::OBSERVER ? " an " : " a ")
                 << to_string(mci.moduleType)
                 << " and cannot have a '!' or '-' prefix.\n";
            }
            auto const mci_p = cet::make_exempt_ptr(&mci);
            if (cat == mod_cat_t::MODIFIER) {
              // Trigger path.
              protoTrigPathLabelMap_[path_name].emplace_back(mci_p, filteract);
            } else {
              protoEndPathLabels_.emplace_back(mci_p, filteract);
            }
          }
          if (cat == mod_cat_t::OBSERVER) {
            ++num_end_paths;
          }
        }
        if (num_end_paths > 1) {
          mf::LogInfo("PathConfiguration")
            << "Multiple end paths have been combined into one end path,\n"
            << "\"end_path\" since order is irrelevant.";
        }
      }
      //
      // Check for fatal errors.
      //
      if (!es.str().empty()) {
        throw Exception(errors::Configuration, "Path configuration: ")
          << "The following were encountered while processing path "
             "configurations:\n"
          << es.str();
      }
    }
  }

  vector<string> const&
  PathManager::triggerPathNames() const
  {
    return triggerPathNames_;
  }

  void
  PathManager::createModulesAndWorkers(
    std::vector<std::string> const& producing_services)
  {
    // For each configured schedule, create the trigger paths and the
    // workers on each path.
    auto const nschedules =
      static_cast<ScheduleID::size_type>(Globals::instance()->nschedules());

    // The modules created are managed by shared_ptrs.  Once the
    // workers claim (co-)ownership of the modules, the 'modules'
    // object can be destroyed.
    auto modules = makeModules_(nschedules);

    auto fill_workers = [&modules, this](ScheduleID const sid) {
      auto& pinfo = triggerPathsInfo_[sid];
      pinfo.pathResults() = HLTGlobalStatus(triggerPathNames_.size());
      int bitPos = 0;
      ScheduleContext const sc{sid};
      for (auto const& val : protoTrigPathLabelMap_) {
        auto const& path_name = val.first;
        auto const& worker_config_infos = val.second;
        PathContext const pc{
          sc, path_name, bitPos, sorted_module_labels(worker_config_infos)};
        auto wips =
          fillWorkers_(pc, worker_config_infos, modules, pinfo.workers());
        pinfo.paths().push_back(new Path{
          exceptActions_, actReg_, pc, move(wips), &pinfo.pathResults()});
        {
          ostringstream msg;
          msg << "Made path 0x" << hex << ((unsigned long)pinfo.paths().back())
              << dec << " bitPos: " << bitPos << " name: " << val.first;
          TDEBUG_FUNC_SI_MSG(
            5, "PathManager::createModulesAndWorkers", sid, msg.str());
        }
        ++bitPos;
      }

      if (protoEndPathLabels_.empty()) {
        return;
      }

      //  Create the end path and the workers on it.
      auto& einfo = endPathInfo_[sid];
      PathContext const pc{sc,
                           PathContext::end_path(),
                           0,
                           sorted_module_labels(protoEndPathLabels_)};
      auto wips =
        fillWorkers_(pc, protoEndPathLabels_, modules, einfo.workers());
      einfo.paths().push_back(
        new Path{exceptActions_, actReg_, pc, move(wips), nullptr});
      {
        ostringstream msg;
        msg << "Made end path 0x" << hex
            << ((unsigned long)einfo.paths().back()) << dec;
        TDEBUG_FUNC_SI_MSG(
          5, "PathManager::createModulesAndWorkers", 0, msg.str());
      }
    };
    ScheduleIteration schedule_iteration{nschedules};
    schedule_iteration.for_each_schedule(fill_workers);

    using namespace detail;
    auto const graph_info_collection =
      getModuleGraphInfoCollection_(producing_services);
    ModuleGraphInfoMap const modInfos{graph_info_collection};
    auto const module_graph =
      make_module_graph(modInfos, protoTrigPathLabelMap_, protoEndPathLabels_);
    auto const graph_filename =
      procPS_.get<string>("services.scheduler.dataDependencyGraph", {});
    if (!graph_filename.empty()) {
      cet::ostream_handle osh{graph_filename};
      print_module_graph(osh, modInfos, module_graph.first);
      cerr << "Generated data-dependency graph file: " << graph_filename
           << '\n';
    }
    auto const& err = module_graph.second;
    if (!err.empty()) {
      throw Exception{errors::Configuration} << err << '\n';
    }

    // No longer need worker/module config objects.
    protoTrigPathLabelMap_.clear();
    protoEndPathLabels_.clear();
    allModules_.clear();
  }

  PathsInfo&
  PathManager::triggerPathsInfo(ScheduleID const sid)
  {
    return triggerPathsInfo_.at(sid);
  }

  PerScheduleContainer<PathsInfo>&
  PathManager::triggerPathsInfo()
  {
    return triggerPathsInfo_;
  }

  PathsInfo&
  PathManager::endPathInfo(ScheduleID const sid)
  {
    return endPathInfo_.at(sid);
  }

  PerScheduleContainer<PathsInfo>&
  PathManager::endPathInfo()
  {
    return endPathInfo_;
  }

  Worker*
  PathManager::triggerResultsInserter(ScheduleID const sid) const
  {
    return triggerResultsInserter_.at(sid).get();
  }

  void
  PathManager::setTriggerResultsInserter(
    ScheduleID const sid,
    unique_ptr<WorkerT<ReplicatedProducer>>&& w)
  {
    triggerResultsInserter_.at(sid) = move(w);
  }

  PathManager::ModulesByThreadingType
  PathManager::makeModules_(ScheduleID::size_type const nschedules)
  {
    ModulesByThreadingType modules{};
    vector<string> configErrMsgs;
    for (auto const& pr : allModules_) {
      auto const& module_label = pr.first;
      auto const& mci = pr.second;
      auto const& modPS = mci.modPS;
      auto const module_type = mci.libSpec;
      auto const module_threading_type = mci.moduleThreadingType;

      ModuleDescription const md{
        modPS.id(),
        module_type,
        module_label,
        module_threading_type,
        ProcessConfiguration{processName_, procPS_.id(), getReleaseVersion()}};

      // FIXME: provide context information?
      actReg_.sPreModuleConstruction.invoke(md);

      auto sid = ScheduleID::first();
      auto result = makeModule_(modPS, md, sid);
      auto module = result.first;
      auto const& err = result.second;
      if (!err.empty()) {
        configErrMsgs.push_back(err);
        continue;
      }

      if (module_threading_type == ModuleThreadingType::shared ||
          module_threading_type == ModuleThreadingType::legacy) {
        modules.shared.emplace(module_label,
                               std::shared_ptr<ModuleBase>{module});
      } else {
        PerScheduleContainer<std::shared_ptr<ModuleBase>> replicated_modules(
          nschedules);
        replicated_modules[sid].reset(module);
        ScheduleIteration schedule_iteration{sid.next(),
                                             ScheduleID(nschedules)};

        auto fill_replicated_module =
          [&replicated_modules, &modPS, &md, this](ScheduleID const sid) {
            auto repl_result = makeModule_(modPS, md, sid);
            if (repl_result.second.empty()) {
              replicated_modules[sid].reset(repl_result.first);
            }
          };
        schedule_iteration.for_each_schedule(fill_replicated_module);
        modules.replicated.emplace(module_label, replicated_modules);
      }

      actReg_.sPostModuleConstruction.invoke(md);

      // Since we store consumes information per module label, we only
      // sort and collect it for one of the replicated-module copies.
      // The only way this would be a problem is if someone decided to
      // provided conditional consumes calls based on the ScheduleID
      // presented to the replicated-module constructor.
      module->sortConsumables(processName_);
      ConsumesInfo::instance()->collectConsumes(module_label,
                                                module->getConsumables());
    }

    if (!configErrMsgs.empty()) {
      constexpr cet::HorizontalRule rule{100};
      ostringstream msg;
      msg << "\n"
          << rule('=') << "\n\n"
          << "!! The following modules have been misconfigured: !!"
          << "\n";
      for (auto const& err : configErrMsgs) {
        msg << "\n" << rule('-') << "\n" << err;
      }
      msg << "\n" << rule('=') << "\n\n";
      throw Exception(errors::Configuration) << msg.str();
    }
    return modules;
  }

  std::pair<ModuleBase*, std::string>
  PathManager::makeModule_(ParameterSet const& modPS,
                           ModuleDescription const& md,
                           ScheduleID const sid) const
  {
    std::pair<ModuleBase*, std::string> result;
    auto const& module_type = md.moduleName();
    try {
      detail::ModuleMaker_t* module_factory_func{nullptr};
      try {
        lm_.getSymbolByLibspec(module_type, "make_module", module_factory_func);
      }
      catch (Exception& e) {
        cet::detail::wrapLibraryManagerException(
          e, "Module", module_type, getReleaseVersion());
      }
      if (module_factory_func == nullptr) {
        throw Exception(errors::Configuration, "BadPluginLibrary: ")
          << "Module " << module_type << " with version " << getReleaseVersion()
          << " has internal symbol definition problems: consult an "
             "expert.";
      }
      WorkerParams const wp{procPS_,
                            modPS,
                            outputCallbacks_,
                            productsToProduce_,
                            actReg_,
                            exceptActions_,
                            processName_,
                            sid};
      result.first = module_factory_func(md, wp);
    }
    catch (fhicl::detail::validationException const& e) {
      ostringstream es;
      es << "\n\nModule label: " << detail::bold_fontify(md.moduleLabel())
         << "\nmodule_type : " << detail::bold_fontify(module_type) << "\n\n"
         << e.what();
      result.second = es.str();
    }
    return result;
  }

  vector<WorkerInPath>
  PathManager::fillWorkers_(PathContext const& pc,
                            vector<WorkerInPath::ConfigInfo> const& wci_list,
                            ModulesByThreadingType const& modules,
                            map<string, Worker*>& workers)
  {
    auto const sid = pc.scheduleID();
    auto const pi = pc.bitPosition();
    vector<WorkerInPath> wips;
    for (auto const& wci : wci_list) {
      auto const& mci = *wci.moduleConfigInfo;
      auto const filterAction = wci.filterAction;
      auto const& module_label = mci.moduleLabel;

      if (workers_.find(module_label) == cend(workers_)) {
        workers_[module_label].expand_to_num_schedules();
      }

      auto const& modPS = mci.modPS;
      auto const module_type = mci.libSpec;
      auto const module_threading_type = mci.moduleThreadingType;
      Worker* worker{nullptr};
      // Workers which are present on multiple paths should be shared so
      // that their work is only done once per schedule.
      {
        auto iter = workers.find(module_label);
        if (iter != workers.end()) {
          ostringstream msg;
          msg << "Reusing worker 0x" << hex << ((unsigned long)iter->second)
              << dec << " path: " << pi << " type: " << module_type
              << " label: " << module_label;
          TDEBUG_FUNC_SI_MSG(5, "PathManager::fillWorkers_", sid, msg.str());
          worker = iter->second;
        }
      }
      ModuleDescription const md{
        modPS.id(),
        module_type,
        module_label,
        module_threading_type,
        ProcessConfiguration{processName_, procPS_.id(), getReleaseVersion()}};
      if (worker == nullptr) {
        auto get_module =
          [&modules](std::string const& module_label,
                     ModuleThreadingType const module_threading_type,
                     ScheduleID const sid) {
            if (module_threading_type == ModuleThreadingType::shared ||
                module_threading_type == ModuleThreadingType::legacy) {
              return modules.shared.at(module_label);
            } else {
              return modules.replicated.at(module_label)[sid];
            }
          };

        WorkerParams const wp{procPS_,
                              modPS,
                              outputCallbacks_,
                              productsToProduce_,
                              actReg_,
                              exceptActions_,
                              processName_,
                              sid};
        detail::WorkerFromModuleMaker_t* worker_from_module_factory_func =
          nullptr;
        try {
          lm_.getSymbolByLibspec(module_type,
                                 "make_worker_from_module",
                                 worker_from_module_factory_func);
        }
        catch (Exception& e) {
          cet::detail::wrapLibraryManagerException(
            e, "Module", module_type, getReleaseVersion());
        }
        if (worker_from_module_factory_func == nullptr) {
          throw Exception(errors::Configuration, "BadPluginLibrary: ")
            << "Module " << module_type << " with version "
            << getReleaseVersion()
            << " has internal symbol definition problems: consult an expert.";
        }
        auto module = get_module(module_label, module_threading_type, sid);
        worker = worker_from_module_factory_func(module, md, wp);
        workers_[module_label][sid] = worker;
        TDEBUG(5) << "Made worker 0x" << hex << ((unsigned long)worker) << dec
                  << " (" << sid << ") path: " << pi << " type: " << module_type
                  << " label: " << module_label << "\n";
      }
      workers.emplace(module_label, worker);
      wips.emplace_back(worker, filterAction, ModuleContext{pc, md});
    }
    return wips;
  }

  ModuleType
  PathManager::loadModuleType_(string const& lib_spec)
  {
    detail::ModuleTypeFunc_t* mod_type_func{nullptr};
    try {
      lm_.getSymbolByLibspec(lib_spec, "moduleType", mod_type_func);
    }
    catch (Exception& e) {
      cet::detail::wrapLibraryManagerException(
        e, "Module", lib_spec, getReleaseVersion());
    }
    if (mod_type_func == nullptr) {
      throw Exception(errors::Configuration, "BadPluginLibrary")
        << "Module " << lib_spec << " with version " << getReleaseVersion()
        << " has internal symbol definition problems: consult an expert.";
    }
    return mod_type_func();
  }

  ModuleThreadingType
  PathManager::loadModuleThreadingType_(string const& lib_spec)
  {
    detail::ModuleThreadingTypeFunc_t* mod_threading_type_func{nullptr};
    try {
      lm_.getSymbolByLibspec(
        lib_spec, "moduleThreadingType", mod_threading_type_func);
    }
    catch (Exception& e) {
      cet::detail::wrapLibraryManagerException(
        e, "Module", lib_spec, getReleaseVersion());
    }
    if (mod_threading_type_func == nullptr) {
      throw Exception(errors::Configuration, "BadPluginLibrary")
        << "Module " << lib_spec << " with version " << getReleaseVersion()
        << " has internal symbol definition problems: consult an expert.";
    }
    return mod_threading_type_func();
  }

  // Module-graph implementation below
  using namespace detail;

  collection_map_t
  PathManager::getModuleGraphInfoCollection_(
    std::vector<std::string> const& producing_services)
  {
    collection_map_t result{};
    auto& source_info = result["input_source"];
    if (!protoTrigPathLabelMap_.empty()) {
      set<string> const path_names{cbegin(triggerPathNames_),
                                   cend(triggerPathNames_)};
      source_info.paths = path_names;
      result["TriggerResults"] = ModuleGraphInfo{ModuleType::producer};
    } else if (!protoEndPathLabels_.empty()) {
      source_info.paths = {"end_path"};
    }

    // Prepare information for produced and viewable products
    std::map<std::string, std::set<ProductInfo>> produced_products_per_module;
    std::map<std::string, std::set<std::string>> viewable_products_per_module;
    for (auto const& pd : productsToProduce_) {
      auto const& module_name = pd.moduleLabel();
      produced_products_per_module[module_name].emplace(
        art::ProductInfo::ConsumableType::Product,
        pd.friendlyClassName(),
        pd.moduleLabel(),
        pd.productInstanceName(),
        ProcessTag{pd.processName(), pd.processName()});
      if (pd.supportsView()) {
        // We do not do any type-checking here due to lack of
        // introspection abilities.  That will be performed during the
        // actual product lookup.
        viewable_products_per_module[module_name].insert(
          pd.productInstanceName());
      }
    }

    // Handle producing services, which do not currently support 'consumes'.
    for (auto const& service_name : producing_services) {
      auto& graph_info = result[service_name];
      graph_info.module_type = ModuleType::producing_service;

      auto found = produced_products_per_module.find(service_name);
      if (found == cend(produced_products_per_module)) {
        continue;
      }

      graph_info.produced_products = found->second;
    }

    for (auto const& path : protoTrigPathLabelMap_) {
      fillModuleOnlyDeps_(path.first,
                          path.second,
                          produced_products_per_module,
                          viewable_products_per_module,
                          result);
    }
    fillModuleOnlyDeps_(PathContext::end_path(),
                        protoEndPathLabels_,
                        produced_products_per_module,
                        viewable_products_per_module,
                        result);
    fillSelectEventsDeps_(protoEndPathLabels_, result);
    return result;
  }

  void
  PathManager::fillModuleOnlyDeps_(
    string const& path_name,
    configs_t const& worker_configs,
    std::map<std::string, std::set<ProductInfo>> const& produced_products,
    std::map<std::string, std::set<std::string>> const& viewable_products,
    collection_map_t& info_collection) const
  {
    auto const worker_config_begin = cbegin(worker_configs);

    for (auto it = worker_config_begin, end = cend(worker_configs); it != end;
         ++it) {
      auto const& mci = *it->moduleConfigInfo;
      auto const& module_name = mci.moduleLabel;
      auto& graph_info = info_collection[module_name];
      graph_info.paths.insert(path_name);
      graph_info.module_type = mci.moduleType;

      auto found = produced_products.find(module_name);
      if (found != cend(produced_products)) {
        graph_info.produced_products = found->second;
      }

      auto const& consumables =
        ConsumesInfo::instance()->consumables(module_name);
      graph_info.consumed_products =
        detail::consumed_products_for_module(processName_,
                                             consumables,
                                             produced_products,
                                             viewable_products,
                                             worker_config_begin,
                                             it);
    }
  }

  namespace {
    string const allowed_path_spec{R"([\*a-zA-Z_][\*\?\w]*)"};
    regex const regex{"(\\w+:)?(!|exception@)?(" + allowed_path_spec +
                      ")(&noexception)?"};
  }

  void
  PathManager::fillSelectEventsDeps_(configs_t const& worker_configs,
                                     collection_map_t& info_collection) const
  {
    for (auto const& worker_config : worker_configs) {
      auto const& mci = *worker_config.moduleConfigInfo;
      auto const& module_name = mci.moduleLabel;
      auto const& ps = mci.modPS;
      auto& graph_info = info_collection[module_name];
      assert(is_observer(graph_info.module_type));
      auto const path_specs = ps.get<vector<string>>("SelectEvents", {});
      for (auto const& path_spec : path_specs) {
        smatch matches;
        regex_match(path_spec, matches, regex);
        // By the time we have gotten here, all modules have been
        // constructed, and it is guaranteed that the specified paths
        // are in accord with the above regex.
        //   0: Full match
        //   1: Optional process name
        //   2: Optional '!' or 'exception@'
        //   3: Required path specification
        //   4: Optional '&noexception'
        assert(matches.size() == 5);
        graph_info.select_events.insert(matches[3]);
      }
    }
  }

} // namespace art
