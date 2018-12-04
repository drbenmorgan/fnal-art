#include "art/Framework/Modules/detail/SamplingInputFile.h"

#include "art/Framework/IO/Root/BranchMapperWithReader.h"
#include "art/Framework/IO/Root/RootDB/TKeyVFSOpenPolicy.h"
#include "art/Framework/IO/Root/RootDB/have_table.h"
#include "art/Framework/IO/Root/checkDictionaries.h"
#include "art/Framework/IO/Root/detail/readFileIndex.h"
#include "art/Framework/IO/Root/detail/readMetadata.h"
#include "art/Framework/IO/Root/rootErrMsgs.h"
#include "art/Framework/Modules/SampledInfo.h"
#include "art/Framework/Modules/detail/SamplingDelayedReader.h"
#include "art/Framework/Services/Registry/ServiceHandle.h"
#include "art/Framework/Services/System/DatabaseConnection.h"
#include "art/Persistency/Provenance/MasterProductRegistry.h"
#include "art/Persistency/Provenance/ProcessHistoryRegistry.h"
#include "canvas/Persistency/Provenance/BranchDescription.h"
#include "canvas/Persistency/Provenance/BranchKey.h"
#include "canvas/Persistency/Provenance/TypeLabel.h"
#include "canvas/Persistency/Provenance/rootNames.h"
#include "canvas_root_io/Streamers/ProductIDStreamer.h"
#include "fhiclcpp/ParameterSetRegistry.h"

namespace detail = art::detail;

detail::SamplingInputFile::SamplingInputFile(
  std::string const& dataset,
  std::string const& filename,
  double const weight,
  double const probability,
  ProductDescriptions const& sampledInfoDescriptions,
  bool const readIncomingParameterSets,
  MasterProductRegistry& mpr)
  : dataset_{dataset}
  , file_{std::make_unique<TFile>(filename.c_str())}
  , weight_{weight}
  , probability_{probability}
  , sampledInfoDescriptions_{sampledInfoDescriptions}
{
  // Read metadata tree
  auto metaDataTree =
    dynamic_cast<TTree*>(file_->Get(rootNames::metaDataTreeName().c_str()));
  if (!metaDataTree) {
    throw Exception{errors::FileReadError}
      << couldNotFindTree(rootNames::metaDataTreeName());
  }

  // Read the ProcessHistory
  {
    auto pHistMap = detail::readMetadata<ProcessHistoryMap>(metaDataTree);
    ProcessHistoryRegistry::put(pHistMap);
  }

  // Read file format version
  fileFormatVersion_ = detail::readMetadata<FileFormatVersion>(metaDataTree);

  // Also need to check RootFileDB if we have one.
  if (fileFormatVersion_.value_ >= 5) {
    sqliteDB_ = ServiceHandle<DatabaseConnection> {}
    ->get<TKeyVFSOpenPolicy>("RootFileDB", file_.get());
    if (readIncomingParameterSets &&
        have_table(sqliteDB_, "ParameterSets", dataset_)) {
      fhicl::ParameterSetRegistry::importFrom(sqliteDB_);
    }
  }

  // Read file index
  auto findexPtr = &fileIndex_;
  detail::readFileIndex(file_.get(), metaDataTree, findexPtr);
  fiIter_ = fileIndex_.begin();
  fiEnd_ = fileIndex_.end();

  // To support files that contain BranchIDLists
  BranchIDLists branchIDLists{};
  if (detail::readMetadata(metaDataTree, branchIDLists)) {
    branchIDLists_ = std::make_unique<BranchIDLists>(std::move(branchIDLists));
    configureProductIDStreamer(branchIDLists_.get());
  }

  // Read event history tree
  eventHistoryTree_ =
    static_cast<TTree*>(file_->Get(rootNames::eventHistoryTreeName().c_str()));
  if (!eventHistoryTree_) {
    throw art::Exception{errors::DataCorruption}
      << "Failed to find the event history tree.\n";
  }
  // eventHistoryTree_->SetCacheSize(static_cast<Long64_t>(treeCacheSize));

  // Read event (meta)data trees
  eventTree_ = dynamic_cast<TTree*>(
    file_->Get(BranchTypeToProductTreeName(InEvent).c_str()));
  eventMetaTree_ = dynamic_cast<TTree*>(
    file_->Get(BranchTypeToMetaDataTreeName(InEvent).c_str()));

  if (eventTree_) {
    auxBranch_ =
      eventTree_->GetBranch(BranchTypeToAuxiliaryBranchName(InEvent).c_str());
  }
  if (eventMetaTree_) {
    productProvenanceBranch_ =
      eventMetaTree_->GetBranch(productProvenanceBranchName(InEvent).c_str());
  }
  // Add checks for pointers above

  // Read the ProductList
  std::array<AvailableProducts_t, NumBranchTypes> availableProducts{{}};
  productListHolder_ = detail::readMetadata<ProductRegistry>(metaDataTree);
  auto& productList = productListHolder_.productList_;
  //  dropOnInput(groupSelectorRules, branchChildren, dropDescendants,
  //  prodList);

  for (auto& pr : productList) {
    auto& pd = pr.second;
    auto branch = eventTree_->GetBranch(pd.branchName().c_str());
    bool const present{branch != nullptr};
    if (present) {
      availableProducts[pd.branchType()].emplace(pd.productID());
      checkDictionaries(pd);
    }

    auto const validity = present ?
                            BranchDescription::Transients::PresentFromSource :
                            BranchDescription::Transients::Dropped;
    pd.setValidity(validity);
    branches_.emplace(pr.first, input::BranchInfo{pd, branch});
  }

  mpr.updateFromInputFile(productList);

  // Register newly created data product
  for (auto const& pd : sampledInfoDescriptions_) {
    availableProducts[pd.branchType()].emplace(pd.productID());
    checkDictionaries(pd);
    productList.emplace(BranchKey{pd}, pd);
  }
  presentProducts_ =
    ProductTables{make_product_descriptions(productList), availableProducts};
}

bool
detail::SamplingInputFile::entryForNextEvent(art::input::EntryNumber& entry)
{
  while (fiIter_ != fiEnd_ && fiIter_->getEntryType() != FileIndex::kEvent) {
    ++fiIter_;
  }

  if (fiIter_ == fiEnd_) {
    return false;
  }

  entry = fiIter_->entry_;
  ++fiIter_;
  return true;
}

art::SampledInfo<art::RunID>
detail::SamplingInputFile::fillRun(RunPrincipal& rp [[gnu::unused]]) const
{
  // We use a set because it is okay for multiple entries of the same
  // Run to be present in the FileIndex--these correspond to Run
  // fragments.  However, we do not want these to appear as separate
  // entries in the SampledInfo object.
  std::set<RunID> ids;
  for (auto const& element : fileIndex_) {
    if (element.getEntryType() != FileIndex::kRun) {
      continue;
    }
    ids.emplace(element.eventID_.run());
  }
  return SampledInfo<RunID>{
    weight_, probability_, std::vector<RunID>(cbegin(ids), cend(ids))};
}

art::SampledInfo<art::SubRunID>
detail::SamplingInputFile::fillSubRun(SubRunPrincipal& srp
                                      [[gnu::unused]]) const
{
  // We use a set because it is okay for multiple entries of the same
  // SubRun to be present in the FileIndex--these correspond to SubRun
  // fragments.  However, we do not want these to appear as separate
  // entries in the SampledInfo object.
  std::set<SubRunID> ids;
  for (auto const& element : fileIndex_) {
    if (element.getEntryType() != FileIndex::kSubRun) {
      continue;
    }
    ids.emplace(element.eventID_.run(), element.eventID_.subRun());
  }
  return SampledInfo<SubRunID>{
    weight_, probability_, std::vector<SubRunID>(cbegin(ids), cend(ids))};
}

std::unique_ptr<art::EventPrincipal>
detail::SamplingInputFile::readEvent(input::EntryNumber const entry,
                                     EventID const& eventID,
                                     ProcessConfiguration const& pc)
{
  auto const on_disk_aux = auxiliaryForEntry_(entry);
  auto history = historyForEntry_(entry);

  // We do *not* keep the on-disk EventID for the primary event; we
  // instead create it as an event product.
  art::EventAuxiliary const aux{eventID,
                                on_disk_aux.time(),
                                on_disk_aux.isRealData(),
                                on_disk_aux.experimentType()};
  auto const on_disk_id = on_disk_aux.id();
  auto ep = std::make_unique<art::EventPrincipal>(
    aux,
    pc,
    &presentProducts_.get(InEvent),
    std::make_shared<History>(std::move(history)),
    std::make_unique<BranchMapperWithReader>(productProvenanceBranch_, entry),
    std::make_unique<SamplingDelayedReader>(fileFormatVersion_,
                                            sqliteDB_,
                                            input::EntryNumbers{entry},
                                            branches_,
                                            eventTree_,
                                            -1,
                                            branchIDLists_.get(),
                                            InEvent,
                                            on_disk_id,
                                            false));
  for (auto const& pr : branches_) {
    ep->fillGroup(pr.second.branchDescription_);
  }

  // Place sampled EventID onto event
  auto sampledEventID = std::make_unique<SampledEventInfo>(
    SampledEventInfo{on_disk_id, dataset_, weight_, probability_});
  auto wp = std::make_unique<Wrapper<SampledEventInfo>>(move(sampledEventID));
  auto const& pd = sampledInfoDescriptions_[InEvent];
  ep->put(std::move(wp),
          pd,
          std::make_unique<ProductProvenance const>(pd.productID(),
                                                    productstatus::present()));
  return ep;
}

art::EventAuxiliary
detail::SamplingInputFile::auxiliaryForEntry_(input::EntryNumber const entry)
{
  auto aux = std::make_unique<EventAuxiliary>();
  auto pAux = aux.get();
  auxBranch_->SetAddress(&pAux);
  eventTree_->LoadTree(entry);
  input::getEntry(auxBranch_, entry);
  return *aux;
}

art::History
detail::SamplingInputFile::historyForEntry_(input::EntryNumber const entry)
{
  // We could consider doing delayed reading, but because we have to
  // store this History object in a different tree than the event
  // data tree, this is too hard to do in this first version.
  History history;
  auto pHistory = &history;
  auto eventHistoryBranch =
    eventHistoryTree_->GetBranch(rootNames::eventHistoryBranchName().c_str());
  if (!eventHistoryBranch) {
    throw art::Exception{errors::DataCorruption}
      << "Failed to find history branch in event history tree.\n";
  }
  eventHistoryBranch->SetAddress(&pHistory);
  input::getEntry(eventHistoryTree_, entry);
  return history;
}
