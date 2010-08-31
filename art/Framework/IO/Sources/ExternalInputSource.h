#ifndef FWCore_Sources_ExternalInputSource_h
#define FWCore_Sources_ExternalInputSource_h

/*----------------------------------------------------------------------

----------------------------------------------------------------------*/

#include <memory>
#include <vector>
#include <string>

#include "art/Framework/Core/ConfigurableInputSource.h"
#include "art/Framework/IO/Catalog/InputFileCatalog.h"

namespace edm {
  class ExternalInputSource : public ConfigurableInputSource {
  public:
    ExternalInputSource(ParameterSet const& pset, InputSourceDescription const& desc, bool realData = true);
    virtual ~ExternalInputSource();

  std::vector<std::string> const& logicalFileNames() const {return catalog_.logicalFileNames();}
  std::vector<std::string> const& fileNames() const {return catalog_.fileNames();}
  InputFileCatalog& catalog() {return catalog_;}


  private:
    PoolCatalog poolCatalog_;
    InputFileCatalog catalog_;
  };
}
#endif
