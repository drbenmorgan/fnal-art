# - Canvas top level build
# Project setup
cmake_minimum_required(VERSION 3.3.0)
project(art VERSION 2.4.0)

# CMAKE_MODULE_PATH not picked up from the environemnt?
list(INSERT CMAKE_MODULE_PATH 0 $ENV{CMAKE_MODULE_PATH})


# - Cetbuildtools, version2
find_package(cetbuildtools2 0.1.0 REQUIRED)
list(INSERT CMAKE_MODULE_PATH 0 ${cetbuildtools2_MODULE_PATH})
include(CetInstallDirs)
include(CetCMakeSettings)
include(CetCompilerSettings)
include(CetTest)

# C++ Standard Config
set(CMAKE_CXX_EXTENSIONS OFF)
# Canvas lib builds don't use compile features yet.
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(canvas_COMPILE_FEATURES
  cxx_auto_type
  cxx_generic_lambdas
  )

# - Our our modules
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_LIST_DIR}/Modules)

#-----------------------------------------------------------------------
# Needed direct dependencies
# Art does not appear to specify versions
find_package(canvas REQUIRED)
find_package(messagefacility REQUIRED)
find_package(fhiclcpp REQUIRED)
find_package(cetlib REQUIRED)
find_package(TBB REQUIRED)
find_package(CLHEP REQUIRED)
find_package(ROOT 6 REQUIRED)
find_package(Boost REQUIRED filesystem system thread)
find_package(SQLite REQUIRED)
# - Defer CPPUnit to tests

#-----------------------------------------------------------------------
# Core global build settings
# - Everything uses "art/.." inc dirs
include_directories(${PROJECT_SOURCE_DIR})
include_directories(${PROJECT_BINARY_DIR})

#-----------------------------------------------------------------------
# Subdirectories of build
#
# Plugin skeleton generators for cetskelgen.
#add_subdirectory(perllib)

# tools
#add_subdirectory(tools)

# source
add_subdirectory (art)

# ups - table and config files
#add_subdirectory(ups)

# CMake modules
#add_subdirectory(Modules)

# packaging utility
#include(UseCPack)

