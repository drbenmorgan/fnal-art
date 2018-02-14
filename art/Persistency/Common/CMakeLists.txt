# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
  return()
endif()

art_make_library(
  LIBRARY_NAME
  art_Persistency_Common
  SOURCE
  DelayedReader.cc
  GroupQueryResult.cc
  LIBRARIES
  canvas
  )

install_headers()
install_source()
