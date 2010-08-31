#ifndef DataFormats_Common_RefToBaseProd_h
#define DataFormats_Common_RefToBaseProd_h

/* \class edm::RefToBaseProd<T>
 *
 * \author Luca Lista, INFN
 *
 *
 *
 */

#include "art/Persistency/Common/EDProductfwd.h"
#include "art/Persistency/Common/RefCore.h"
#include "art/Persistency/Provenance/ProductID.h"
#include "art/Persistency/Common/ConstPtrCache.h"

namespace edm {
  template<typename T> class View;
  template<typename C> class Handle;

  template <typename T>
  class RefToBaseProd {
  public:
    typedef View<T> product_type;

    /// Default constructor needed for reading from persistent store. Not for direct use.
    RefToBaseProd() : product_(), viewCache_(0) {}

    /// General purpose constructor from handle-like object.
    // The templating is artificial.
    // HandleC must have the following methods:
    //   id(),      returning a ProductID,
   //   product(), returning a C*.
    template <class HandleC>
    explicit RefToBaseProd(HandleC const& handle);
    explicit RefToBaseProd(Handle<View<T> > const& handle);
    /// Constructor from Ref<C,T,F>
    template <typename C, typename F>
    explicit RefToBaseProd(Ref<C, T, F> const& ref);
    explicit RefToBaseProd(RefToBase<T> const& ref);
    explicit RefToBaseProd( const View<T> & );
    RefToBaseProd( const RefToBaseProd<T> & );
    template<typename C>
    RefToBaseProd( const RefProd<C> & );

    /// Destructor
    ~RefToBaseProd() { delete viewPtr();}

    /// Dereference operator
    product_type const&  operator*() const;

    /// Member dereference operator
    product_type const* operator->() const;

    /// Returns C++ pointer to the product
    /// Will attempt to retrieve product
    product_type const* get() const {
      return isNull() ? 0 : this->operator->();
    }

    /// Returns C++ pointer to the product
    /// Will attempt to retrieve product
    product_type const* product() const {
      return isNull() ? 0 : this->operator->();
    }

    RefCore const& refCore() const {
      return product_;
    }

    /// Checks for null
    bool isNull() const {return !isNonnull(); }

    /// Checks for non-null
    bool isNonnull() const {return id().isValid(); }

    /// Checks for null
    bool operator!() const {return isNull(); }

    /// Accessor for product ID.
    ProductID id() const {return product_.id();}

    /// Accessor for product getter.
    EDProductGetter const* productGetter() const {return product_.productGetter();}

    /// Checks if product is in memory.
    bool hasCache() const {return product_.productPtr() != 0;}

    RefToBaseProd<T> & operator=( const RefToBaseProd<T> & other );

    void swap(RefToBaseProd<T> &);

  private:
    View<T> const* viewPtr() const {
      return reinterpret_cast<const View<T>*>(viewCache_.ptr_);
    }
    RefCore product_;
    mutable ConstPtrCache viewCache_;
  };
}

#include "art/Persistency/Common/View.h"
#include "art/Persistency/Common/Handle.h"
#include "art/Persistency/Common/Ref.h"
#include "art/Persistency/Common/RefCoreGet.h"
#include "art/Persistency/Common/RefVectorHolder.h"
#include "art/Persistency/Common/RefVector.h"
#include "art/Persistency/Common/RefTraits.h"

namespace edm {

  namespace refhelper {
    template<typename C,
	     typename T = typename refhelper::ValueTrait<C>::value,
	     typename F = typename refhelper::FindTrait<C, T>::value>
    struct RefToBaseProdTrait {
      typedef RefVector<C, T, F> ref_vector_type;
    };

    template<typename C, typename T, typename F, typename T1, typename F1>
    struct RefToBaseProdTrait<RefVector<C, T, F>, T1, F1> {
      typedef RefVector<C, T, F> ref_vector_type;
    };
  }

  template <typename T>
  inline
  RefToBaseProd<T>::RefToBaseProd(Handle<View<T> > const& handle) :
    product_(handle->id(), 0, handle->productGetter(), false ),
    viewCache_( new View<T>( * handle ) ) {
    assert( handle->productGetter() == 0 );
  }

  template <typename T>
  inline
  RefToBaseProd<T>::RefToBaseProd( const View<T> & view ) :
    product_( view.id(), 0, view.productGetter(), false ),
    viewCache_( new View<T>( view ) ) {
  }

  template <typename T>
  inline
  RefToBaseProd<T>::RefToBaseProd( const RefToBaseProd<T> & ref ) :
    product_( ref.product_ ),
    viewCache_( ref.viewPtr() ? (new View<T>( * ref ) ) : 0 ) {
  }

  template <typename T>
  inline
  RefToBaseProd<T> & RefToBaseProd<T>::operator=( const RefToBaseProd<T> & other ) {
    RefToBaseProd<T> temp(other);
    this->swap(temp);
    return *this;
  }

  /// Dereference operator
  template <typename T>
  inline
  View<T> const& RefToBaseProd<T>::operator*() const {
    return * operator->();
  }

  /// Member dereference operator
  template <typename T>
  inline
  View<T> const* RefToBaseProd<T>::operator->() const {
    if ( viewCache_.ptr_ == 0 ) {
      if ( product_.isNull() )
	throw edm::Exception(errors::InvalidReference)
	  << "attempting get view from a null RefToBaseProd.\n";
      ProductID id = product_.id();
      std::vector<void const*> pointers;
      helper_vector_ptr helpers;
      product_.productGetter()->getIt(id)->fillView(id, pointers, helpers);
      viewCache_.ptr_ =( new View<T>( pointers, helpers ) );
    }
    return viewPtr();
  }

  template<typename T>
  inline
  void RefToBaseProd<T>::swap(RefToBaseProd<T> & other) {
    std::swap( product_, other.product_ );
    std::swap( viewCache_.ptr_, other.viewCache_.ptr_);
  }

  template <typename T>
  inline
  bool
  operator== (RefToBaseProd<T> const& lhs, RefToBaseProd<T> const& rhs) {
    return lhs.refCore() == rhs.refCore();
  }

  template <typename T>
  inline
  bool
  operator!= (RefToBaseProd<T> const& lhs, RefToBaseProd<T> const& rhs) {
    return !(lhs == rhs);
  }

  template <typename T>
  inline
  bool
  operator< (RefToBaseProd<T> const& lhs, RefToBaseProd<T> const& rhs) {
    return (lhs.refCore() < rhs.refCore());
  }

  template<typename T>
  inline void swap( edm::RefToBaseProd<T> const& lhs, edm::RefToBaseProd<T> const& rhs ) {
    lhs.swap( rhs );
  }
}

#include "art/Persistency/Common/FillView.h"

namespace edm {
  template <typename T>
  template <typename C>
  inline
  RefToBaseProd<T>::RefToBaseProd(const RefProd<C> & ref) :
    product_( ref.refCore() ) {
    std::vector<void const*> pointers;
    typedef typename refhelper::RefToBaseProdTrait<C>::ref_vector_type ref_vector;
    typedef reftobase::RefVectorHolder<ref_vector> holder_type;
    helper_vector_ptr helpers( new holder_type );
    detail::reallyFillView( * ref.product(), ref.id(), pointers, * helpers );
    viewCache_.ptr_=( new View<T>( pointers, helpers ) );
  }

  template <typename T>
  template <class HandleC>
  inline
  RefToBaseProd<T>::RefToBaseProd(HandleC const& handle) :
    product_(handle.id(), handle.product(), 0, false) {
    std::vector<void const*> pointers;
    typedef typename refhelper::RefToBaseProdTrait<typename HandleC::element_type>::ref_vector_type ref_vector;
    typedef reftobase::RefVectorHolder<ref_vector> holder_type;
    helper_vector_ptr helpers( new holder_type );
    detail::reallyFillView( * handle, handle.id(), pointers, * helpers );
    viewCache_.ptr_=( new View<T>( pointers, helpers ) );
  }

  /// Constructor from Ref.
  template <typename T>
  template <typename C, typename F>
  inline
  RefToBaseProd<T>::RefToBaseProd(Ref<C, T, F> const& ref) :
      product_(ref.id(),
	       ref.hasProductCache() ?  ref.product() : 0,
	       ref.productGetter(),
	       false) {
    std::vector<void const*> pointers;
    typedef typename refhelper::RefToBaseProdTrait<C>::ref_vector_type ref_vector;
    typedef reftobase::RefVectorHolder<ref_vector> holder_type;
    helper_vector_ptr helpers( new holder_type );
    detail::reallyFillView( * ref.product(), ref.id(), pointers, * helpers );
    viewCache_.ptr_=( new View<T>( pointers, helpers ) );
  }

  /// Constructor from RefToBase.
  template <typename T>
  inline
  RefToBaseProd<T>::RefToBaseProd(RefToBase<T> const& ref) :
    product_(ref.id(),
	     ref.hasProductCache() ?  ref.product() : 0,
	     ref.productGetter(),
	     false) {
    std::vector<void const*> pointers;
    helper_vector_ptr helpers( ref.holder_->makeVectorBaseHolder().release() );
    helpers->reallyFillView( ref.product(), ref.id(), pointers );
    viewCache_.ptr_=( new View<T>( pointers, helpers ) );
  }

}

#endif
