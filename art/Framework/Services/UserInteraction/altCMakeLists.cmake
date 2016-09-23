add_library(art_Framework_Services_UserInteraction SHARED
  UserInteraction.h
  UserInteraction.cc
  )

target_link_libraries(art_Framework_Services_UserInteraction PUBLIC
  art_Framework_Core
  art_Framework_Principal
  art_Framework_Services_Registry
  canvas::canvas_Persistency_Provenance
  fhiclcpp::fhiclcpp
  )

install(TARGETS art_Framework_Services_UserInteraction
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/UserInteraction
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

