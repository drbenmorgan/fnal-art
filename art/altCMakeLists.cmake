add_subdirectory(Version)
add_subdirectory(Utilities)
add_subdirectory(Framework)
add_subdirectory(Persistency)

if(BUILD_TESTING)
  find_package(Boost QUIET REQUIRED unit_test_framework)
  add_subdirectory(test)
endif()
