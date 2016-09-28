#-----------------------------------------------------------------------
# Core library
add_library(art_Framework_Services_Optional SHARED
  TFileDirectory.h
  TFileDirectory.cc
  detail/TH1AddDirectorySentry.h
  detail/TH1AddDirectorySentry.cc
  )
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  # Check list of headers (Needed for IDE listing)
  target_sources(art_Framework_Services_Optional PRIVATE
    MemoryTrackerLinux.h
    MemoryTrackerLinux.cc
    SimpleMemoryCheckLinux.h
    SimpleMemoryCheckLinux.cc
    detail/LinuxProcData.h
    detail/LinuxProcMgr.h
    detail/LinuxProcMgr.cc
    )
endif()

# Review link list!!
target_link_libraries(art_Framework_Services_Optional PUBLIC
  cetlib::cetlib
  ${ROOT_Hist_LIBRARY}
  ${ROOT_RIO_LIBRARY}
  ${ROOT_Core_LIBRARY}
  art_Framework_Services_Registry
  art_Persistency_Provenance
  art_Utilities
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  )

#-----------------------------------------------------------------------
# Plugins
art_add_service(RandomNumberGenerator RandomNumberGenerator.h RandomNumberGenerator_service.cc)
art_service_link_libraries(RandomNumberGenerator
  art_Framework_Principal
  art_Persistency_Common
  messagefacility::MF_MessageLogger
  fhiclcpp::fhiclcpp
  cetlib::cetlib
  CLHEP::CLHEP
  )

art_add_service(SimpleInteraction SimpleInteraction.h SimpleInteraction_service.cc)
art_service_link_libraries(SimpleInteraction art_Framework_Services_UserInteraction)

art_add_service(SimpleMemoryCheck SimpleMemoryCheck.h SimpleMemoryCheck_service.cc)
art_service_link_libraries(SimpleMemoryCheck
  art_Framework_Services_Optional
  canvas::canvas_Persistency_Provenance
  )

art_add_service(MemoryAdjuster MemoryAdjuster_service.cc)
art_service_link_libraries(MemoryAdjuster
  art_Framework_Services_Optional
  )

art_add_service(MemoryTracker MemoryTracker.h MemoryTracker_service.cc)
art_service_link_libraries(MemoryTracker art_Framework_Services_Optional)

# TODO (needs art_Framework_IO)
art_add_service(TFileService TFileService.h TFileService_service.cc)
art_service_link_libraries(TFileService
  art_Framework_Services_System_TriggerNamesService_service
  art_Framework_Services_Optional
  art_Framework_IO
  art_Framework_Principal
  ${ROOT_RIO_LIBRARY}
  ${ROOT_Thread_LIBRARY}
  )

art_add_service(Timing Timing_service.cc)
art_service_link_libraries(Timing
  art_Persistency_Provenance
  canvas::canvas_Persistency_Provenance
  )

art_add_service(TimeTracker TimeTracker.h TimeTracker_service.cc)
art_service_link_libraries(TimeTracker
  art_Persistency_Provenance
  canvas::canvas_Persistency_Provenance
  cetlib::cetlib
  ${TBB_LIBRARIES}
  )
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  art_service_link_libraries(TimeTracker rt)
endif()

art_add_service(Tracer Tracer_service.cc)
art_service_link_libraries(Tracer
  canvas::canvas_Persistency_Provenance
  )

art_add_service(TrivialFileDelivery TrivialFileDelivery.h TrivialFileDelivery_service.cc)
art_add_service(TrivialFileTransfer TrivialFileTransfer.h TrivialFileTransfer_service.cc)


install(TARGETS art_Framework_Services_Optional
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

art_install_services(SERVICES
  RandomNumberGenerator
  SimpleMemoryCheck
  MemoryAdjuster
  MemoryTracker
  SimpleInteraction
  TFileService
  Timing
  TimeTracker
  Tracer
  TrivialFileDelivery
  TrivialFileTransfer
  INSTALL
    EXPORT ${PROJECT_NAME}Targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/Optional
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )


