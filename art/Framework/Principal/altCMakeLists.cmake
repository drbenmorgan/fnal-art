add_library(art_Framework_Principal SHARED
  ActionCodes.h
  Actions.cc
  Actions.h
  AssnsGroup.cc
  AssnsGroup.h
  AssnsGroupWithData.cc
  AssnsGroupWithData.h
  BranchActionType.h
  CMakeLists.txt
  ClosedRangeSetHandler.cc
  ClosedRangeSetHandler.h
  Consumer.cc
  Consumer.h
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
  ExecutionCounts.h
  Group.cc
  Group.h
  GroupFactory.h
  Handle.h
  MaybeIncrementCounts.h
  NoDelayedReader.cc
  NoDelayedReader.h
  OpenRangeSetHandler.cc
  OpenRangeSetHandler.h
  OutputHandle.h
  Principal.cc
  Principal.h
  PrincipalPackages.h
  ProductInfo.h
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
  altCMakeLists.cmake
  fwd.h
  get_ProductDescription.cc
  get_ProductDescription.h
  )

target_include_directories(art_Framework_Principal PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Framework_Principal
  PUBLIC
    art_Persistency_Common
    art_Persistency_Provenance
    art_Framework_Services_Registry
    # May also need TriggerNameServce..
    canvas::canvas
    canvas_root_io::canvas_root_io
    cetlib::cetlib
    fhiclcpp::fhiclcpp
    messagefacility::MF_MessageLogger
    )

  install(TARGETS art_Framework_Principal
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Principal
  FILES_MATCHING PATTERN "*.h"
  )

