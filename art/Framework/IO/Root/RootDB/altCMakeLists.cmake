add_library(art_Framework_IO_Root_RootDB SHARED
  SQLErrMsg.cc
  SQLErrMsg.h
  SQLite3Wrapper.cc
  SQLite3Wrapper.h
  TKeyVFSOpenPolicy.cc
  TKeyVFSOpenPolicy.h
  tkeyvfs.cc
  tkeyvfs.h
  )

target_include_directories(art_Framework_IO_Root_RootDB PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  # Until ROOT properly supports usage requirements
  $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>
  )

target_link_libraries(art_Framework_IO_Root_RootDB
  PUBLIC
    ROOT::RIO
    SQLite::SQLite
  PRIVATE
    canvas::canvas
    cetlib::cetlib
    messagefacility::MF_MessageLogger
    )

install(TARGETS art_Framework_IO_Root_RootDB
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
