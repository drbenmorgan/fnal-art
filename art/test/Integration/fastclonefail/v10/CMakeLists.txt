if(ALT_CMAKE)
add_library(art_test_Integration_fastclonefail_v10 SHARED ClonedProd.cc)
target_include_directories(art_test_Integration_fastclonefail_v10 PUBLIC ${PROJECT_SOURCE_DIR})
target_link_libraries(art_test_Integration_fastclonefail_v10 PUBLIC
  art_Framework_Core cetlib ${ROOT_CORE})
else()
art_make_library(
  LIBRARIES
  art_Framework_Core cetlib ${ROOT_CORE}
  SOURCE ClonedProd.cc
  NO_INSTALL
)
endif()

art_dictionary(NO_INSTALL DICTIONARY_LIBRARIES art_test_Integration_fastclonefail_v10)

simple_plugin(ClonedProdProducer
  "module"
  art_test_Integration_fastclonefail_v10
  NO_INSTALL
  )

set_target_properties(
  art_test_Integration_fastclonefail_v10
  art_test_Integration_fastclonefail_v10_dict
  art_test_Integration_fastclonefail_v10_ClonedProdProducer_module
  PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}
  )

#  Write data to an output file using a private dictionary from this
#  directory. The intention is that the data members of the data product
#  class will be changed in such a way that the later test that reads
#  this file will need to use schema evolution which will cause fast
#  cloning to fail.
cet_test(test_fastclonefail_w.sh PREBUILT
  TEST_ARGS test_fastclone_fail_v10.fcl
  DATAFILES test_fastclone_fail_v10.fcl
)
