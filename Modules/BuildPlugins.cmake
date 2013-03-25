# macros for building plugin libraries
#
# The plugin type is expected to be service, source, or module,
# but we do not enforce this.
#
# USAGE:
# simple_plugin( <name> <plugin type>
#                [library list]
#                [ALLOW_UNDERSCORES]
#                [NO_INSTALL] )
#        the base plugin name is derived from the current source code subdirectory
#        specify NO_INSTALL when building a plugin for the tests

# simple plugin libraries
include(CetParseArgs)
macro (simple_plugin name type)
  cet_parse_args(SP "" "USE_BOOST_UNIT;ALLOW_UNDERSCORES;NO_INSTALL;NOINSTALL" ${ARGN})
  if (NOINSTALL)
    message(SEND_ERROR "simple_plugin now requires NO_INSTALL instead of NOINSTALL")
  endif()
  #message( STATUS "simple_plugin: PACKAGE_TOP_DIRECTORY is ${PACKAGE_TOP_DIRECTORY}")
  # base name on current subdirectory
  if( PACKAGE_TOP_DIRECTORY )
     STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  else()
     STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  if( NOT SP_ALLOW_UNDERSCORES )
    string(REGEX MATCH [_] has_underscore "${CURRENT_SUBDIR}")
    if( has_underscore )
      message(SEND_ERROR  "found underscore in plugin subdirectory: ${CURRENT_SUBDIR}" )
    endif( has_underscore )
    string(REGEX MATCH [_] has_underscore "${name}")
    if( has_underscore )
      message(SEND_ERROR  "found underscore in plugin name: ${name}" )
    endif( has_underscore )
  endif()
  STRING( REGEX REPLACE "/" "_" plugname "${CURRENT_SUBDIR}" )
  set(plugin_name "${plugname}_${name}_${type}")
  set(codename "${name}_${type}.cc")
  #message(STATUS "SIMPLE_PLUGIN: generating ${plugin_name}")
  add_library(${plugin_name} SHARED ${codename} )
  set(simple_plugin_liblist "${SP_DEFAULT_ARGS}")
  if(SP_USE_BOOST_UNIT)
    set_target_properties(${plugin_name}
      PROPERTIES
      COMPILE_DEFINITIONS BOOST_TEST_DYN_LINK
      COMPILE_FLAGS -Wno-overloaded-virtual
      )
    list(INSERT simple_plugin_liblist 0 ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
  endif()
  if(ART_FRAMEWORK_CORE)
    # using art as a product
    if("${type}" STREQUAL "service")
      list(INSERT simple_plugin_liblist 0 ${ART_FRAMEWORK_SERVICES_REGISTRY} ${SIGC})
    elseif("${type}" STREQUAL "module" OR "${type}" STREQUAL "source")
      list(INSERT simple_plugin_liblist 0
	      ${ART_FRAMEWORK_CORE}
	      ${ART_FRAMEWORK_PRINCIPAL}
	      ${ART_PERSISTENCY_COMMON}
	      ${ART_PERSISTENCY_PROVENANCE}
	      ${ART_UTILITIES}
        ${CETLIB}
	      ${ROOT_CORE}
	      )
    endif()
  else()
    # this block is used when building art
    if("${type}" STREQUAL "service")
      list(INSERT simple_plugin_liblist 0 art_Framework_Services_Registry)
    elseif("${type}" STREQUAL "module" OR "${type}" STREQUAL "source")
      list(INSERT simple_plugin_liblist 0
        art_Framework_Core
        art_Framework_Principal
        art_Persistency_Provenance
        art_Utilities
        ${ROOT_CORE}
        )
    endif()
  endif()
  if( simple_plugin_liblist )
    target_link_libraries( ${plugin_name} ${simple_plugin_liblist} )
  endif( simple_plugin_liblist )
  if( NOT SP_NO_INSTALL )
    install( TARGETS ${plugin_name}  DESTINATION ${flavorqual_dir}/lib )
    cet_add_to_library_list( ${plugin_name} )
  endif()
endmacro (simple_plugin name type)
