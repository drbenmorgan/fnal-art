add_library(art_Persistency_Provenance SHARED
  EventProcessHistoryID.h
  MasterProductRegistry.cc
  MasterProductRegistry.h
  ProcessConfigurationRegistry.h
  ProcessHistoryRegistry.h
  ProductMetaData.cc
  ProductMetaData.h
  Selections.h
  orderedProcessNamesCollection.cc
  orderedProcessNamesCollection.h
  detail/branchNameComponentChecking.cc
  detail/branchNameComponentChecking.h
  )

target_include_directories(art_Persistency_Provenance PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Persistency_Provenance
  PUBLIC
    canvas::canvas
    cetlib::cetlib
  PRIVATE
    Boost::boost
  )

install(TARGETS art_Persistency_Provenance
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Persistency/Provenance
  FILES_MATCHING PATTERN "*.h"
  )

