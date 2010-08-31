/*----------------------------------------------------------------------

----------------------------------------------------------------------*/

#include "FWCore/Integration/test/TestRunLumiSource.h"
#include "art/Persistency/Provenance/EventID.h"
#include "art/Persistency/Provenance/LuminosityBlockID.h"
#include "art/Persistency/Provenance/EventAuxiliary.h"
#include "art/Persistency/Provenance/LuminosityBlockAuxiliary.h"
#include "art/Persistency/Provenance/RunAuxiliary.h"
#include "art/ParameterSet/ParameterSet.h"
#include "art/Framework/Core/EventPrincipal.h"
#include "art/Framework/Core/LuminosityBlockPrincipal.h"
#include "art/Framework/Core/RunPrincipal.h"
#include "art/Persistency/Provenance/Timestamp.h"
#include "art/Framework/Core/InputSourceMacros.h"

namespace edm {

  TestRunLumiSource::TestRunLumiSource(ParameterSet const& pset,
				       InputSourceDescription const& desc) :
    InputSource(pset, desc),
    runLumiEvent_(pset.getUntrackedParameter<std::vector<int> >("runLumiEvent", std::vector<int>())),
    currentIndex_(0),
    firstTime_(true) {
  }

  TestRunLumiSource::~TestRunLumiSource() {
  }

  boost::shared_ptr<RunPrincipal>
  TestRunLumiSource::readRun_() {
    unsigned int run = runLumiEvent_[currentIndex_];
    Timestamp ts = Timestamp(1);  // 1 is just a meaningless number to make it compile for the test

    RunAuxiliary runAux(run, ts, Timestamp::invalidTimestamp());
    boost::shared_ptr<RunPrincipal> runPrincipal(
        new RunPrincipal(runAux, productRegistry(), processConfiguration()));
    currentIndex_ += 3;
    return runPrincipal;
  }

  boost::shared_ptr<LuminosityBlockPrincipal>
  TestRunLumiSource::readLuminosityBlock_() {
    unsigned int run = runLumiEvent_[currentIndex_];
    unsigned int lumi = runLumiEvent_[currentIndex_ + 1];
    Timestamp ts = Timestamp(1);

    RunAuxiliary runAux(run, ts, Timestamp::invalidTimestamp());
    boost::shared_ptr<RunPrincipal> rp2(
        new RunPrincipal(runAux, productRegistry(), processConfiguration()));

    LuminosityBlockAuxiliary lumiAux(rp2->run(), lumi, ts, Timestamp::invalidTimestamp());
    boost::shared_ptr<LuminosityBlockPrincipal> luminosityBlockPrincipal(
        new LuminosityBlockPrincipal(lumiAux, productRegistry(), processConfiguration()));
    luminosityBlockPrincipal->setRunPrincipal(rp2);

    currentIndex_ += 3;
    return luminosityBlockPrincipal;
  }

  std::auto_ptr<EventPrincipal>
  TestRunLumiSource::readEvent_() {
    EventSourceSentry(*this);
    unsigned int run = runLumiEvent_[currentIndex_];
    unsigned int lumi = runLumiEvent_[currentIndex_ + 1];
    unsigned int event = runLumiEvent_[currentIndex_ + 2];
    Timestamp ts = Timestamp(1);

    RunAuxiliary runAux(run, ts, Timestamp::invalidTimestamp());
    boost::shared_ptr<RunPrincipal> rp2(
        new RunPrincipal(runAux, productRegistry(), processConfiguration()));

    LuminosityBlockAuxiliary lumiAux(rp2->run(), lumi, ts, Timestamp::invalidTimestamp());
    boost::shared_ptr<LuminosityBlockPrincipal> lbp2(
        new LuminosityBlockPrincipal(lumiAux, productRegistry(), processConfiguration()));
    lbp2->setRunPrincipal(rp2);

    EventID id(run, event);
    currentIndex_ += 3;
    EventAuxiliary eventAux(id, processGUID(), ts, lbp2->luminosityBlock(), false);
    std::auto_ptr<EventPrincipal> result(
	new EventPrincipal(eventAux, productRegistry(), processConfiguration()));
    result->setLuminosityBlockPrincipal(lbp2);
    return result;
  }

  InputSource::ItemType
  TestRunLumiSource::getNextItemType() {
    if (firstTime_) {
      firstTime_ = false;
      return InputSource::IsFile;
    }
    if (currentIndex_ + 2 >= runLumiEvent_.size()) {
      return InputSource::IsStop;
    }
    if (runLumiEvent_[currentIndex_] == 0) {
      return InputSource::IsStop;
    }
    ItemType oldState = state();
    if (oldState == IsInvalid) return InputSource::IsFile;
    if (runLumiEvent_[currentIndex_ + 1] == 0) {
      return InputSource::IsRun;
    }
    if (runLumiEvent_[currentIndex_ + 2] == 0) {
      return InputSource::IsLumi;
    }
    return InputSource::IsEvent;
  }
}

using edm::TestRunLumiSource;
DEFINE_FWK_INPUT_SOURCE(TestRunLumiSource);

