add_library(art_Framework_IO_Catalog SHARED
  FileCatalog.h
  InputFileCatalog.cc
  InputFileCatalog.h
  )

target_link_libraries(art_Framework_IO_Catalog PUBLIC
  art_Framework_Services_Optional_TrivialFileDelivery_service
  art_Framework_Services_Optional_TrivialFileTransfer_service
  art_Utilities
  canvas::canvas_Utilities
  Boost::filesystem
  )

install(TARGETS art_Framework_IO_Catalog
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )



