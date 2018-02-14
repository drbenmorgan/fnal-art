#add_subdirectory(detail)
# Build library here for now as it's extremely simple,
# Not clear why it would even be separate.
add_library(art_Framework_IO_detail SHARED
  detail/FileNameComponents.cc
  detail/FileNameComponents.h
  detail/logFileAction.cc
  detail/logFileAction.h
  detail/validateFileNamePattern.cc
  detail/validateFileNamePattern.h
  )
target_include_directories(art_Framework_IO_detail PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
target_link_libraries(art_Framework_IO_detail
  PRIVATE
    Boost::regex
    canvas::canvas
    messagefacility::MF_MessageLogger
    )

# - Now the main one
add_library(art_Framework_IO SHARED
  ClosingCriteria.cc
  ClosingCriteria.h
  FileStatsCollector.cc
  FileStatsCollector.h
  PostCloseFileRenamer.cc
  PostCloseFileRenamer.h
  )
target_include_directories(art_Framework_IO PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
target_link_libraries(art_Framework_IO
  PUBLIC
    Boost::regex
    Boost::date_time
    canvas::canvas
    fhiclcpp::fhiclcpp
    art_Framework_IO_detail
  PRIVATE
    Boost::filesystem
    Boost::system
    )

# Actual subdirectories
#add_subdirectory(Catalog) Requires TrivialFileTransfer_service
#add_subdirectory(ProductMix) Requires System/Option services, and art_Framework_Core
#add_subdirectory(Root) whole lot of stuff...
add_subdirectory(Sources)


install(TARGETS art_Framework_IO_detail art_Framework_IO
  EXPORT ${PROJECT_NAME}Targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

# install (DIRECTORY header...)





#art_make(LIB_LIBRARIES
#  art_Framework_IO_detail
#  art_Persistency_Provenance canvas
#  ${Boost_DATE_TIME_LIBRARY}
#  ${Boost_FILESYSTEM_LIBRARY}
#  ${Boost_REGEX_LIBRARY}
#)

#install_headers()
#install_source()

# build art_Framework_IO libraries
#add_subdirectory (Catalog)
#add_subdirectory (ProductMix)
#add_subdirectory (Root)
#add_subdirectory (Sources)
#add_subdirectory (detail)
