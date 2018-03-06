# - Toplevel CMake script for fnal::art
cmake_minimum_required(VERSION 3.3)
project(art VERSION 2.10.1)
# Normalize version to UPS style
set(version "${PROJECT_VERSION}")
string(REPLACE "." "_" version "${version}")

# - Cetbuildtools, version2
find_package(cetbuildtools2 0.5.0 REQUIRED)
set(CMAKE_MODULE_PATH ${cetbuildtools2_MODULE_PATH})
set(CET_COMPILER_CXX_STANDARD_MINIMUM 14)
include(CetInstallDirs)
include(CetCMakeSettings)
include(CetCompilerSettings)

# Our modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/Modules/AltCMake)

#-----------------------------------------------------------------------
# Dependencies
find_package(canvas_root_io 1.4.2 REQUIRED)
find_package(canvas REQUIRED)
find_package(messagefacility REQUIRED)
find_package(fhiclcpp REQUIRED)
find_package(cetlib REQUIRED)
find_package(cetlib_except 1.1.0 REQUIRED)
# Must specify directly used components
find_package(Boost REQUIRED date_time filesystem system thread)
find_package(CLHEP REQUIRED)
# Art doesn't appear to use range-v3 directly, at least
# via #inclusion search (yet). Canvas use will forward on
# use if using it through that interface.
#find_ups_product(range)
find_package(ROOT REQUIRED)
find_package(SQLite REQUIRED)
find_package(TBB REQUIRED)

# macros for art_dictionary and simple_plugin
include(ArtDictionary)
include(BuildPlugins)

# TODO (check usage on Linux)
#if (NOT APPLE)
#  set(RT -lrt)
#endif()

# TODO
# Plugin skeleton generators for cetskelgen.
#add_subdirectory(perllib)

# TODO: Review which are needed at install time
#       and are they bin/libexec or something else
# tools
#add_subdirectory(tools)

# source
add_subdirectory(art)

# TODO: Compatibility
# ups - table and config files
#add_subdirectory(ups)

# CMake modules
add_subdirectory(Modules/AltCMake)

# TODO
# packaging utility
#include(UseCPack)
