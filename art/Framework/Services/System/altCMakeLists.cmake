simple_plugin(CurrentModule "service" art_Persistency_Provenance canvas::canvas)
simple_plugin(DatabaseConnection "service")
simple_plugin(FileCatalogMetadata "service")
simple_plugin(FloatingPointControl "service"
  SOURCE FloatingPointControl_service.cc detail/fpControl.cc)
simple_plugin(ScheduleContext "service" art_Framework_Core)
simple_plugin(TriggerNamesService "service")

install(TARGETS
  art_Framework_Services_System_CurrentModule_service
  art_Framework_Services_System_DatabaseConnection_service
  art_Framework_Services_System_FileCatalogMetadata_service
  art_Framework_Services_System_FloatingPointControl_service
  art_Framework_Services_System_ScheduleContext_service
  art_Framework_Services_System_TriggerNamesService_service
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/System
  FILES_MATCHING PATTERN "*.h"
  )

