set(art_Framework_EventProcessor_sources
  EventProcessor.cc
  EventProcessor.h
  ServiceDirector.cc
  ServiceDirector.h
  detail/ExceptionCollector.cc
  detail/ExceptionCollector.h
  detail/memoryReport.h
  detail/writeSummary.cc
  detail/writeSummary.h
  )

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  list(APPEND art_Framework_EventProcessor_sources detail/memoryReportLinux.cc)
else()
  list(APPEND art_Framework_EventProcessor_sources detail/memoryReportDarwin.cc)
endif()

add_library(art_Framework_EventProcessor SHARED ${art_Framework_EventProcessor_sources})

target_include_directories(art_Framework_EventProcessor PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Framework_EventProcessor
  PUBLIC
    art_Framework_Core
    art_Framework_Principal
    art_Framework_Services_Registry
    art_Utilities
    canvas::canvas
    cetlib::cetlib
    fhiclcpp::fhiclcpp
    messagefacility::MF_MessageLogger
    TBB::tbb
  PRIVATE
    art_Version
    art_Framework_Services_System_CurrentModule_service
    art_Framework_Services_System_FileCatalogMetadata_service
    art_Framework_Services_System_FloatingPointControl_service
    art_Framework_Services_System_ScheduleContext_service
    art_Framework_Services_System_TriggerNamesService_service
   )

install(TARGETS art_Framework_EventProcessor
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/EventProcessor
  FILES_MATCHING PATTERN "*.h"
  )


