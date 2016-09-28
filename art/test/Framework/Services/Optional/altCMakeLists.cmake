cet_test_env("PATH=$<TARGET_FILE_DIR:art>:$ENV{PATH}")

add_subdirectory( detail )

art_add_service(MyService MyService_service.cc)

art_add_service(MyServiceUsingIface MyServiceUsingIface_service.cc)
art_service_link_libraries(MyServiceUsingIface PUBLIC
  art_Framework_Services_Optional_TrivialFileDelivery_service
  )

art_add_module(MyServiceUser MyServiceUser_module.cc)

cet_test(MyService_t HANDBUILT
  TEST_EXEC art
  TEST_ARGS -c MyService_t.fcl
  DATAFILES fcl/MyService_t.fcl
  )

cet_test(MyServiceUsingIface_t HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all -c MyServiceUsingIface_t.fcl
  DATAFILES fcl/MyServiceUsingIface_t.fcl
  )

art_add_service(PSTest PSTest_service.cc)
art_add_module(PSTestAnalyzer PSTestAnalyzer_module.cc)
art_module_link_libraries(PSTestAnalyzer PUBLIC
  art_test_Framework_Services_Optional_PSTest_service
  )

art_add_service(PSTestInterfaceImpl PSTestInterfaceImpl_service.cc)

cet_test(PSTest_t HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all -c PSTest_t.fcl
  DATAFILES fcl/PSTest_t.fcl
  )
