# cmake will automatically order the library builds according to declared dependencies
add_subdirectory(Version)
add_subdirectory(Utilities)
add_subdirectory(Framework)
add_subdirectory(Persistency)

# Testing
if(BUILD_TESTING)
  find_package(CppUnit REQUIRED)
  add_subdirectory(test)
endif()
