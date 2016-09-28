#
# http://root.cern.ch/viewvc/trunk/cint/reflex/cmake/modules/FindCppUnit.cmake
#
# - Find CppUnit
# This module finds an installed CppUnit package.
#
# It sets the following variables:
# CPPUNIT_FOUND - Set to false, or undefined, if CppUnit isn't found.
# CPPUNIT_INCLUDE_DIR - The CppUnit include directory.
# CPPUNIT_LIBRARY - The CppUnit library to link against.

find_path(CPPUNIT_INCLUDE_DIR cppunit/Test.h)
find_library(CPPUNIT_LIBRARY NAMES cppunit)

# handle the QUIETLY and REQUIRED arguments and set ZLIB_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CPPUNIT REQUIRED_VARS CPPUNIT_LIBRARY CPPUNIT_INCLUDE_DIR)

if(CPPUNIT_FOUND)
  set(CPPUNIT_INCLUDE_DIRS ${CPPUNIT_INCLUDE_DIR})

  if(NOT CPPUNIT_LIBRARIES)
    set(CPPUNIT_LIBRARIES ${CPPUNIT_LIBRARY})
  endif()

  if(NOT TARGET CppUnit::CppUnit)
    add_library(CppUnit::CppUnit UNKNOWN IMPORTED)
    set_target_properties(CppUnit::CppUnit PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${CPPUNIT_INCLUDE_DIRS}"
      IMPORTED_LOCATION "${CPPUNIT_LIBRARY}"
      )
  endif()
endif()
