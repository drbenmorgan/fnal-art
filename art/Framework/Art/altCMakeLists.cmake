# Configure file to handle differences for Mac.
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/check_libs.cc.in
  ${CMAKE_CURRENT_BINARY_DIR}/check_libs.cc @ONLY
  )

####################################
# Configure for desired default exception handling.
SET(ART_MAIN_FUNC artapp)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/artapp.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/${ART_MAIN_FUNC}.h @ONLY
  )

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/artapp.cc.in
  ${CMAKE_CURRENT_BINARY_DIR}/${ART_MAIN_FUNC}.cc @ONLY
  )

SET(ART_MAIN_FUNC mu2eapp)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/artapp.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/${ART_MAIN_FUNC}.h @ONLY
  )

SET(ART_RETHROW_DEFAULT TRUE)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/artapp.cc.in
  ${CMAKE_CURRENT_BINARY_DIR}/${ART_MAIN_FUNC}.cc @ONLY
  )
####################################

# No builds under here
#add_subdirectory(detail)
#add_subdirectory(detail/md-collector)
#add_subdirectory(detail/md-summary)

set(art_Framework_Art_sources
  BasicOptionsHandler.cc
  BasicPostProcessor.cc
  BasicSourceOptionsHandler.cc
  BasicOutputOptionsHandler.cc
  DebugOptionsHandler.cc
  ProcessingOptionsHandler.cc
  FileCatalogOptionsHandler.cc
  OptionsHandler.cc
  ${CMAKE_CURRENT_BINARY_DIR}/artapp.cc
  ${CMAKE_CURRENT_BINARY_DIR}/mu2eapp.cc
  find_config.cc
  run_art.cc
  detail/MetadataRegexHelpers.cc
  detail/AllowedConfiguration.cc
  detail/PluginSymbolResolvers.cc
  detail/ServiceNames.cc
  detail/fillSourceList.cc
  detail/describe.cc
  detail/get_LibraryInfoCollection.cc
  detail/get_MetadataCollector.cc
  detail/get_MetadataSummary.cc
  )

add_library(art_Framework_Art SHARED ${art_Framework_Art_sources})

target_include_directories(art_Framework_Art PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Framework_Art PUBLIC
  art_Framework_EventProcessor
  art_Framework_Core
  art_Utilities
  art_Version
  messagefacility::MF_MessageLogger
  Boost::program_options
  # The following are used for InitRootHandlers
  art_Framework_IO_Root
  art_Framework_IO_Root_RootDB
  ROOT::Hist
  ROOT::Tree
  )

install(TARGETS art_Framework_Art
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Art
  FILES_MATCHING PATTERN "*.h"
  )


# Build an art exec.
macro(art_exec TARGET_STEM IN_STEM MAIN_FUNC)
  cmake_parse_arguments(AE "" "" "LIBRARIES" ${ARGN})
  set(ART_MAIN_FUNC ${MAIN_FUNC})
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${IN_STEM}.cc.in
    ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_STEM}.cc @ONLY
    )

  add_executable(${TARGET_STEM} ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_STEM}.cc)
  target_link_libraries(${TARGET_STEM} PRIVATE art_Framework_Art messagefacility::MF_MessageLogger ${AE_LIBRARIES})

  set_property(TARGET ${TARGET_STEM} PROPERTY ENABLE_EXPORTS TRUE)
  # Enable plugins to access symbols exported by the exec (CMake policy CMP0065).
  install(TARGETS ${TARGET_STEM}
    EXPORT ${PROJECT_NAME}Targets
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endmacro()

# Standard execs
art_exec(art art artapp)
art_exec(gm2 art artapp)
art_exec(lar art artapp)
art_exec(mu2e art mu2eapp)
art_exec(nova art artapp)

# Execs with Boost unit testing enabled for modules.
find_package(Boost QUIET REQUIRED unit_test_framework)
art_exec(art_ut art_ut artapp LIBRARIES Boost::unit_test_framework)
art_exec(gm2_ut art_ut artapp LIBRARIES Boost::unit_test_framework)
art_exec(lar_ut art_ut artapp LIBRARIES Boost::unit_test_framework)
art_exec(mu2e_ut art_ut mu2eapp LIBRARIES Boost::unit_test_framework)
art_exec(nova_ut art_ut artapp LIBRARIES Boost::unit_test_framework)

add_executable(check_libs ${CMAKE_CURRENT_BINARY_DIR}/check_libs.cc)
target_link_libraries(check_libs PRIVATE art_Utilities canvas::canvas cetlib::cetlib)
install(TARGETS check_libs
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
