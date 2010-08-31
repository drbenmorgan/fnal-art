#ifndef Integration_MessageLoggerClient_h
#define Integration_MessageLoggerClient_h

#include "art/Framework/Core/Frameworkfwd.h"
#include "art/Framework/Core/EDAnalyzer.h"


namespace edm {
  class ParameterSet;
}


namespace edmtest
{

class MessageLoggerClient
  : public edm::EDAnalyzer
{
public:
  explicit
    MessageLoggerClient( edm::ParameterSet const & )
  { }

  virtual
    ~MessageLoggerClient()
  { }

  virtual
    void analyze( edm::Event      const & e
                , edm::EventSetup const & c
                );

private:
};


}  // namespace edmtest


#endif  // Integration_MessageLoggerClient_h
