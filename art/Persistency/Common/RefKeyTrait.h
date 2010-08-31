#ifndef DataFormats_Common_RefKeyTrait_h
#define DataFormats_Common_RefKeyTrait_h
#include "art/Utilities/EDMException.h"

namespace edm {
  template <typename C> class RefProd;
  namespace reftobase {

    struct RefKey {
      template<typename REF>
      static size_t key( const REF & r ) {
	return r.key();
      }
    };

    struct RefProdKey {
      template<typename REF>
      static size_t key( const REF & r ) {
	throw edm::Exception(errors::InvalidReference)
	  << "attempting get key from a RefToBase containing a RefProd.\n"
	  << "You can use key only with RefToBase containing a Ref.";
      }
    };

    template<typename REF>
    struct RefKeyTrait {
      typedef RefKey type;
    };

    template<typename C>
    struct RefKeyTrait<RefProd<C> > {
      typedef RefProdKey type;
    };
  }
}

#endif
