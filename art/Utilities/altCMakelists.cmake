set(art_UTILITIES_SOURCES
  BasicHelperMacros.h
  BasicPluginMacros.h
  ExceptionMessages.cc
  ExceptionMessages.h
  FirstAbsoluteOrLookupWithDotPolicy.cc
  FirstAbsoluteOrLookupWithDotPolicy.h
  GetReleaseVersion.h
  HRRealTime.h
  JobMode.h
  MallocOpts.cc
  MallocOpts.h
  OutputFileInfo.h
  PluginSuffixes.cc
  PluginSuffixes.h
  ProductTokens.h
  RegexMatch.cc
  RegexMatch.h
  RootHandlers.cc
  RootHandlers.h
  SAMMetadataTranslators.h
  ScheduleID.h
  ThreadSafeIndexedRegistry.h
  UnixSignalHandlers.cc
  UnixSignalHandlers.h
  Verbosity.h
  ensureTable.cc
  ensureTable.h
  fwd.h
  parent_path.cc
  parent_path.h
  pointersEqual.h
  quiet_unit_test.hpp
  unique_filename.cc
  unique_filename.h
  ParameterSetHelpers/CLHEP_ps.h
  detail/math_private.h
  detail/serviceConfigLocation.cc
  detail/serviceConfigLocation.h
  )

add_library(art_Utilities SHARED ${art_UTILITIES_SOURCES})

# - Only link direct(*) dependencies
# (*) needs review, plus PRIVTAE/PUBLIC split
# CLHEP is needed as an INTERFACE because the ParameterSet helper
# part use the headers, and consequently the library. Because
# currently supported CLHEP doesn't use usage requirements fully,
# need both target_link_libs and target_include_dirs
target_link_libraries(art_Utilities PUBLIC
  canvas::canvas_Utilities
  messagefacility::MF_MessageLogger
  messagefacility::MF_Utilities
  fhiclcpp::fhiclcpp
  cetlib::cetlib
  Boost::filesystem
  Boost::system
  Boost::thread
  ${TBB_LIBRARIES}
  ${CMAKE_DL_LIBS}
  INTERFACE
   CLHEP::CLHEP
  )
target_include_directories(art_Utilities INTERFACE
  ${CLHEP_INCLUDE_DIRS}
  )

install(TARGETS art_Utilities
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Utilities
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
  )

