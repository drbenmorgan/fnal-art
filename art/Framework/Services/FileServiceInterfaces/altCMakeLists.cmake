set(art_Framework_Services_FileServiceInterfaces_sources
  CatalogInterface.h
  FileDeliveryStatus.cc
  FileDeliveryStatus.h
  FileDisposition.cc
  FileDisposition.h
  FileTransfer.h
  FileTransferStatus.cc
  FileTransferStatus.h
  )

add_library(art_Framework_Services_FileServiceInterfaces
  SHARED
  ${art_Framework_Services_FileServiceInterfaces_sources}
  )

# - Again, review links for direct deps, PUBLIC/PRIVATE
target_link_libraries(art_Framework_Services_FileServiceInterfaces PUBLIC
  art_Framework_Services_Registry
  fhiclcpp::fhiclcpp
  )

install(TARGETS art_Framework_Services_FileServiceInterfaces
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT Runtime
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/FileServiceInterfaces
  COMPONENT Development
  FILES_MATCHING PATTERN "*.h"
  )

