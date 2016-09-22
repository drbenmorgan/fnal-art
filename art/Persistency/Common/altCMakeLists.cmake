set(art_Persistency_Common_sources
  CollectionUtilities.h
  DelayedReader.cc
  DelayedReader.h
  GroupQueryResult.cc
  GroupQueryResult.h
  PostReadFixupTrait.h
  debugging_allocator.h
  fwd.h
  )

add_library(art_Persistency_Common SHARED ${art_Persistency_Common_sources})

# - Review these links...
target_link_libraries(art_Persistency_Common
  canvas::canvas_Persistency_Common
  canvas::canvas_Persistency_Provenance
  canvas::canvas_Utilities
  art_Persistency_Provenance
  art_Utilities
  ${ROOT_CORE}
  ${Boost_THREAD_LIBRARY}
  )

install(TARGETS art_Persistency_Common
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Persistency/Common
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

