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
  EventObserver.cc
  EventObserver.h
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
  IEventProcessor.cc
  IEventProcessor.h
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
  OutputFileStatus.h
  OutputFileSwitchBoundary.h
  OutputModule.cc
  OutputModule.h
  OutputModuleDescription.h
  OutputWorker.cc
  OutputWorker.h
  Path.cc
  Path.h
  PathManager.cc
  PathManager.h
  PathsInfo.h
  PrincipalCache.cc
  PrincipalCache.h
  PrincipalMaker.h
  ProcessingTask.h
  ProducerBase.h
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
  TriggerNames.cc
  TriggerNames.h
  TriggerReport.h
  TriggerResultInserter.cc
  TriggerResultInserter.h
  UnknownModuleException.h
  WorkerInPath.cc
  WorkerInPath.h
  WorkerMap.h
  WorkerT.h
  get_BranchDescription.cc
  get_BranchDescription.h
  detail/IgnoreModuleLabel.h
  detail/ModuleConfigInfo.cc
  detail/ModuleConfigInfo.h
  detail/ModuleFactory.cc
  detail/ModuleFactory.h
  detail/ModuleInPathInfo.h
  detail/ModuleTypeDeducer.h
  detail/OutputModuleUtils.cc
  detail/OutputModuleUtils.h
  detail/ScheduleTask.cc
  detail/ScheduleTask.h
  detail/get_failureToPut_flag.cc
  detail/get_failureToPut_flag.h
  detail/verify_names.cc
  detail/verify_names.h
  )

target_link_libraries(art_Framework_Core PUBLIC
  art_Framework_Principal
  art_Framework_Services_FileServiceInterfaces
  art_Framework_Services_Optional_MemoryTracker_service
  art_Framework_Services_Optional_RandomNumberGenerator_service
  art_Framework_Services_Optional_TimeTracker_service
  art_Framework_Services_Registry
  art_Framework_Services_System_FileCatalogMetadata_service
  art_Framework_Services_System_TriggerNamesService_service
  art_Persistency_Common
  art_Persistency_Provenance
  art_Utilities
  art_Version
  canvas::canvas_Persistency_Common
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  cetlib::cetlib
  fhiclcpp::fhiclcpp
  messagefacility::MF_MessageLogger
  messagefacility::MF_MessageService
  ${TBB_LIBRARIES}
  )

install(TARGETS art_Framework_Core
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Core
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

