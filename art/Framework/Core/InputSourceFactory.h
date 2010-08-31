#ifndef FWCore_Framework_InputSourceFactory_h
#define FWCOre_Framework_InputSourceFactory_h

#include "art/Framework/PluginManager/PluginFactory.h"
#include "art/Framework/Core/InputSource.h"

#include <string>
#include <memory>

namespace edm {

  typedef InputSource* (ISFunc)(ParameterSet const&, InputSourceDescription const&);

  typedef edmplugin::PluginFactory<ISFunc> InputSourcePluginFactory;

  class InputSourceFactory {
  public:
    ~InputSourceFactory();

    static InputSourceFactory* get();

    std::auto_ptr<InputSource>
      makeInputSource(ParameterSet const&,
		       InputSourceDescription const&) const;


  private:
    InputSourceFactory();
    static InputSourceFactory singleInstance_;
  };

}
#endif
