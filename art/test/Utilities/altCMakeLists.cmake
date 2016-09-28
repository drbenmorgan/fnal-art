# cet_test macro
#set(default_art_test_libraries
#  art_Utilities
#  canvas_Utilities
#  cetlib
#  MF_MessageLogger
#  ${ROOT_CINT}
#  ${ROOT_REFLEX}
#  )

cet_test(ParameterSet_get_CLHEP_t
  LIBRARIES art_Utilities
  )

cet_test(pointersEqual_t USE_BOOST_UNIT
  LIBRARIES art_Utilities
  )

foreach(test_cpp MallocOpts_t.cpp)
  get_filename_component(tname ${test_cpp} NAME_WE )
  cet_test(${tname}
    SOURCES ${test_cpp}
    LIBRARIES art_Utilities
    )
endforeach()

foreach(cppunit_test HRTime_t.cpp)
  get_filename_component(tname ${cppunit_test} NAME_WE )
  cet_test(${tname}
    SOURCES ${cppunit_test}
    LIBRARIES art_Utilities CppUnit::CppUnit
    )
endforeach()

cet_test(ScheduleID_t USE_BOOST_UNIT LIBRARIES cetlib::cetlib)

cet_test(parent_path_t USE_BOOST_UNIT
  LIBRARIES art_Utilities)
