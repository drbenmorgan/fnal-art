add_subdirectory(Version)
add_subdirectory(Utilities)
add_subdirectory(Framework)
add_subdirectory(Persistency)

#-----------------------------------------------------------------------
# Create exports file(s)
include(CMakePackageConfigHelpers)

# - Common to both trees
write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  COMPATIBILITY SameMajorVersion
  )

# - Build tree (EXPORT only for now, config file needs some thought,
#   dependent on the use of multiconfig)
export(
  EXPORT ${PROJECT_NAME}Targets
  NAMESPACE ${PROJECT_NAME}::
  FILE "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake"
  )

# - Install tree
configure_package_config_file("${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in"
  "${PROJECT_BINARY_DIR}/InstallCMakeFiles/${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
  PATH_VARS CMAKE_INSTALL_INCLUDEDIR
  )

install(
  FILES
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    "${PROJECT_BINARY_DIR}/InstallCMakeFiles/${PROJECT_NAME}Config.cmake"
  DESTINATION
    "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
    )

install(
  EXPORT ${PROJECT_NAME}Targets
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
  )

#-----------------------------------------------------------------------
# Testing if required
#
if(BUILD_TESTING)
  find_package(Boost QUIET REQUIRED unit_test_framework)
  add_subdirectory(test)
endif()
