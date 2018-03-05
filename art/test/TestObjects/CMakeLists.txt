# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
add_library(art_test_TestObjects SHARED TH1Data.cc)
target_include_directories(art_test_TestObjects PUBLIC ${PROJECT_SOURCE_DIR} ${ROOT_INCLUDE_DIRS})
target_link_libraries(art_test_TestObjects PUBLIC ${ROOT_HIST} ${ROOT_CORE})
else()
art_make_library(SOURCE TH1Data.cc
  LIBRARIES ${ROOT_HIST} ${ROOT_CORE}
  )
endif()

art_dictionary(DICTIONARY_LIBRARIES art_test_TestObjects)

install_headers()
