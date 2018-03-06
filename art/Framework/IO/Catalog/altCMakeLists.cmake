add_library(art_Framework_IO_Catalog SHARED
  FileCatalog.h
  InputFileCatalog.cc
  InputFileCatalog.h
  )

target_include_directories(art_Framework_IO_Catalog
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Framework_IO_Catalog
  PUBLIC
    art_Framework_Services_FileServiceInterfaces
    art_Framework_Services_Registry
    fhiclcpp::fhiclcpp
  PRIVATE
    Boost::boost
    )

install(TARGETS art_Framework_IO_Catalog
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

