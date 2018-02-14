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
target_include_directories(art_Framework_IO_Sources PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
target_link_libraries(art_Framework_IO_Sources
  PUBLIC
    art_Framework_Services_FileServiceInterfaces
    art_Framework_Services_Registry
    art_Framework_Principal
    canvas::canvas
    )
install(TARGETS art_Framework_IO_Sources
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
