add_library(art_Framework_IO_Sources SHARED
  Source.h
  SourceHelper.cc
  SourceHelper.h
  SourceTraits.h
  put_product_in_principal.h
  detail/FileNamesHandler.h
  detail/FileServiceProxy.cc
  detail/FileServiceProxy.h
  )

target_link_libraries(art_Framework_IO_Sources PUBLIC
  art_Framework_Services_FileServiceInterfaces
  art_Framework_Services_Registry
  art_Framework_Principal
  art_Persistency_Common
  art_Persistency_Provenance
  art_Utilities
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  )

install(TARGETS art_Framework_IO_Sources
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

