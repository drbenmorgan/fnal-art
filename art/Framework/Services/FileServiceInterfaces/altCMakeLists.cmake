add_library(art_Framework_Services_FileServiceInterfaces SHARED
  CatalogInterface.h
  FileDeliveryStatus.cc
  FileDeliveryStatus.h
  FileDisposition.cc
  FileDisposition.h
  FileTransfer.h
  FileTransferStatus.cc
  FileTransferStatus.h
  )

target_include_directories(art_Framework_Services_FileServiceInterfaces PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

target_link_libraries(art_Framework_Services_FileServiceInterfaces
  # Needs review - mix of interface, header only...
  PUBLIC
    art_Framework_Services_Registry
    fhiclcpp::fhiclcpp
  )

install(TARGETS art_Framework_Services_FileServiceInterfaces
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/Framework/Services/FileServiceInterfaces
  FILES_MATCHING PATTERN "*.h"
  )


