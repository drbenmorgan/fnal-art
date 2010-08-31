#include "art/Framework/PluginManager/PresenceMacros.h"
#include "art/Framework/Services/Message/MessageLogger.h"
#include "art/Framework/Services/Message/MessageServicePresence.h"
#include "art/Framework/Services/Message/SingleThreadMSPresence.h"
#include "art/Framework/Services/Registry/ServiceMaker.h"

using edm::service::MessageLogger;

DEFINE_FWK_SERVICE(MessageLogger);
