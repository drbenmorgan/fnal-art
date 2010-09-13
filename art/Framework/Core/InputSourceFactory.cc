
#include "art/Framework/Core/InputSourceFactory.h"
#include "fhiclcpp/ParameterSet.h"
#include "art/Utilities/DebugMacros.h"
#include "art/Utilities/EDMException.h"

#include <iostream>

EDM_REGISTER_PLUGINFACTORY(edm::InputSourcePluginFactory,"CMS EDM Framework InputSource");

namespace edm {

  InputSourceFactory::~InputSourceFactory()
  { }

  InputSourceFactory::InputSourceFactory()
  { }

  InputSourceFactory InputSourceFactory::singleInstance_;

  InputSourceFactory* InputSourceFactory::get()
  {
    // will not work with plugin factories
    //static InputSourceFactory f;
    //return &f;

    return &singleInstance_;
  }

  std::auto_ptr<InputSource>
  InputSourceFactory::makeInputSource(ParameterSet const& conf,
                                      InputSourceDescription const& desc) const
  {
    std::string modtype = conf.getString("@module_type");
    FDEBUG(1) << "InputSourceFactory: module_type = " << modtype << std::endl;
    std::auto_ptr<InputSource> wm;
    try {
      wm = std::auto_ptr<InputSource>(InputSourcePluginFactory::get()->create(modtype,conf,desc));
    }
    catch(edm::Exception& ex) {
      ex << "Error occurred while creating source " << modtype << "\n";
      throw ex;
    }
    catch(cms::Exception& e) {
      e << "Error occurred while creating source " << modtype << "\n";
      throw e;
    }

    if(wm.get()==0) {
        throw edm::Exception(errors::Configuration,"NoSourceModule")
          << "InputSource Factory:\n"
          << "Cannot find source type from ParameterSet: "
          << modtype << "\n"
          << "Perhaps your source type is misspelled or is not an EDM Plugin?\n"
          << "Try running EdmPluginDump to obtain a list of available Plugins.";
    }

    wm->registerProducts();

    FDEBUG(1) << "InputSourceFactory: created input source "
              << modtype
              << std::endl;

    return wm;
  }

}  // namespace edm
