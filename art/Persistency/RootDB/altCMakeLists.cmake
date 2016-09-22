set(art_Persistency_RootDB_suorce
  MetaDataAccess.cc
  MetaDataAccess.h
  SQLErrMsg.cc
  SQLErrMsg.h
  SQLite3Wrapper.cc
  SQLite3Wrapper.h
  altCMakeLists.cmake
  tkeyvfs.cc
  tkeyvfs.h
  )

add_library(art_Persistency_RootDB SHARED ${art_Persistency_RootDB_suorce})

# UPS/CVMFS ROOT doesn't have full imported targets...
# NB, won't export as this hard codes an absolute path, so clients may
# find missing include paths for now...
include_directories(${ROOT_INCLUDE_DIRS})

# Everything has sqlite and RIO likely a PRIVATE dep
target_link_libraries(art_Persistency_RootDB PUBLIC
  art_Utilities
  ${ROOT_RIO_LIBRARY}
  ${ROOT_Thread_LIBRARY}
  ${ROOT_Core_LIBRARY}
  canvas::canvas_Utilities
  SQLite::SQLite
  )

install(TARGETS art_Persistency_RootDB
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Persistency/RootDB
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )


