#ifndef art_Framework_Services_Registry_ServiceScope_h
#define art_Framework_Services_Registry_ServiceScope_h
// vim: set sw=2 expandtab :

namespace art {

  enum class ServiceScope {
    LEGACY // 0
    ,
    SHARED // 1
    ,
    PER_SCHEDULE // 2
  };

} // namespace art

#endif /* art_Framework_Services_Registry_ServiceScope_h */

// Local Variables:
// mode: c++
// End:
