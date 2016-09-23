
art_add_service(CurrentModule CurrentModule.h CurrentModule_service.cc)
art_service_link_libraries(CurrentModule
  art_Persistency_Provenance
  canvas::canvas_Persistency_Provenance
  )
art_add_service(FileCatalogMetadata FileCatalogMetadata.h FileCatalogMetadata_service.cc)

art_add_service(FloatingPointControl FloatingPointControl.h FloatingPointControl_service.cc)

art_add_service(TriggerNamesService TriggerNamesService.h TriggerNamesService_service.cc)


#simple_plugin(PathSelection "service" art_Framework_Core)
#simple_plugin(ScheduleContext "service" art_Framework_Core)

art_install_services(SERVICES CurrentModule FileCatalogMetadata FloatingPointControl TriggerNamesService
  INSTALL
    EXPORT ${PROJECT_NAME}Targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/System
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )



