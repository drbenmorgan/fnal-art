//
// check_libs is a program that tries loading all types of libraries
// that the art LibraryManager works with, to help diagnose loading
// problems.
//

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

#include "cpp0x/regex"

#include "art/Framework/Core/LibraryManager.h"
#include "cetlib/exception.h"

using art::LibraryManager;
using std::string;
using std::vector;
using std::cout;
using std::regex;
using std::regex_match;


void try_loading(LibraryManager& libs, 
		 string const& path,
		 string const& expected_symbol)
{
  void* sym = 0;
  try 
    {
      sym = libs.getSymbolByPath(path, expected_symbol);
      if (sym) 
	cout << "... ok\n";
      else
	cout << "... symbol value was zero: report this to ART core team\n";
    }
  catch (cet::exception& e)
    {
      cout << "... FAILED:\n"
	   << e.what() << '\n';
    }
  catch (...)
    {
      cout << " ... FAILED: Loading threw an unidentified exception\n";
    }

}

void checkLoadability(string const& type,
		      string const& expected_symbol)
{
  static const regex system_service("libart_Framework_Services_System_[A-Za-z]+_service\\.so");

  vector<string> libraries;
  LibraryManager libs(type);

  size_t numLibs = libs.getLoadableLibraries(libraries);
  cout << "    found " 
       << numLibs 
       << " libraries of type "
       << type
       << ", list follows...\n";

  for (vector<string>::const_iterator
	 it = libraries.begin(),
	 end = libraries.end();
       it != end; ++it)
    {
      cout << "        " << *it;
      void* sym = 0;
      if (regex_search(*it, system_service))
	cout << "... ok\n";
      else
	try_loading(libs, *it, expected_symbol);
    }

}

int main()
{
  checkLoadability("module", "make");
  checkLoadability("service", "make");

  checkLoadability("map", "SEAL_CAPABILITIES");
  checkLoadability("dict", "_init");

  return 0;
}
