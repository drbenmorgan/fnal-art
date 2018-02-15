# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
  return()
endif()

art_make_library(SOURCE TH1Data.cc
  LIBRARIES ${ROOT_HIST} ${ROOT_CORE}
  )

art_dictionary(DICTIONARY_LIBRARIES art_test_TestObjects)

install_headers()
