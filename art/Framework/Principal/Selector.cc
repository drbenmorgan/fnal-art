#include "art/Framework/Principal/Selector.h"
// vim: set sw=2 expandtab :

namespace art {

  Selector::Selector(Selector const& other) : sel_(other.sel_->clone()) {}

  Selector&
  Selector::operator=(Selector const& other) &
  {
    Selector temp(other);
    swap(temp);
    return *this;
  }

  void
  Selector::swap(Selector& other)
  {
    using std::swap;
    swap(sel_, other.sel_);
  }

  Selector::~Selector() = default;

  Selector*
  Selector::clone() const
  {
    return new Selector{*this};
  }

  bool
  Selector::doMatch(BranchDescription const& prov) const
  {
    return sel_->match(prov);
  }

} // namespace art
