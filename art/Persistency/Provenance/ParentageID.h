#ifndef DataFormats_Provenance_ParentageID_h
#define DataFormats_Provenance_ParentageID_h

#include "art/Persistency/Provenance/HashedTypes.h"
#include "art/Persistency/Provenance/Hash.h"

namespace edm
{
  typedef Hash<ParentageType> ParentageID;
}


#endif
