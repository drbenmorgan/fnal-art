#include <algorithm>
#include <iterator>
#include <sstream>

#include "art/Framework/Core/EDAnalyzer.h"
#include "art/Framework/Core/MakerMacros.h"
#include "art/Framework/Core/TriggerNamesService.h"
#include "art/MessageLogger/MessageLogger.h"
#include "art/Framework/Services/Registry/Service.h"
#include "art/Utilities/Algorithms.h"
#include "art/ParameterSet/ParameterSet.h"
#include "art/ParameterSet/Registry.h"

namespace edmtest
{
  class PathAnalyzer : public edm::EDAnalyzer
  {
  public:

    explicit PathAnalyzer(edm::ParameterSet const&);
    virtual ~PathAnalyzer();

    virtual void analyze(edm::Event const&, edm::EventSetup const&);
    virtual void beginJob(edm::EventSetup const&);
    virtual void endJob();

  private:
    void dumpTriggerNamesServiceInfo(char const* where);
  }; // class PathAnalyzer

  //--------------------------------------------------------------------
  //
  // Implementation details

  PathAnalyzer::PathAnalyzer(edm::ParameterSet const&) { }

  PathAnalyzer::~PathAnalyzer() {}

  void
  PathAnalyzer::analyze(edm::Event const&, edm::EventSetup const&)
  {
    dumpTriggerNamesServiceInfo("analyze");
  }

  void
  PathAnalyzer::beginJob(edm::EventSetup const&)
  {
    dumpTriggerNamesServiceInfo("beginJob");

    // Make sure we can get a the process parameter set. This test
    // doesn't really belong here, but I had to stick it somewhere
    // quickly...

    edm::ParameterSet ppset = edm::getProcessParameterSet();
    assert (ppset.id().isValid());
  }

  void
  PathAnalyzer::endJob()
  {
    dumpTriggerNamesServiceInfo("endJob");
  }

  void
  PathAnalyzer::dumpTriggerNamesServiceInfo(char const* where)
  {
    typedef edm::Service<edm::service::TriggerNamesService>  TNS;
    typedef std::vector<std::string> stringvec;

    TNS tns;
    std::ostringstream message;

    stringvec const& trigpaths = tns->getTrigPaths();
    message << "dumpTriggernamesServiceInfo called from PathAnalyzer::"
	    << where << '\n';
    message << "trigger paths are: ";

    edm::copy_all(trigpaths, std::ostream_iterator<std::string>(message, " "));
    message << '\n';

    for (stringvec::const_iterator i = trigpaths.begin(), e = trigpaths.end();
	 i != e;
	 ++i)
      {
	message << "path name: " << *i << " contains: ";
	edm::copy_all(tns->getTrigPathModules(*i), std::ostream_iterator<std::string>(message, " "));
	message << '\n';
      }

    message << "trigger ParameterSet:\n"
	    << tns->getTriggerPSet()
	    << '\n';

    edm::LogInfo("PathAnalyzer") << "TNS size: " << tns->size()
				 << "\n"
				 << message.str()
				 << std::endl;
  }

} // namespace edmtest

using edmtest::PathAnalyzer;
DEFINE_FWK_MODULE(PathAnalyzer);
