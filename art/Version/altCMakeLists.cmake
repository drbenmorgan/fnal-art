# Translate to UPS-speak
set(version "${PROJECT_VERSION}")
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/GetReleaseVersion.cc.in
  ${CMAKE_CURRENT_BINARY_DIR}/GetReleaseVersion.cc @ONLY )

add_library(art_Version SHARED
  GetReleaseVersion.h
  ${CMAKE_CURRENT_BINARY_DIR}/GetReleaseVersion.cc
  )

install(TARGETS art_Version
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )
install(FILES GetReleaseVersion.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Version
  COMPONENT Development
  )
