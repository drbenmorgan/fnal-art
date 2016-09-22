set(art_PERSISTENCY_PROVENANCE_SOURCES
  BranchIDListHelper.cc
  BranchIDListHelper.h
  BranchIDListRegistry.h
  EventProcessHistoryID.h
  MasterProductRegistry.cc
  MasterProductRegistry.h
  ProcessConfigurationRegistry.h
  ProcessHistoryRegistry.h
  ProductMetaData.cc
  ProductMetaData.h
  Selections.h
  detail/branchNameComponentChecking.cc
  detail/branchNameComponentChecking.h
  detail/type_aliases.h
  )

add_library(art_Persistency_Provenance SHARED ${art_PERSISTENCY_PROVENANCE_SOURCES})

# Review these links...
# Boost::thread, MessageLogger not used?
# cetlib a direct dependence?
target_link_libraries(art_Persistency_Provenance PUBLIC
  art_Persistency_RootDB
  art_Utilities
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  Boost::thread
  messagefacility::MF_MessageLogger
	)

install(TARGETS art_Persistency_Provenance
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Persistency/Provenance
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

