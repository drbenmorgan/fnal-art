# - Toplevel CMake script for fnal::art
cmake_minimum_required(VERSION 3.3)
project(art VERSION 2.10.1)

# - Cetbuildtools, version2
find_package(cetbuildtools2 0.1.0 REQUIRED)
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
find_package(canvas 1.0.6 REQUIRED)
find_package(messagefacility REQUIRED)
find_package(fhiclcpp REQUIRED)
find_package(cetlib REQUIRED)
find_package(cetlib_except 1.1.0 REQUIRED)
find_package(CLHEP REQUIRED)
find_package(SQLite REQUIRED)
#find_ups_product(range)
find_package(TBB REQUIRED)
find_package(Boost REQUIRED)
find_package(ROOT REQUIRED)

# find_package(CPPUNIT REQUIRED ... for testing ...)

# macros for art_dictionary and simple_plugin
#include(ArtDictionary)
#include(BuildPlugins)

#if (NOT APPLE)
#  set(RT -lrt)
#endif()

# Plugin skeleton generators for cetskelgen.
#add_subdirectory(perllib)

# tools
#add_subdirectory(tools)

# source
add_subdirectory(art)

# ups - table and config files
#add_subdirectory(ups)

# CMake modules
#add_subdirectory(Modules)

# packaging utility
#include(UseCPack)
