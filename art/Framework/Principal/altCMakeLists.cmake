set(art_Framework_Principal_sources
  ActionCodes.h
  Actions.cc
  Actions.h
  AssnsGroup.cc
  AssnsGroup.h
  ClosedRangeSetHandler.cc
  ClosedRangeSetHandler.h
  CurrentProcessingContext.cc
  CurrentProcessingContext.h
  DataViewImpl.cc
  DataViewImpl.h
  DeferredProductGetter.cc
  DeferredProductGetter.h
  Event.cc
  Event.h
  EventPrincipal.cc
  EventPrincipal.h
  Group.cc
  Group.h
  GroupFactory.cc
  GroupFactory.h
  Handle.h
  MaybeRunStopwatch.h
  NoDelayedReader.cc
  NoDelayedReader.h
  OccurrenceTraits.h
  OpenRangeSetHandler.cc
  OpenRangeSetHandler.h
  OutputHandle.h
  Principal.cc
  Principal.h
  Provenance.cc
  Provenance.h
  RPParams.h
  RPWorker.h
  RangeSetHandler.h
  RangeSetsSupported.h
  Results.cc
  Results.h
  ResultsPrincipal.cc
  ResultsPrincipal.h
  Run.cc
  Run.h
  RunPrincipal.cc
  RunPrincipal.h
  Selector.cc
  Selector.h
  SelectorBase.cc
  SelectorBase.h
  SubRun.cc
  SubRun.h
  SubRunPrincipal.cc
  SubRunPrincipal.h
  SummedValue.h
  View.h
  Worker.cc
  Worker.h
  WorkerParams.h
  fwd.h
  detail/maybe_record_parents.h
  detail/orderedProcessNames.cc
  detail/orderedProcessNames.h
  )

add_library(art_Framework_Principal SHARED ${art_Framework_Principal_sources})

# Review link list for direct deps (CLHEP seems totally unused)
target_link_libraries(art_Framework_Principal PUBLIC
  art_Persistency_Common
  art_Framework_Services_Registry
  art_Utilities
  art_Version
  canvas::canvas_Utilities
  messagefacility::MF_MessageLogger
  fhiclcpp::fhiclcpp
  cetlib::cetlib
  #${CLHEP}
  )

install(TARGETS art_Framework_Principal
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Principal
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

