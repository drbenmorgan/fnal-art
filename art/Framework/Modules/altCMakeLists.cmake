simple_plugin(BlockingPrescaler       "module")
simple_plugin(DataFlowDumper          "module")
simple_plugin(EmptyEvent              "source")
simple_plugin(EventIDFilter           "module")
simple_plugin(FileDumperOutput        "module")
simple_plugin(Prescaler               "module")
simple_plugin(ProvenanceCheckerOutput "module")
simple_plugin(RandomNumberSaver       "module")

install(TARGETS
  art_Framework_Modules_BlockingPrescaler_module
  art_Framework_Modules_DataFlowDumper_module
  art_Framework_Modules_EmptyEvent_source
  art_Framework_Modules_EventIDFilter_module
  art_Framework_Modules_FileDumperOutput_module
  art_Framework_Modules_Prescaler_module
  art_Framework_Modules_ProvenanceCheckerOutput_module
  art_Framework_Modules_RandomNumberSaver_module
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Modules
  FILES_MATCHING PATTERN "*.h"
  )


