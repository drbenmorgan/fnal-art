#include "test/Framework/Services/Message/UnitTestClient_O.h"
#include "art/MessageLogger/MessageLogger.h"
#include "art/Framework/Core/MakerMacros.h"

#include <iostream>
#include <string>

namespace edmtest
{


void
  UnitTestClient_O::analyze( edm::Event      const & e
                           , edm::EventSetup const & /*unused*/
                              )
{
  edm::LogInfo   ("importantInfo")
  		<< "This LogInfo message should appear in both destinations";
  edm::LogInfo   ("routineInfo")
		<< "This LogInfo message should appear in the info destination";


 }  // MessageLoggerClient::analyze()


}  // namespace edmtest


using edmtest::UnitTestClient_O;
DEFINE_FWK_MODULE(UnitTestClient_O);
