#include "art/Framework/Services/Basic/LockService.h"
#include "art/Persistency/Provenance/ModuleDescription.h"
//#include "art/Utilities/Algorithms.h"
#include "art/Utilities/DebugMacros.h"
#include "art/Utilities/GlobalMutex.h"

#include <algorithm>
#include <iostream>

using namespace edm::rootfix;

LockService::LockService(const ParameterSet& iPS,
			 ActivityRegistry& reg):
  lock_(getGlobalMutex()),
  locker_(),
  labels_(iPS.getVString("labels",Labels())),
  lockSources_(iPS.getBool("lockSources",true))
{
  reg.watchPreSourceConstruction(this,&LockService::preSourceConstruction);
  reg.watchPostSourceConstruction(this,&LockService::postSourceConstruction);

  // reg.watchPostBeginJob(this,&LockService::postBeginJob);
  // reg.watchPostEndJob(this,&LockService::postEndJob);

  // reg.watchPreProcessEvent(this,&LockService::preEventProcessing);
  // reg.watchPostProcessEvent(this,&LockService::postEventProcessing);
  reg.watchPreSource(this,&LockService::preSource);
  reg.watchPostSource(this,&LockService::postSource);

  reg.watchPreModule(this,&LockService::preModule);
  reg.watchPostModule(this,&LockService::postModule);

  FDEBUG(4) << "In LockServices" << std::endl;
}


LockService::~LockService()
{
  delete locker_;
}
void LockService::preSourceConstruction(const ModuleDescription& desc)
{
  if(!labels_.empty() &&
     find(labels_.begin(), labels_.end(), desc.moduleLabel_) != labels_.end())
     //search_all(labels_, desc.moduleLabel_))
    {
      FDEBUG(4) << "made a new locked in LockService" << std::endl;
      locker_ = new boost::mutex::scoped_lock(*lock_);
    }
}

void LockService::postSourceConstruction(const ModuleDescription& desc)
{
  FDEBUG(4) << "destroyed a locked in LockService" << std::endl;
  delete locker_;
  locker_=0;
}

void LockService::postBeginJob()
{
}

void LockService::postEndJob()
{
}

void LockService::preEventProcessing(const edm::EventID& iID,
				     const edm::Timestamp& iTime)
{
}

void LockService::postEventProcessing(const Event& e)
{
}
void LockService::preSource()
{
  if(lockSources_)
    {
      FDEBUG(4) << "made a new locked in LockService" << std::endl;
      locker_ = new boost::mutex::scoped_lock(*lock_);
    }
}

void LockService::postSource()
{
  FDEBUG(4) << "destroyed a locked in LockService" << std::endl;
  delete locker_;
  locker_=0;
}

void LockService::preModule(const ModuleDescription& desc)
{
  if(!labels_.empty() &&
     find(labels_.begin(), labels_.end(), desc.moduleLabel_) != labels_.end())
     //search_all(labels_, desc.moduleLabel_))
    {
      FDEBUG(4) << "made a new locked in LockService" << std::endl;
      locker_ = new boost::mutex::scoped_lock(*lock_);
    }
}

void LockService::postModule(const ModuleDescription& desc)
{
  FDEBUG(4) << "destroyed a locked in LockService" << std::endl;
  delete locker_;
  locker_=0;
}


