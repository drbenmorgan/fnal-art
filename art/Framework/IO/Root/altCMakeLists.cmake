add_subdirectory(RootDB)

add_library(art_Framework_IO_RootVersion SHARED
  GetFileFormatEra.cc
  GetFileFormatEra.h
  GetFileFormatVersion.cc
  GetFileFormatVersion.h
  )
target_include_directories(art_Framework_IO_RootVersion PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )



add_library(art_Framework_IO_Root_detail_sources SHARED
  detail/DummyProductCache.cc
  detail/DummyProductCache.h
  detail/KeptProvenance.cc
  detail/KeptProvenance.h
  detail/RangeSetInfo.cc
  detail/RangeSetInfo.h
  detail/getEntry.cc
  detail/getObjectRequireDict.cc
  detail/getObjectRequireDict.h
  detail/rangeSetFromFileIndex.cc
  detail/rangeSetFromFileIndex.h
  detail/readFileIndex.h
  detail/readMetadata.h
  detail/resolveRangeSet.cc
  detail/resolveRangeSet.h
  detail/rootFileSizeTools.cc
  detail/rootFileSizeTools.h
  detail/rootOutputConfigurationTools.cc
  detail/rootOutputConfigurationTools.h
  )
target_include_directories(art_Framework_IO_Root_detail_sources PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
target_link_libraries(art_Framework_IO_Root_detail_sources
  PUBLIC
    art_Framework_IO
    art_Framework_Core
    art_Framework_IO_Root_RootDB
    canvas::canvas
    SQLite::SQLite
    ROOT::Core
    ROOT::RIO
    ROOT::Tree
    )


add_library(art_Framework_IO_Root_file_info_dumper SHARED
  detail/InfoDumperInputFile.cc
  detail/InfoDumperInputFile.h
  )
target_include_directories(art_Framework_IO_Root_file_info_dumper PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
target_link_libraries(art_Framework_IO_Root_file_info_dumper
  PUBLIC
   art_Framework_IO_Root_detail_sources
   art_Framework_IO_Root_RootDB
   # And...
   )


add_library(art_Framework_IO_Root SHARED
  BranchMapperWithReader.h
  DropMetaData.cc
  DropMetaData.h
  DuplicateChecker.cc
  DuplicateChecker.h
  FastCloningInfoProvider.cc
  FastCloningInfoProvider.h
  InitRootHandlers.cc
  InitRootHandlers.h
  Inputfwd.h
  RootBranchInfo.cc
  RootBranchInfo.h
  RootBranchInfoList.cc
  RootBranchInfoList.h
  RootDelayedReader.cc
  RootDelayedReader.h
  RootFileBlock.h
  RootInput.h
  RootInputFile.cc
  RootInputFile.h
  RootInputFileSequence.cc
  RootInputFileSequence.h
  RootInputTree.cc
  RootInputTree.h
  RootOutputFile.cc
  RootOutputFile.h
  RootOutputTree.cc
  RootOutputTree.h
  RootSizeOnDisk.cc
  RootSizeOnDisk.h
  checkDictionaries.cc
  checkDictionaries.h
  rootErrMsgs.h
  )
target_include_directories(art_Framework_IO_Root PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  # Until ROOT supplies full usage requirements
  $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>
  )
target_link_libraries(art_Framework_IO_Root
  PUBLIC
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
    cetlib::cetlib
    canvas::canvas
    ROOT::Hist
    ROOT::Tree
   )

simple_plugin(RootInput "source" art_Framework_IO_Root art_Framework_IO_Catalog)
simple_plugin(RootOutput "module" art_Framework_IO_Root)


add_executable(product_sizes_dumper product_sizes_dumper.cc)
target_include_directories(product_sizes_dumper PRIVATE $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>)
target_link_libraries(product_sizes_dumper PRIVATE art_Framework_IO_Root ROOT::Core ROOT::RIO Boost::program_options)

add_executable(config_dumper config_dumper.cc)
target_include_directories(config_dumper PRIVATE $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>)
target_link_libraries(config_dumper
  PRIVATE
    art_Framework_IO_Root
    art_Framework_IO_Root_RootDB
    canvas::canvas
    fhiclcpp::fhiclcpp
    ROOT::RIO
    ROOT::Tree
    Boost::program_options
    )

add_executable(sam_metadata_dumper sam_metadata_dumper.cc)
target_include_directories(sam_metadata_dumper PRIVATE $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>)
target_link_libraries(sam_metadata_dumper
  PRIVATE
    art_Framework_IO_Root
    art_Framework_IO_Root_RootDB
    canvas::canvas
    cetlib::cetlib
    fhiclcpp::fhiclcpp
    Boost::program_options
    ROOT::Core
    ROOT::RIO
    SQLite::SQLite
    )

add_executable(count_events count_events.cc)
target_include_directories(count_events PRIVATE $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>)
target_link_libraries(count_events
  PRIVATE
    canvas::canvas
    Boost::program_options
    ROOT::Core
    ROOT::RIO
    ROOT::Tree
    )

add_executable(file_info_dumper file_info_dumper.cc)
target_include_directories(file_info_dumper PRIVATE $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>)
target_link_libraries(file_info_dumper
  PRIVATE
    art_Framework_IO_RootVersion
    art_Framework_IO_Root_RootDB
    art_Framework_IO_Root_file_info_dumper
    Boost::program_options
    canvas::canvas
    cetlib::cetlib
    ROOT::Core
    ROOT::RIO
    SQLite::SQLite
    )



install(
  TARGETS
    art_Framework_IO_RootVersion
    art_Framework_IO_Root_detail_sources
    art_Framework_IO_Root_file_info_dumper
    art_Framework_IO_Root
    art_Framework_IO_Root_RootOutput_module
    art_Framework_IO_Root_RootInput_source
    product_sizes_dumper
    config_dumper
    sam_metadata_dumper
    count_events
    file_info_dumper
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )


