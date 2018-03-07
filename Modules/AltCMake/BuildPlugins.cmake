#.rst:
# (Art)BuildPlugins
# -----------------
#
# macros for building art plugins
#
# The plugin type is expected to be service, source, or module, but we
# do not enforce this in order to allow for user- or experiment-defined
# plugins.
#
# USAGE:
#
# simple_plugin( <name> <plugin type> [<basic_plugin options>]
#                [[NOP] <library list>] )
#
# Options:
#
# NOP
#
#    Dummy option for the purpose of separating (say) multi-option
#    arguments from non-option arguments.
#
# For other available options, please see
# cetbuildtools/Modules/BasicPlugin.cmake
# (https://cdcvs.fnal.gov/redmine/projects/cetbuildtools/repository/revisions/master/entry/Modules/BasicPlugin.cmake).
#

# From cetbuildtools2
include(BasicPlugin)

cmake_policy(PUSH)
cmake_policy(VERSION 3.3)

# When running in a build of Art, targets are not namespaced.
# When used in client applications, they are.
# Account for difference by checking for existence of
# imported namespaced targets, and setting namespace
# variable.
if(TARGET art::art_Framework_Core)
  set(_BP_ART_NAMESPACE "art::")
endif()


# Wrapper over cetbuildtools2's basic_plugin to add
# art specific types and linkage
#
function(simple_plugin name type)
  cmake_parse_arguments(SP "NOP" "" "SOURCE" ${ARGN})
  if(NOT simple_plugin_liblist)
    set(simple_plugin_liblist)
  endif()
  if("${type}" STREQUAL "service")
    list(INSERT simple_plugin_liblist 0
      ${_BP_ART_NAMESPACE}art_Framework_Services_Registry
      ${_BP_ART_NAMESPACE}art_Persistency_Common
      ${_BP_ART_NAMESPACE}art_Utilities
      canvas::canvas
      fhiclcpp::fhiclcpp
      cetlib::cetlib
      cetlib_except::cetlib_except
      Boost::filesystem
      Boost::system
      )
  elseif("${type}" STREQUAL "module" OR "${type}" STREQUAL "source")
    list(INSERT simple_plugin_liblist 0
      ${_BP_ART_NAMESPACE}art_Framework_Core
      ${_BP_ART_NAMESPACE}art_Framework_Principal
      ${_BP_ART_NAMESPACE}art_Persistency_Common
      ${_BP_ART_NAMESPACE}art_Persistency_Provenance
      ${_BP_ART_NAMESPACE}art_Utilities
      canvas::canvas
      fhiclcpp::fhiclcpp
      cetlib::cetlib
      cetlib_except::cetlib_except
      ROOT::Core
      Boost::filesystem
      Boost::system
      )
  elseif("${type}" STREQUAL "tool")
    list(INSERT simple_plugin_liblist 0
      ${_BP_ART_NAMESPACE}art_Utilities
      fhiclcpp::fhiclcpp
      cetlib::cetlib
      cetlib_except::cetlib_except
      Boost::filesystem
      Boost::system
      )
  endif()

  # Source type also requires the IO_Sources subcomponent
  if ("${type}" STREQUAL "source")
    list(INSERT simple_plugin_liblist 0
      ${_BP_ART_NAMESPACE}art_Framework_IO_Sources
      )
  endif()

  # Forward to basic_plugin
  basic_plugin(${name} ${type} ${NOP_ARG} ${simple_plugin_liblist} ${ARGN} ${SP_SOURCE})
endfunction()

cmake_policy(POP)
