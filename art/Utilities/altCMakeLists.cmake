set(art_Utilities_sources
  BasicPluginMacros.h
  ExceptionMessages.cc
  ExceptionMessages.h
  GetReleaseVersion.h
  MallocOpts.cc
  MallocOpts.h
  OutputFileInfo.h
  ParameterSetHelpers/CLHEP_ps.h
  PluginSuffixes.cc
  PluginSuffixes.h
  ProductSemantics.h
  RegexMatch.cc
  RegexMatch.h
  RootHandlers.cc
  RootHandlers.h
  SAMMetadataTranslators.h
  ScheduleID.h
  ToolConfigTable.h
  ToolMacros.h
  UnixSignalHandlers.cc
  UnixSignalHandlers.h
  Verbosity.h
  bold_fontify.h
  ensureTable.cc
  ensureTable.h
  fwd.h
  make_tool.h
  parent_path.cc
  parent_path.h
  pointersEqual.h
  quiet_unit_test.hpp
  unique_filename.cc
  unique_filename.h
  detail/tool_type.h
  )

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  list(APPEND art_Utilities_sources
    LinuxProcData.h
    LinuxProcMgr.cc
    LinuxProcMgr.h
    )
endif()

add_library(art_Utilities SHARED ${art_Utilities_sources})
target_include_directories(art_Utilities PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
target_link_libraries(art_Utilities
  PUBLIC
    CLHEP::CLHEP
    art_Version
    canvas::canvas
    cetlib::cetlib
    fhiclcpp::fhiclcpp
    messagefacility::MF_MessageLogger
  PRIVATE
    Boost::filesystem
    Boost::system
    )

install(TARGETS art_Utilities
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

# System dependent header install
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Utilities
    FILES_MATCHING
      PATTERN "*.h"
      PATTERN "*.hpp"
    )
else()
  install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Utilities
    FILES_MATCHING
      PATTERN "*.h"
      PATTERN "*.hpp"
      PATTERN "Linux*" EXCLUDE
    )
endif()

