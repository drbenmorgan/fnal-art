if(CMAKE_CXX_COMPILER_ID MATCHES Clang)
  set_property(SOURCE MixHelper.cc APPEND
    PROPERTY COMPILE_DEFINITIONS _LIBCPP_ENABLE_CXX17_REMOVED_FEATURES=1
    )
endif()

add_library(art_Framework_IO_ProductMix SHARED
  MixHelper.cc
  MixHelper.h
  MixOp.h
  MixOpBase.cc
  MixOpBase.h
  MixTypes.h
  ProdToProdMapBuilder.cc
  ProdToProdMapBuilder.h
  detail/checkForMissingDictionaries.cc
  detail/checkForMissingDictionaries.h
  )
target_include_directories(art_Framework_IO_ProductMix PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
target_link_libraries(art_Framework_IO_ProductMix
  PUBLIC
    art_Framework_IO_Root
    art_Framework_Services_System_CurrentModule_service
    art_Framework_Services_System_TriggerNamesService_service
    art_Framework_Services_Optional_RandomNumberGenerator_service
    art_Framework_Core
    art_Framework_Principal
    art_Framework_Services_Registry
    art_Persistency_Common
    art_Persistency_Provenance
    art_Utilities
    messagefacility::MF_MessageLogger
    fhiclcpp::fhiclcpp
    canvas::canvas
    canvas_root_io::canvas_root_io
    cetlib::cetlib
    )

art_dictionary(DICTIONARY_LIBRARIES art_Persistency_Provenance canvas::canvas DICT_NAME_VAR _dictlib)

# Use get_property to avoid nested genex expansion issue
get_target_property(_rootmap_file ${_dictlib}_dict ROOTMAP_FILE)
get_target_property(_pcm_file ${_dictlib}_dict PCM_FILE)
install(TARGETS art_Framework_IO_ProductMix ${_dictlib}_dict
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES ${_rootmap_file} ${_pcm_file}
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

