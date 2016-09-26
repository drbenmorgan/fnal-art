add_library(art_Framework_IO SHARED
  FileStatsCollector.cc
  FileStatsCollector.h
  PostCloseFileRenamer.cc
  PostCloseFileRenamer.h
  )

target_link_libraries(art_Framework_IO PUBLIC
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  Boost::date_time
  Boost::filesystem
  Boost::regex
  )

install(TARGETS art_Framework_IO
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/IO
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )


# build art_Framework_IO libraries
add_subdirectory (Catalog)
add_subdirectory (ProductMix)
add_subdirectory (Root)
add_subdirectory (Sources)
add_subdirectory (detail)
