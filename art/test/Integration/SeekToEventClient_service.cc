#include "art/Framework/Services/Registry/ActivityRegistry.h"
#include "art/Framework/IO/Root/RootInput.h"
#include "art/test/Integration/SeekToEventClient.h"
#include "fhiclcpp/ParameterSet.h"

arttest::SeekToEventClient::SeekToEventClient(Parameters const& config,
                                              art::ActivityRegistry& r)
  : nextEventsToProcess_{config().nextEventsToProcess()}
{
  r.sPostBeginJobWorkers.watch(this, &SeekToEventClient::postBeginJobWorkers);
  r.sPostProcessEvent.watch(this, &SeekToEventClient::postProcessEvent);
}

void
arttest::SeekToEventClient::postBeginJobWorkers(art::InputSource* input_source,
                                                std::vector<art::Worker*> const&)
{
  if (nextEventsToProcess_.empty()) return;

  input_ = dynamic_cast<art::RootInput*>(input_source);
  if (!input_)
    throw art::Exception(art::errors::Configuration)
      << "The SeekToEventClient service can be used only with\n"
      << "the RootInput source.\n";
}

void
arttest::SeekToEventClient::postProcessEvent(art::Event const&)
{
  if (nextEventsToProcess_.empty()) return;
  input_->seekToEvent(nextEventsToProcess_[0]);
  nextEventsToProcess_.erase(nextEventsToProcess_.begin());
}

DEFINE_ART_SERVICE(arttest::SeekToEventClient)