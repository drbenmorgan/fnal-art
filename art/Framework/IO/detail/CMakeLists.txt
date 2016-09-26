# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
else()

art_make_library(
  LIBRARY_NAME art_Framework_IO_detail
  SOURCE logFileAction.cc
  LIBRARIES MF_MessageLogger
  )

install_headers()
install_source()

endif() # ALT_CMAKE
