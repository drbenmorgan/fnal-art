# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
else()


include(CetTest)

cet_test(GlobalSignal_t USE_BOOST_UNIT)
cet_test(LocalSignal_t USE_BOOST_UNIT)

endif() # ALT_CMAKE
