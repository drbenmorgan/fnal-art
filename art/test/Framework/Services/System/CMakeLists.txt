# - When user supplies "-DALT_CMAKE" use the non-CET/UPS system
if(ALT_CMAKE)
  include(altCMakeLists.cmake)
else()

cet_test(ScheduleContext_t
  LIBRARIES
  art_Framework_Services_System_ScheduleContext_service
  art_Framework_Services_Registry
  art_Utilities canvas_Utilities
  ${TBB}
  )

endif() # ALT_CMAKE
