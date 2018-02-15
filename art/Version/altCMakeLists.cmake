add_library(art_Version SHARED GetReleaseVersion.h ${CMAKE_CURRENT_BINARY_DIR}/GetReleaseVersion.cc)
target_include_directories(art_Version PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

install(TARGETS art_Version
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(FILES GetReleaseVersion.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Version
  )

