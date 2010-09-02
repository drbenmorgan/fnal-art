#ifndef Integration_ThingRawSource_h
#define Integration_ThingRawSource_h

/** \class ThingRawSource
 *
 * \version   1st Version Dec. 27, 2005

 *
 ************************************************************/

#include "art/Persistency/Provenance/EventID.h"
#include "art/Framework/Core/Frameworkfwd.h"
#include "art/Framework/IO/Sources/RawInputSource.h"
#include "FWCore/Integration/test/ThingAlgorithm.h"

namespace edmtest {
  class ThingRawSource : public edm::RawInputSource {
  public:

    // The following is not yet used, but will be the primary
    // constructor when the parameter set system is available.
    //
    explicit ThingRawSource(edm::ParameterSet const& pset, edm::InputSourceDescription const& desc);

    virtual ~ThingRawSource();

    virtual std::auto_ptr<edm::Event> readOneEvent();

    virtual void beginRun(edm::Run& r);

    virtual void endRun(edm::Run& r);

    virtual void beginSubRun(edm::SubRun& lb);

    virtual void endSubRun(edm::SubRun& lb);

  private:
    ThingAlgorithm alg_;
    edm::EventID eventID_;
  };
}
#endif
