# simple_plugin(RNGS_analyzer  "module" NO_INSTALL )
# simple_plugin(RNGS_producer  "module" NO_INSTALL )

art_add_module(TestTFileServiceAnalyzer TestTFileServiceAnalyzer_module.cc)
art_module_link_libraries(TestTFileServiceAnalyzer
  art_Framework_Services_Optional_TFileService_service
  ${ROOT_Hist_LIBRARY}
  ${ROOT_Graf_LIBRARY}
  )

art_add_module(UnitTestClient UnitTestClient_module.cc)

cet_test(UnitTestClient HANDBUILT
  TEST_EXEC $<TARGET_FILE:art>
  TEST_ARGS --rethrow-all --config test_fpc.fcl
  DATAFILES
  fcl/test_fpc.fcl
  # fcl/messageDefaults.fcl
  )

