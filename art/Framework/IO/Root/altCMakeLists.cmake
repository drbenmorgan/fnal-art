add_library(art_Framework_IO_Root_detail_sources SHARED
  detail/DummyProductCache.cc
  detail/DummyProductCache.h
  detail/KeptProvenance.cc
  detail/KeptProvenance.h
  detail/getEntry.cc
  detail/resolveRangeSet.cc
  detail/resolveRangeSet.h
  detail/rootFileSizeTools.cc
  detail/rootFileSizeTools.h
  detail/rootOutputConfigurationTools.cc
  detail/rootOutputConfigurationTools.h
  )
target_link_libraries(art_Framework_IO_Root_detail_sources PUBLIC
  art_Framework_Principal
  art_Persistency_RootDB
  art_Utilities
  canvas::canvas_Persistency_Provenance
  messagefacility::MF_MessageLogger
  ${ROOT_Core_LIBRARY}
  ${ROOT_RIO_LIBRARY}
  ${ROOT_Tree_LIBRARY}
  )

add_library(art_Framework_IO_RootVersion SHARED
  GetFileFormatEra.cc
  GetFileFormatEra.h
  GetFileFormatVersion.cc
  GetFileFormatVersion.h
  )

add_library(art_Framework_IO_Root_file_info_dumper SHARED
  detail/InfoDumperInputFile.cc
  detail/InfoDumperInputFile.h
  )
target_link_libraries(art_Framework_IO_Root_file_info_dumper PUBLIC
  art_Framework_IO_Root_detail_sources
  art_Persistency_RootDB
  canvas::canvas_Persistency_Provenance
  cetlib::cetlib
  )

add_library(art_Framework_IO_Root SHARED
  BranchMapperWithReader.h
  DropMetaData.cc
  DropMetaData.h
  DuplicateChecker.cc
  DuplicateChecker.h
  FastCloningInfoProvider.cc
  FastCloningInfoProvider.h
  Inputfwd.h
  RootBranchInfo.cc
  RootBranchInfo.h
  RootBranchInfoList.cc
  RootBranchInfoList.h
  RootDelayedReader.cc
  RootDelayedReader.h
  RootInputFile.cc
  RootInputFile.h
  RootInputFileSequence.cc
  RootInputFileSequence.h
  RootOutputClosingCriteria.cc
  RootOutputClosingCriteria.h
  RootOutputFile.cc
  RootOutputFile.h
  RootOutputTree.cc
  RootOutputTree.h
  RootSizeOnDisk.cc
  RootSizeOnDisk.h
  RootTree.cc
  RootTree.h
  rootErrMsgs.h
  )
target_link_libraries(art_Framework_IO_Root PUBLIC
  art_Framework_Core
  art_Framework_IO
  art_Framework_IO_Catalog
  art_Framework_IO_detail
  art_Framework_Services_Registry
  art_Framework_Services_System_FileCatalogMetadata_service
  art_Persistency_Common
  art_Persistency_Provenance
  art_Framework_IO_RootVersion
  art_Framework_IO_Root_detail_sources
  canvas::canvas_Persistency_Provenance
  cetlib::cetlib
  #${ROOT_CINTEX}
  ${ROOT_Core_LIBRARY}
  ${ROOT_Tree_LIBRARY}
  #${ROOT_NET}
  #${ROOT_MATHCORE}
  )

art_add_source(RootInput RootInput.h RootInput_source.cc)
art_source_link_libraries(RootInput
  art_Framework_IO_Root
  art_Framework_IO_Catalog
  )
art_install_sources(SOURCES RootInput
  INSTALL
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

art_add_module(RootOutput RootOutput_module.cc)
art_module_link_libraries(RootOutput art_Framework_IO_Root)
art_install_modules(MODULES RootOutput
  INSTALL
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )


add_executable(product_sizes_dumper product_sizes_dumper.cc)
target_link_libraries(product_sizes_dumper PRIVATE
  art_Framework_IO_Root
  Boost::program_options
  cetlib::cetlib
  )

add_executable(config_dumper config_dumper.cc)
target_link_libraries(config_dumper PRIVATE
  art_Framework_IO_Root
  art_Utilities
  art_Framework_Core
  canvas::canvas_Utilities
  Boost::program_options
  ${ROOT_Tree_LIBRARY}
  ${ROOT_RIO_LIBRARY}
  )

add_executable(sam_metadata_dumper sam_metadata_dumper.cc)
target_link_libraries(sam_metadata_dumper PRIVATE
  art_Framework_IO_Root
  art_Utilities
  art_Framework_Core
  canvas::canvas_Utilities
  Boost::program_options
  ${ROOT_RIO_Library}
  )

add_executable(count_events count_events.cc)
target_link_libraries(count_events PRIVATE
  art_Framework_IO_Root
  art_Framework_Core
  art_Utilities
  canvas::canvas_Utilities
  Boost::program_options
  ${ROOT_Tree_LIBRARY}
  ${ROOT_RIO_LIBRARY}
  )

add_executable(file_info_dumper file_info_dumper.cc)
target_link_libraries(file_info_dumper PRIVATE
  art_Framework_IO_Root
  art_Framework_IO_Root_file_info_dumper
  art_Framework_Principal
  Boost::program_options
  )

install(TARGETS
  art_Framework_IO_Root_detail_sources
  art_Framework_IO_RootVersion
  art_Framework_IO_Root_file_info_dumper
  art_Framework_IO_Root
  product_sizes_dumper
  config_dumper
  sam_metadata_dumper
  count_events
  file_info_dumper
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )


