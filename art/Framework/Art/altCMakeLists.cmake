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

add_library(art_Framework_Art SHARED
  ${CMAKE_CURRENT_BINARY_DIR}/artapp.cc
  ${CMAKE_CURRENT_BINARY_DIR}/mu2eapp.cc
  BasicOptionsHandler.cc
  BasicOptionsHandler.h
  BasicOutputOptionsHandler.cc
  BasicOutputOptionsHandler.h
  BasicPostProcessor.cc
  BasicPostProcessor.h
  BasicSourceOptionsHandler.cc
  BasicSourceOptionsHandler.h
  DebugOptionsHandler.cc
  DebugOptionsHandler.h
  EventProcessingOptionsHandler.cc
  EventProcessingOptionsHandler.h
  FileCatalogOptionsHandler.cc
  FileCatalogOptionsHandler.h
  InitRootHandlers.cc
  InitRootHandlers.h
  OptionsHandler.cc
  OptionsHandler.h
  OptionsHandlers.h
  find_config.cc
  find_config.h
  run_art.cc
  run_art.h
  detail/DebugOutput.h
  detail/LibraryInfo.h
  detail/LibraryInfoCollection.h
  detail/MetadataCollector.h
  detail/MetadataRegexHelpers.cc
  detail/MetadataRegexHelpers.h
  detail/MetadataSummary.h
  detail/PluginMetadata.h
  detail/PluginSymbolResolvers.cc
  detail/PluginSymbolResolvers.h
  detail/PrintFormatting.h
  detail/PrintPluginMetadata.cc
  detail/PrintPluginMetadata.h
  detail/ServiceNames.cc
  detail/ServiceNames.h
  detail/bold_fontify.h
  detail/exists_outside_prolog.h
  detail/fhicl_key.h
  detail/fillSourceList.cc
  detail/fillSourceList.h
  detail/get_LibraryInfoCollection.cc
  detail/get_LibraryInfoCollection.h
  detail/get_MetadataCollector.cc
  detail/get_MetadataCollector.h
  detail/get_MetadataSummary.cc
  detail/get_MetadataSummary.h
  detail/handle_deprecated_configs.cc
  detail/handle_deprecated_configs.h
  )
target_link_libraries(art_Framework_Art PUBLIC
  Boost::program_options
  art_Framework_IO_Root
  art_Framework_EventProcessor
  art_Framework_Core
  art_Framework_Services_Registry
  art_Persistency_Common
  art_Persistency_Provenance
  art_Utilities
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  art_Version
  ${ROOT_Hist_Library}
  ${ROOT_Matrix_Library}
  )

# - Core Art
set(ART_MAIN_FUNC artapp)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/art.cc.in ${CMAKE_CURRENT_BINARY_DIR}/art.cc @ONLY)
add_executable(art ${CMAKE_CURRENT_BINARY_DIR}/art.cc)
target_link_libraries(art PRIVATE
  art_Framework_Art
  messagefacility::MF_MessageLogger
  )
# - Art with unit testing
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/art_ut.cc.in ${CMAKE_CURRENT_BINARY_DIR}/art_ut.cc @ONLY)
add_executable(art_ut ${CMAKE_CURRENT_BINARY_DIR}/art_ut.cc)
target_link_libraries(art_ut PRIVATE
  art_Framework_Art
  messagefacility::MF_MessageLogger
  cetlib::cetlib
  Boost::unit_test_framework
  )

# - Mu2e Art
set(ART_MAIN_FUNC mu2eapp)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/art.cc.in ${CMAKE_CURRENT_BINARY_DIR}/mu2e.cc @ONLY)
add_executable(mu2e ${CMAKE_CURRENT_BINARY_DIR}/mu2e.cc)
target_link_libraries(mu2e PRIVATE
  art_Framework_Art
  messagefacility::MF_MessageLogger
  )
# - Mu2e with unit testing
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/art_ut.cc.in ${CMAKE_CURRENT_BINARY_DIR}/mu2e_ut.cc @ONLY)
add_executable(mu2e_ut ${CMAKE_CURRENT_BINARY_DIR}/mu2e_ut.cc)
target_link_libraries(mu2e_ut PRIVATE
  art_Framework_Art
  messagefacility::MF_MessageLogger
  cetlib::cetlib
  Boost::unit_test_framework
  )

add_executable(check_libs ${CMAKE_CURRENT_BINARY_DIR}/check_libs.cc)
target_link_libraries(check_libs PRIVATE cetlib::cetlib)

#-----------------------------------------------------------------------
# Install
install(TARGETS
  art_Framework_Art
  art
  art_ut
  mu2e
  mu2e_ut
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

# Softlinks for additional applications (UNIX only)
install(CODE "
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink art gm2
  WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_FULL_BINDIR}\"
  )
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink art lar
  WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_FULL_BINDIR}\"
  )
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink art nova
  WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_FULL_BINDIR}\"
  )
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink art_ut gm2_ut
  WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_FULL_BINDIR}\"
  )
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink art_ut lar_ut
  WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_FULL_BINDIR}\"
  )
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink art_ut nova_ut
  WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_FULL_BINDIR}\"
  )
"
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Art
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )



