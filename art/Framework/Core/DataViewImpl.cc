#include "art/Framework/Core/DataViewImpl.h"

#include "art/Framework/Core/Principal.h"
#include "art/Framework/Core/Selector.h"
#include "art/Persistency/Provenance/ModuleDescription.h"
#include "art/Persistency/Provenance/ProductProvenance.h"
#include "art/Persistency/Provenance/ProductRegistry.h"
#include "art/Persistency/Provenance/ProductStatus.h"
#include "cetlib/container_algorithms.h"
#include <algorithm>

using namespace cet;
using namespace std;

namespace art {

  DataViewImpl::DataViewImpl(Principal & pcpl,
        ModuleDescription const& md,
        BranchType const& branchType)  :
    putProducts_(),
    principal_(pcpl),
    md_(md),
    branchType_(branchType)
  {  }

  struct deleter {
    void operator()(pair<EDProduct*, ConstBranchDescription const*> const p) const { delete p.first; }
  };

  DataViewImpl::~DataViewImpl() {
    // anything left here must be the result of a failure
    // let's record them as failed attempts in the event principal
    for_all(putProducts_, deleter());
  }

  size_t
  DataViewImpl::size() const {
    return putProducts_.size() + principal_.size();
  }

  BasicHandle
  DataViewImpl::get_(TypeID const& tid, SelectorBase const& sel) const
  {
    return principal_.getBySelector(tid, sel);
  }

  void
  DataViewImpl::getMany_(TypeID const& tid,
                  SelectorBase const& sel,
                  BasicHandleVec& results) const
  {
    principal_.getMany(tid, sel, results);
  }

  BasicHandle
  DataViewImpl::getByLabel_(TypeID const& tid,
                     string const& label,
                     string const& productInstanceName,
                     string const& processName) const
  {
    return principal_.getByLabel(tid, label, productInstanceName, processName);
  }

  void
  DataViewImpl::getManyByType_(TypeID const& tid,
                  BasicHandleVec& results) const
  {
    principal_.getManyByType(tid, results);
  }

  int
  DataViewImpl::getMatchingSequence_(TypeID const& typeID,
                                     SelectorBase const& selector,
                                     BasicHandleVec& results,
                                     bool stopIfProcessHasMatch) const
  {
    return principal_.getMatchingSequence(typeID,
                                    selector,
                                    results,
                                    stopIfProcessHasMatch);
  }

  int
  DataViewImpl::getMatchingSequenceByLabel_(TypeID const& typeID,
                                            string const& label,
                                            string const& productInstanceName,
                                            BasicHandleVec& results,
                                            bool stopIfProcessHasMatch) const
  {
    art::Selector sel(art::ModuleLabelSelector(label) &&
                      art::ProductInstanceNameSelector(productInstanceName));

    int n = principal_.getMatchingSequence(typeID,
                                     sel,
                                     results,
                                     stopIfProcessHasMatch);
    return n;
  }

  int
  DataViewImpl::getMatchingSequenceByLabel_(TypeID const& typeID,
                                            string const& label,
                                            string const& productInstanceName,
                                            string const& processName,
                                            BasicHandleVec& results,
                                            bool stopIfProcessHasMatch) const
  {
    art::Selector sel(art::ModuleLabelSelector(label) &&
                      art::ProductInstanceNameSelector(productInstanceName) &&
                      art::ProcessNameSelector(processName) );

    int n = principal_.getMatchingSequence(typeID,
                                   sel,
                                   results,
                                   stopIfProcessHasMatch);
    return n;
  }

  ProcessHistory const&
  DataViewImpl::processHistory() const
  {
    return principal_.processHistory();
  }

  ConstBranchDescription const&
  DataViewImpl::getBranchDescription(TypeID const& type,
                                     string const& productInstanceName) const {
    string friendlyClassName = type.friendlyClassName();
        BranchKey bk(friendlyClassName, md_.moduleLabel(), productInstanceName, md_.processName());
    ProductRegistry::ConstProductList const& pl = principal_.productRegistry().constProductList();
    ProductRegistry::ConstProductList::const_iterator it = pl.find(bk);
    if (it == pl.end()) {
      throw art::Exception(art::errors::InsertFailure)
        << "Illegal attempt to 'put' an unregistered product.\n"
        << "No product is registered for\n"
        << "  process name:                '" << bk.processName_ << "'\n"
        << "  module label:                '" << bk.moduleLabel_ << "'\n"
        << "  product friendly class name: '" << bk.friendlyClassName_ << "'\n"
        << "  product instance name:       '" << bk.productInstanceName_ << "'\n"

        << "The ProductRegistry contains:\n"
        << principal_.productRegistry()
        << '\n';
    }
    if(it->second.branchType() != branchType_) {
        throw art::Exception(art::errors::InsertFailure,"Not Registered")
          << "put: Problem found while adding product. "
          << "The product for ("
          << bk.friendlyClassName_ << ","
          << bk.moduleLabel_ << ","
          << bk.productInstanceName_ << ","
          << bk.processName_
          << ")\n"
          << "is registered for a(n) " << it->second.branchType()
          << " instead of for a(n) " << branchType_
          << ".\n";
    }
    return it->second;
  }

  EDProductGetter const*
  DataViewImpl::prodGetter() const{
    return principal_.prodGetter();
  }

}  // art
