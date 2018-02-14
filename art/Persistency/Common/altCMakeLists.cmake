add_library(art_Persistency_Common SHARED
  CollectionUtilities.h
  DelayedReader.cc
  DelayedReader.h
  GroupQueryResult.cc
  GroupQueryResult.h
  PtrMaker.h
  debugging_allocator.h
  fwd.h
  )

target_include_directories(art_Persistency_Common PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Persistency_Common
  PUBLIC
    canvas::canvas
    cetlib::cetlib
    )

install(TARGETS art_Persistency_Common
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Persistency/Common
  FILES_MATCHING PATTERN "*.h"
  )

