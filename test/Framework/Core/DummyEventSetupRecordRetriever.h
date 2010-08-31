#ifndef Framework_DummyEventSetupRecordRetriever_h
#define Framework_DummyEventSetupRecordRetriever_h
// -*- C++ -*-
//
// Package:     Framework
// Class  :     DummyEventSetupRecordRetriever
//
/**\class DummyEventSetupRecordRetriever DummyEventSetupRecordRetriever.h FWCore/Framework/interface/DummyEventSetupRecordRetriever.h

 Description: <one line class summary>

 Usage:
    <usage>

*/
//
// Author:      Chris Jones
// Created:     Fri Apr 22 14:14:09 EDT 2005
//
//

// system include files

// user include files
#include "art/Framework/Core/EventSetupRecordIntervalFinder.h"
#include "art/Framework/Core/ESProducer.h"

#include "test/Framework/Core/DummyEventSetupRecord.h"
#include "test/Framework/Core/DummyEventSetupData.h"

// forward declarations
namespace edm {
   class DummyEventSetupRecordRetriever :
     public EventSetupRecordIntervalFinder,
     public ESProducer
   {

   public:
      DummyEventSetupRecordRetriever() {
         this->findingRecord<DummyEventSetupRecord>();
         setWhatProduced(this);
      }

      std::auto_ptr<DummyEventSetupData> produce(const DummyEventSetupRecord&) {
         std::auto_ptr<DummyEventSetupData> data(new DummyEventSetupData(1));
         return data;
      }
   protected:

      virtual void setIntervalFor(const edm::eventsetup::EventSetupRecordKey&,
                                   const edm::IOVSyncValue& /*iTime*/,
                                   edm::ValidityInterval& iInterval) {
         iInterval = edm::ValidityInterval(IOVSyncValue::beginOfTime(),
                                            IOVSyncValue::endOfTime());
      }

   private:
      DummyEventSetupRecordRetriever(const DummyEventSetupRecordRetriever&); // stop default

      const DummyEventSetupRecordRetriever& operator=(const DummyEventSetupRecordRetriever&); // stop default

      // ---------- member data --------------------------------

};
}
#endif
