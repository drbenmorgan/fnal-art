add_library(art_Framework_IO_detail SHARED
  logFileAction.cc
  logFileAction.h
  )

target_link_libraries(art_Framework_IO_detail PUBLIC
  messagefacility::MF_MessageLogger
  )

install(TARGETS art_Framework_IO_detail
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

