add_library(art_Framework_Services_Registry SHARED
  ActivityRegistry.h
  GlobalSignal.h
  LocalSignal.h
  ServiceHandle.h
  ServiceMacros.h
  ServiceRegistry.cc
  ServiceRegistry.h
  ServiceScope.h
  ServiceTable.h
  ServiceToken.h
  ServicesManager.cc
  ServicesManager.h
  detail/ServiceCache.h
  detail/ServiceCacheEntry.cc
  detail/ServiceCacheEntry.h
  detail/ServiceHandleAllowed.h
  detail/ServiceHelper.h
  detail/ServiceStack.h
  detail/ServiceWrapper.h
  detail/ServiceWrapperBase.h
  detail/SignalResponseType.h
  detail/helper_macros.h
  detail/makeWatchFunc.h
  )

target_include_directories(art_Framework_Services_Registry PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Framework_Services_Registry
  PUBLIC
    art_Utilities
    canvas::canvas
    cetlib::cetlib
    fhiclcpp::fhiclcpp
  PRIVATE
    Boost::thread
  )

install(TARGETS art_Framework_Services_Registry
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/Registry
  FILES_MATCHING PATTERN "*.h"
  )

