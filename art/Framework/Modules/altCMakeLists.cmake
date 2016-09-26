art_add_module(BlockingPrescaler BlockingPrescaler_module.cc)
art_add_module(FileDumperOutput FileDumperOutput_module.cc)
art_add_module(Prescaler Prescaler_module.cc)
art_add_module(ProvenanceCheckerOutput ProvenanceCheckerOutput_module.cc)
art_add_module(RandomNumberSaver RandomNumberSaver_module.cc)

art_install_modules(MODULES
  BlockingPrescaler
  FileDumperOutput
  Prescaler
  ProvenanceCheckerOutput
  RandomNumberSaver
  INSTALL
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

art_add_source(EmptyEvent EmptyEvent_source.cc)
art_install_sources(SOURCES
  EmptyEvent
  INSTALL
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Modules
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )


