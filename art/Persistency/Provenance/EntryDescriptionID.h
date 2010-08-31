#ifndef DataFormats_Provenance_EntryDescriptionID_h
#define DataFormats_Provenance_EntryDescriptionID_h

#include "art/Persistency/Provenance/HashedTypes.h"
#include "art/Persistency/Provenance/Hash.h"

namespace edm
{
  typedef Hash<EntryDescriptionType> EntryDescriptionID;
}


#endif
