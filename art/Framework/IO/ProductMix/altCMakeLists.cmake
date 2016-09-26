add_library(art_Framework_IO_ProductMix SHARED
  MixContainerTypes.h
  MixHelper.cc
  MixHelper.h
  MixOp.h
  MixOpBase.h
  ProdToProdMapBuilder.cc
  ProdToProdMapBuilder.h
  )

target_link_libraries(art_Framework_IO_ProductMix PUBLIC
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
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  messagefacility::MF_MessageLogger
  fhiclcpp::fhiclcpp
  cetlib::cetlib
  )

# NB: Includes needed to work around art_dictionary not yet supporting
# genexps
include_directories(${canvas_INCLUDE_DIR})
art_dictionary(DICTIONARY_LIBRARIES art_Persistency_Provenance canvas::canvas_Persistency_Provenance)

