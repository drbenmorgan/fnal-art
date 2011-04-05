#ifndef art_Framework_Core_EDAnalyzer_h
#define art_Framework_Core_EDAnalyzer_h

// ======================================================================
//
// EDAnalyzer - the base class for all analyzer "modules".
//
// ======================================================================

#include "art/Framework/Core/EngineCreator.h"
#include "art/Framework/Core/EventObserver.h"
#include "art/Framework/Core/Frameworkfwd.h"
#include "art/Framework/Core/WorkerT.h"
#include "boost/shared_ptr.hpp"
#include <ostream>
#include <string>

// ----------------------------------------------------------------------

namespace art
{

  class EDAnalyzer
    : public EventObserver,
      public EngineCreator
  {
  public:
    template <typename T> friend class WorkerT;
    typedef EDAnalyzer ModuleType;
    typedef WorkerT<EDAnalyzer> WorkerType;

    EDAnalyzer()
      : EngineCreator()
      , moduleDescription_()
      , current_context_(0)
    { }
    virtual ~EDAnalyzer();

    std::string workerType() const {return "WorkerT<EDAnalyzer>";}

  protected:
    // The returned pointer will be null unless the this is currently
    // executing its event loop function ('analyze').
    CurrentProcessingContext const* currentContext() const;

  private:
    bool doEvent(EventPrincipal const& ep,
                   CurrentProcessingContext const* cpc);
    void doBeginJob();
    void doEndJob();
    bool doBeginRun(RunPrincipal const& rp,
                   CurrentProcessingContext const* cpc);
    bool doEndRun(RunPrincipal const& rp,
                   CurrentProcessingContext const* cpc);
    bool doBeginSubRun(SubRunPrincipal const& srp,
                   CurrentProcessingContext const* cpc);
    bool doEndSubRun(SubRunPrincipal const& srp,
                   CurrentProcessingContext const* cpc);
    void doRespondToOpenInputFile(FileBlock const& fb);
    void doRespondToCloseInputFile(FileBlock const& fb);
    void doRespondToOpenOutputFiles(FileBlock const& fb);
    void doRespondToCloseOutputFiles(FileBlock const& fb);
    void registerAnyProducts(boost::shared_ptr<EDAnalyzer>const&, ProductRegistry const*) {}

    virtual void analyze(Event const&) = 0;
    virtual void beginJob(){}
    virtual void endJob(){}
    virtual void reconfigure(ParameterSet const&);
    virtual void beginRun(Run const&){}
    virtual void endRun(Run const&){}
    virtual void beginSubRun(SubRun const&){}
    virtual void endSubRun(SubRun const&){}
    virtual void respondToOpenInputFile(FileBlock const& fb) {}
    virtual void respondToCloseInputFile(FileBlock const& fb) {}
    virtual void respondToOpenOutputFiles(FileBlock const& fb) {}
    virtual void respondToCloseOutputFiles(FileBlock const& fb) {}

    void setModuleDescription(ModuleDescription const& md) {
      moduleDescription_ = md;
    }

    ModuleDescription moduleDescription_;
    CurrentProcessingContext const* current_context_;
  };  // EDAnalyzer

}  // art

// ======================================================================

#endif /* art_Framework_Core_EDAnalyzer_h */

// Local Variables:
// mode: c++
// End:
