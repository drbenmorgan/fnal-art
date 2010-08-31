#ifndef Integration_OtherThingAnalyzer_h
#define Integration_OtherThingAnalyzer_h

#include "art/Framework/Core/Frameworkfwd.h"
#include "art/Framework/Core/EDAnalyzer.h"

namespace edmtest {

  class OtherThingAnalyzer : public edm::EDAnalyzer {
  public:

    explicit OtherThingAnalyzer(edm::ParameterSet const& pset);

    virtual ~OtherThingAnalyzer() {}

    virtual void analyze(edm::Event const& e, edm::EventSetup const& c);

    void doit(edm::Event const& event, std::string const& label);

  private:
    bool thingWasDropped_;
  };

}

#endif
