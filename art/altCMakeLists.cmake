# cmake will automatically order the library builds according to declared dependencies
add_subdirectory(Version)
add_subdirectory(Utilities)
#add_subdirectory(Framework)
add_subdirectory(Persistency)

# Testing
#if(BUILD_TESTING)
#  find_package(Boost REQUIRED unit_test_framework)
#  add_subdirectory(test)
#endif()
