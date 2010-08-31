#ifndef Framework_DependentEventSetupRecordProvider_h
#define Framework_DependentEventSetupRecordProvider_h
// -*- C++ -*-
//
// Package:     Framework
// Class  :     DependentEventSetupRecordProvider
//
/**\class DependentEventSetupRecordProvider DependentEventSetupRecordProvider.h FWCore/Framework/interface/DependentEventSetupRecordProvider.h

 Description: <one line class summary>

 Usage:
    <usage>

*/
//
// Author:      Chris Jones
// Created:     Sun May  1 16:30:01 EDT 2005
//
//

// system include files
#include <vector>
#include "boost/shared_ptr.hpp"

// user include files
#include "art/Framework/Core/EventSetupRecordProvider.h"

// forward declarations
namespace edm {
   namespace eventsetup {
      class DependentRecordIntervalFinder;

class DependentEventSetupRecordProvider : public EventSetupRecordProvider
{

   public:
      DependentEventSetupRecordProvider(const EventSetupRecordKey& iKey):
      EventSetupRecordProvider(iKey) {}
      //virtual ~DependentEventSetupRecordProvider();

      // ---------- const member functions ---------------------

      // ---------- static member functions --------------------

      // ---------- member functions ---------------------------

      void setDependentProviders(const std::vector< boost::shared_ptr<EventSetupRecordProvider> >&);

   private:
      DependentEventSetupRecordProvider(const DependentEventSetupRecordProvider&); // stop default

      const DependentEventSetupRecordProvider& operator=(const DependentEventSetupRecordProvider&); // stop default

      // ---------- member data --------------------------------
};

   }
}

#endif
