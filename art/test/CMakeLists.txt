
cet_enable_asserts()

# add_definitions(-DART_NO_MIX_PTRVECTOR)

# Make sure tests have correct environment settings.
include(CetTest)
# If you explicitly include CetTest in a subdirectory, you will need to
# re-initialize the test environment.
cet_test_env("FHICL_FILE_PATH=.")

if(ALT_CMAKE)
  # Here we set up alias targets so namespaced targets can be used
  # transparently with minimal changes
  add_library(canvas INTERFACE)
  target_link_libraries(canvas INTERFACE canvas::canvas)
  add_library(cetlib INTERFACE)
  target_link_libraries(cetlib INTERFACE cetlib::cetlib)
  add_library(cetlib_except INTERFACE)
  target_link_libraries(cetlib INTERFACE cetlib_except::cetlib_except)
  add_library(fhiclcpp INTERFACE)
  target_link_libraries(fhiclcpp INTERFACE fhiclcpp::fhiclcpp)
  add_library(MF_MessageLogger INTERFACE)
  target_link_libraries(MF_MessageLogger INTERFACE messagefacility::MF_MessageLogger)
  add_library(mf_catch_main INTERFACE)
  target_link_libraries(mf_catch_main INTERFACE messagefacility::mf_catch_main)
  add_library(messagefacility_plugins_stringstream_mfPlugin INTERFACE)
  target_link_libraries(messagefacility_plugins_stringstream_mfPlugin INTERFACE messagefacility::messagefacility_plugins_stringstream_mfPlugin)

  # For third party, forward variables onto imported targets
  set(CLHEP CLHEP::CLHEP)
  # Find CppUnit here, as only required when testing.
  find_package(CppUnit REQUIRED)
  set(CPPUNIT CppUnit::CppUnit)
  set(ROOT_HIST ROOT::Hist)
  set(ROOT_GRAF ROOT::Graf)
  # Until ROOT targets supply usage requirements
  include_directories(SYSTEM ${ROOT_INCLUDE_DIRS})
  set(SQLITE3 SQLite::SQLite)
  set(TBB TBB::tbb)
  # Hack to guarantee include paths without full usage requirements
  include_directories(BEFORE ${PROJECT_SOURCE_DIR})

  # Hack to ignore install_XXX()
  macro(install_headers)
  endmacro()

  # Internal dynamic loader path.
  # Need both internal path, and that for MF for its plugins.
  cet_test_env("CETD_LIBRARY_PATH=$<TARGET_FILE_DIR:art_Framework_Art>:$<TARGET_FILE_DIR:messagefacility::MF_MessageLogger>:$ENV{CETD_LIBRARY_PATH}")

  # Ensure we find programs that are only given as names, not full paths
  cet_test_env("PATH=$<TARGET_FILE_DIR:art>:${PROJECT_SOURCE_DIR}/tools:$ENV{PATH}")
endif()

# build Persistency libraries
add_subdirectory (Framework/Art)
add_subdirectory (Framework/Core)
add_subdirectory (Framework/EventProcessor)
add_subdirectory (Framework/IO)
add_subdirectory (Framework/IO/Root)
add_subdirectory (Framework/IO/Root/RootDB)
add_subdirectory (Framework/Principal)
add_subdirectory (Framework/Services/Optional)
add_subdirectory (Framework/Services/Registry)
add_subdirectory (Framework/Services/System)
add_subdirectory (Framework/Services/Basic)
add_subdirectory (Integration)
add_subdirectory (Persistency/Provenance)
add_subdirectory (Persistency/Common)
add_subdirectory (TestObjects)
add_subdirectory (Version)
add_subdirectory (Utilities)
