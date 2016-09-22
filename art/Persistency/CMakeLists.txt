# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
else()

# project name
project(Persistency)

# build Persistency libraries
#add_subdirectory (CLHEPDictionaries)
add_subdirectory (Common)
add_subdirectory (Provenance)
add_subdirectory (RootDB)
#add_subdirectory (StdDictionaries)
#add_subdirectory (WrappedStdDictionaries)
#add_subdirectory (CetlibDictionaries)
#add_subdirectory (FhiclCppDictionaries)

endif() # ALT_CMAKE
