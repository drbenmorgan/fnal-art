set(art_Framework_Services_Registry_sources
  ActivityRegistry.h
  BranchActionType.h
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
  detail/ServiceHelper.h
  detail/ServiceStack.h
  detail/ServiceWrapper.h
  detail/ServiceWrapperBase.h
  detail/SignalResponseType.h
  detail/helper_macros.h
  detail/makeWatchFunc.h
  )

add_library(art_Framework_Services_Registry SHARED ${art_Framework_Services_Registry_sources})

# - Review these links for actual direct deps
target_link_libraries(art_Framework_Services_Registry PUBLIC
  art_Utilities
  ${TBB_LIBRARY_RELEASE}
  canvas::canvas_Utilities
  )

install(TARGETS art_Framework_Services_Registry
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/Registry
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

