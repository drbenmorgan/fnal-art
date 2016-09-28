include_directories(${ROOT_INCLUDE_DIRS})

add_library(art_test_TestObjects SHARED
  TH1Data.cc
  TH1Data.h
  )

# Must link to both Host and Core in case Root was not built
# with CMake or explicit linking
target_link_libraries(art_test_TestObjects PUBLIC
  ${ROOT_Hist_LIBRARY}
  ${ROOT_Core_LIBRARY}
  )
install(TARGETS art_test_TestObjects
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/test/TestObjects
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
  )

# Extra inc dirs until we can support genexes
include_directories(${canvas_INCLUDE_DIR})
art_dictionary(DICTIONARY_LIBRARIES art_test_TestObjects canvas::canvas_Persistency_Common_dict)



