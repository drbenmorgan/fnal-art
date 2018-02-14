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

basic_plugin(MemoryTracker "service"
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

# As with others, need to think about install
# due to complex names

