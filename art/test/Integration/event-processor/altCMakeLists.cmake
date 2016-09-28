art_add_module(ThrowingAnalyzer ThrowingAnalyzer_module.cc)
art_add_module(ThrowingProducer ThrowingProducer_module.cc)
art_add_source(DoNothingInput   DoNothingInput_source.cc)

cet_test( EP_throwing_01_t HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all -c test_01.fcl
  DATAFILES
  fcl/test_01.fcl
  )

foreach(num RANGE 2 4)
  cet_test( EP_throwing_0${num}_t HANDBUILT
    TEST_EXEC art
    TEST_ARGS --rethrow-all -c test_0${num}.fcl
    DATAFILES
    fcl/test_0${num}.fcl
    TEST_PROPERTIES
    PASS_REGULAR_EXPRESSION "Throwing.*ctor"
    )
endforeach()
