# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
  return()
endif()

art_make_library(
  LIBRARY_NAME
  art_Framework_IO_Root_RootDB
  SOURCE
  SQLErrMsg.cc
  SQLite3Wrapper.cc
  TKeyVFSOpenPolicy.cc
  tkeyvfs.cc
  LIBRARIES
  art_Utilities
  canvas
  ${ROOT_RIO}
  ${ROOT_CORE}
  ${SQLITE3}
  )

install_headers()
install_source()
