# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
  return()
endif()

art_make(SUBDIRS detail
  LIB_LIBRARIES
  art_Utilities
  canvas
  ${TBB}
  )

install_headers(SUBDIRS detail)
install_source(SUBDIRS detail)
