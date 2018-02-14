add_library(art_Framework_Core SHARED
  Breakpoints.cc
  Breakpoints.h
  CPCSentry.h
  CachedProducts.cc
  CachedProducts.h
  DecrepitRelicInputSourceImplementation.cc
  DecrepitRelicInputSourceImplementation.h
  EDAnalyzer.cc
  EDAnalyzer.h
  EDFilter.cc
  EDFilter.h
  EDProducer.cc
  EDProducer.h
  EmptyEventTimestampPlugin.cc
  EmptyEventTimestampPlugin.h
  EndPathExecutor.cc
  EndPathExecutor.h
  EngineCreator.cc
  EngineCreator.h
  EventObserverBase.cc
  EventObserverBase.h
  EventSelector.cc
  EventSelector.h
  FileBlock.h
  FileCatalogMetadataPlugin.cc
  FileCatalogMetadataPlugin.h
  Frameworkfwd.h
  GroupSelector.cc
  GroupSelector.h
  GroupSelectorRules.cc
  GroupSelectorRules.h
  InputSource.cc
  InputSource.h
  InputSourceDescription.h
  InputSourceFactory.cc
  InputSourceFactory.h
  InputSourceMacros.h
  MFStatusUpdater.cc
  MFStatusUpdater.h
  ModuleMacros.h
  ModuleType.h
  OutputFileGranularity.h
  OutputFileStatus.h
  OutputModule.cc
  OutputModule.h
  OutputModuleDescription.h
  OutputWorker.cc
  OutputWorker.h
  Path.cc
  Path.h
  PathManager.cc
  PathManager.h
  PathsInfo.cc
  PathsInfo.h
  ProducerBase.h
  ProducingService.cc
  ProducingService.h
  ProducingServiceSignals.h
  ProductRegistryHelper.cc
  ProductRegistryHelper.h
  PtrRemapper.h
  RPManager.cc
  RPManager.h
  RPWorkerT.h
  ResultsProducer.cc
  ResultsProducer.h
  Schedule.cc
  Schedule.h
  TriggerReport.h
  TriggerResultInserter.cc
  TriggerResultInserter.h
  WorkerInPath.cc
  WorkerInPath.h
  WorkerMap.h
  WorkerT.h
  detail/IgnoreModuleLabel.h
  detail/ModuleConfigInfo.cc
  detail/ModuleConfigInfo.h
  detail/ModuleFactory.cc
  detail/ModuleFactory.h
  detail/ModuleInPathInfo.h
  detail/ModuleTypeDeducer.h
  detail/ScheduleTask.cc
  detail/ScheduleTask.h
  detail/get_failureToPut_flag.cc
  detail/get_failureToPut_flag.h
  detail/parse_path_spec.cc
  detail/parse_path_spec.h
  detail/verify_names.cc
  detail/verify_names.h
  )

target_include_directories(art_Framework_Core PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Framework_Core
  PUBLIC
    art_Framework_Principal
    art_Framework_Services_Registry
    art_Framework_Services_FileServiceInterfaces
    art_Persistency_Common
    art_Persistency_Provenance
    art_Utilities
    canvas::canvas
    cetlib::cetlib
    fhiclcpp::fhiclcpp
    messagefacility::MF_MessageLogger
    TBB::tbb
  PRIVATE
    art_Version
    )

install(TARGETS art_Framework_Core
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Core
  FILES_MATCHING PATTERN "*.h"
  )


#art_make(
#  SUBDIRS detail
#  LIB_LIBRARIES
#  art_Framework_Services_System_CurrentModule_service
#  art_Framework_Services_System_TriggerNamesService_service
#  art_Framework_Services_Optional_RandomNumberGenerator_service
#  art_Framework_Principal
#  art_Persistency_Common
#  art_Persistency_Provenance canvas
#  art_Framework_Services_Registry
#  art_Utilities
#  art_Version
#  MF_MessageLogger
#  fhiclcpp
#  cetlib
#  canvas
#  ${CLHEP}
#  ${TBB}
#  )

#install_headers(SUBDIRS detail)
#install_source(SUBDIRS detail)
