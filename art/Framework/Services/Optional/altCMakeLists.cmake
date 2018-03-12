# Because ROOT does not declare usage requirements fully yet
include_directories(SYSTEM ${ROOT_INCLUDE_DIRS})

add_library(art_Framework_Services_Optional SHARED
  TFileDirectory.h
  TFileDirectory.cc
  detail/RootDirectorySentry.h
  detail/RootDirectorySentry.cc
  )
target_include_directories(art_Framework_Services_Optional PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
# Many more links below, not clear if set for
# interface reasons.
target_link_libraries(art_Framework_Services_Optional
  PUBLIC
    ROOT::RIO
    ROOT::Hist
  PRIVATE
    canvas::canvas
    cetlib::cetlib
  )

#-----------------------------------------------------------------------
# Plugins
#
simple_plugin(RandomNumberGenerator "service"
  art_Framework_Principal
  art_Persistency_Common
  messagefacility::MF_MessageLogger
  cetlib::cetlib
  CLHEP::CLHEP
 )

simple_plugin(MemoryAdjuster "service" art_Framework_Services_Optional)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(MemoryTrackerSource MemoryTrackerLinux_service.cc)
else()
  set(MemoryTrackerSource MemoryTrackerDarwin_service.cc)
endif()

simple_plugin(MemoryTracker "service"
  art_Framework_Services_Optional
  canvas::canvas
  cetlib::cetlib
  SQLite::SQLite
  SOURCE ${MemoryTrackerSource})

simple_plugin(TFileService "service"
  art_Framework_Services_System_TriggerNamesService_service
  art_Framework_Services_Optional
  art_Framework_IO
  art_Framework_IO_detail
  art_Framework_Principal
  ROOT::RIO
  )

simple_plugin(TimeTracker "service"
  art_Framework_Principal
  canvas::canvas
  cetlib::cetlib
  )
# ${TBB}
# ${RT}
# ${SQLITE3})

simple_plugin(Tracer "service" canvas::canvas)
simple_plugin(TrivialFileDelivery "service")
simple_plugin(TrivialFileTransfer "service")

install(TARGETS
  art_Framework_Services_Optional
  art_Framework_Services_Optional_RandomNumberGenerator_service
  art_Framework_Services_Optional_MemoryAdjuster_service
  art_Framework_Services_Optional_MemoryTracker_service
  art_Framework_Services_Optional_TFileService_service
  art_Framework_Services_Optional_TimeTracker_service
  art_Framework_Services_Optional_Tracer_service
  art_Framework_Services_Optional_TrivialFileDelivery_service
  art_Framework_Services_Optional_TrivialFileTransfer_service
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/Optional
  FILES_MATCHING PATTERN "*.h"
  )

