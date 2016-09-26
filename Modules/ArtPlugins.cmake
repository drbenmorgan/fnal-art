#.rst:
# ArtPlugins
# ----------
#
# CMake functions for declaring, working with and installing Art plugins.
# In Art, plugins may be extensions to:
#
# * Services
# * Module
# * Source
#
# Basically a set of functions to allow easy working with plugin
# names via basename aliases. CET/Art's convention for library/plugin
# naming is complex for end users, so try and hide this until a more
# logical structure is implemented (e.g. Qt-style subdirectories for
# plugins). Retain CMake style of functions to improve usability:
#
# * declaration ala add_library
# * dependencies/usage ala target_{link_libraries,include_directories,etc}
# * install ala install(TARGETS ...)
#

#-----------------------------------------------------------------------
# Copyright (c) 2016, Ben Morgan <Ben.Morgan@warwick.ac.uk>
#
# Distributed under the OSI-approved BSD 3-Clause License (the "License");
# see accompanying file License.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
#.rst:
# create a CET/Art style target name derived from subdirectory structure...
function(art_make_target_name _basename _output)
  string(REPLACE "${PROJECT_SOURCE_DIR}" "" __submodule "${CMAKE_CURRENT_LIST_DIR}")
  string(REPLACE "/" "_" __submodule "${__submodule}")
  string(REGEX REPLACE "^_+" "" __submodule "${__submodule}")
  # NB: ASSUMES that code is organized in a directory structure
  # +- PROJECT_SOURCE_DIR/
  #    +- PROJECT_NAME/
  #       +- ...submodules...
  set(${_output} "${__submodule}_${_basename}" PARENT_SCOPE)
endfunction()

#-----------------------------------------------------------------------
#.rst:
# declare a service
function(art_add_service _name)
  art_make_target_name(${_name} _basename)
  add_library(${_basename}_service SHARED ${ARGN})
  # Review:
  # 1: link list - what does a service *by default* need to link to?
  # 2: Namespacing so clients of art can use this with correct target names
  target_link_libraries(${_basename}_service PUBLIC art_Framework_Services_Registry)
endfunction()

#-----------------------------------------------------------------------
#.rst:
# link a service to dependencies
function(art_service_link_libraries _name)
  art_make_target_name(${_name} _basename)
  target_link_libraries(${_basename}_service PUBLIC ${ARGN})
endfunction()

#-----------------------------------------------------------------------
#.rst:
# install services
function(art_install_services)
  cmake_parse_arguments(AIS
    ""
    ""
    "SERVICES;INSTALL"
    ${ARGN}
    )
  set(AIS_TARGETS_ACTUAL)
  foreach(_service ${AIS_SERVICES})
    art_make_target_name(${_service} _basename)
    list(APPEND AIS_TARGETS_ACTUAL ${_basename}_service)
  endforeach()

  install(TARGETS ${AIS_TARGETS_ACTUAL} ${AIS_INSTALL})
endfunction()

#-----------------------------------------------------------------------
# "Module"
#-----------------------------------------------------------------------
#.rst:
# declare a module
function(art_add_module _name)
  art_make_target_name(${_name} _basename)
  add_library(${_basename}_module SHARED ${ARGN})
  # Review:
  # 1: link list - what does a module *by default* need to link to?
  # 2: Namespacing so clients of art can use this with correct target names
  target_link_libraries(${_basename}_module PUBLIC art_Framework_Core)
endfunction()

#-----------------------------------------------------------------------
#.rst:
# link a module to dependencies
function(art_module_link_libraries _name)
  art_make_target_name(${_name} _basename)
  target_link_libraries(${_basename}_module PUBLIC ${ARGN})
endfunction()

#-----------------------------------------------------------------------
#.rst:
# install modules
function(art_install_modules)
  cmake_parse_arguments(AIM
    ""
    ""
    "MODULES;INSTALL"
    ${ARGN}
    )
  set(AIM_TARGETS_ACTUAL)
  foreach(_module ${AIM_MODULES})
    art_make_target_name(${_module} _basename)
    list(APPEND AIM_TARGETS_ACTUAL ${_basename}_module)
  endforeach()

  install(TARGETS ${AIM_TARGETS_ACTUAL} ${AIM_INSTALL})
endfunction()

#-----------------------------------------------------------------------
# "Source" plugins
#-----------------------------------------------------------------------
#.rst:
# declare a source
function(art_add_source _name)
  art_make_target_name(${_name} _basename)
  add_library(${_basename}_source SHARED ${ARGN})
  # Review:
  # 1: link list - what does a source *by default* need to link to?
  # 2: Namespacing so clients of art can use this with correct target names
  target_link_libraries(${_basename}_source PUBLIC art_Framework_IO_Sources)
endfunction()

#-----------------------------------------------------------------------
#.rst:
# link a source to dependencies
function(art_source_link_libraries _name)
  art_make_target_name(${_name} _basename)
  target_link_libraries(${_basename}_source PUBLIC ${ARGN})
endfunction()

#-----------------------------------------------------------------------
#.rst:
# install sources
function(art_install_sources)
  cmake_parse_arguments(AIM
    ""
    ""
    "SOURCES;INSTALL"
    ${ARGN}
    )
  set(AIM_TARGETS_ACTUAL)
  foreach(_source ${AIM_SOURCES})
    art_make_target_name(${_source} _basename)
    list(APPEND AIM_TARGETS_ACTUAL ${_basename}_source)
  endforeach()

  install(TARGETS ${AIM_TARGETS_ACTUAL} ${AIM_INSTALL})
endfunction()





