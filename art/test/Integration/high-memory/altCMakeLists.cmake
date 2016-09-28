# Tests to expose certain instances of high memory use.

art_dictionary(NO_INSTALL)

art_add_module(HMSubRunProdProducer HMSubRunProdProducer_module.cc)
art_add_module(HMRunProdProducer HMRunProdProducer_module.cc)
art_add_module(TestRemoveCachedProduct TestRemoveCachedProduct_module.cc)
set_boost_unit_properties(art_test_Integration_high-memory_TestRemoveCachedProduct_module)

cet_test(HMSubRun_w HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all --config HMSubRun_w.fcl
  DATAFILES fcl/HMSubRun_w.fcl
  OPTIONAL_GROUPS LONG
)

cet_test(HMSubRun_r HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all --config HMSubRun_r.fcl
  DATAFILES fcl/HMSubRun_r.fcl
  OPTIONAL_GROUPS LONG
  TEST_PROPERTIES DEPENDS HMSubRun_w
)

cet_test(TestRemoveCachedProduct_w HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all --config TestRemoveCachedProduct_w.fcl
  DATAFILES fcl/TestRemoveCachedProduct_w.fcl
)

cet_test(TestRemoveCachedProduct_r HANDBUILT
  TEST_EXEC art_ut
  TEST_ARGS -- --rethrow-all --config TestRemoveCachedProduct_r.fcl
  DATAFILES fcl/TestRemoveCachedProduct_r.fcl
  TEST_PROPERTIES DEPENDS TestRemoveCachedProduct_w
)
