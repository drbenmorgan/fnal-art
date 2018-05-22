#ifndef art_Persistency_Provenance_ModuleContext_h
#define art_Persistency_Provenance_ModuleContext_h

#include "art/Persistency/Provenance/ModuleDescription.h"
#include "art/Persistency/Provenance/PathContext.h"

namespace art {
  class ModuleContext {
  public:
    explicit ModuleContext(PathContext const& pathContext,
                           ModuleDescription const& md)
      : pathContext_{pathContext}, md_{md}
    {}

    auto
    scheduleID() const
    {
      return pathContext_.scheduleID();
    }
    auto const&
    pathName() const
    {
      return pathContext_.pathName();
    }
    auto const&
    moduleDescription() const
    {
      return md_;
    }
    auto const&
    moduleLabel() const
    {
      return md_.moduleLabel();
    }
    auto const&
    moduleName() const
    {
      return md_.moduleName();
    }
    bool
    onEndPath() const
    {
      return pathName() == PathContext::end_path();
    }

  private:
    PathContext pathContext_;
    ModuleDescription md_;
  };
}

#endif /* art_Persistency_Provenance_ModuleContext_h */

// Local Variables:
// mode: c++
// End:
