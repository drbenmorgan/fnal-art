add_library(art_test_TestObjects SHARED TH1Data.cc)
target_include_directories(art_test_TestObjects PUBLIC ${PROJECT_SOURCE_DIR} ${ROOT_INCLUDE_DIRS})
target_link_libraries(art_test_TestObjects PUBLIC ROOT::Hist ROOT::Core)

art_dictionary(DICTIONARY_LIBRARIES art_test_TestObjects)

