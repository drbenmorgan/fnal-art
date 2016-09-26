add_library(art_Framework_EventProcessor SHARED
  EventProcessor.cc
  EventProcessor.h
  ServiceDirector.cc
  ServiceDirector.h
  StateMachine/Events.h
  StateMachine/HandleEvents.cc
  StateMachine/HandleFiles.cc
  StateMachine/HandleRuns.cc
  StateMachine/HandleSubRuns.cc
  StateMachine/Machine.cc
  StateMachine/Machine.h
  detail/writeSummary.cc
  detail/writeSummary.h
  )

# Review list!!
target_link_libraries(art_Framework_EventProcessor PUBLIC
  art_Framework_Core
  art_Framework_Principal
  art_Framework_Services_System_CurrentModule_service
  art_Framework_Services_System_FileCatalogMetadata_service
  art_Framework_Services_System_FloatingPointControl_service
  art_Framework_Services_System_PathSelection_service
  art_Framework_Services_System_ScheduleContext_service
  art_Framework_Services_System_TriggerNamesService_service
  art_Persistency_Provenance
  art_Utilities
  canvas::canvas_Utilities
  cetlib::cetlib
  )

install(TARGETS art_Framework_EventProcessor
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/EventProcessor
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

