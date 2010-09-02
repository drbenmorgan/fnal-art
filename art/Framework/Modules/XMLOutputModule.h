#ifndef FWCore_Modules_XMLOutputModule_h
#define FWCore_Modules_XMLOutputModule_h
// -*- C++ -*-
//
// Package:     Modules
// Class  :     XMLOutputModule
//
/**\class XMLOutputModule XMLOutputModule.h FWCore/Modules/interface/XMLOutputModule.h

 Description: <one line class summary>

 Usage:
    <usage>

*/
//
// Original Author:  Chris Jones
//         Created:  Fri Aug  4 20:45:42 EDT 2006
//
//

// system include files
#include <fstream>
#include <string>

#include "art/Framework/Core/Frameworkfwd.h"
#include "art/Framework/Core/OutputModule.h"

// user include files

// forward declarations
namespace edm {
  class XMLOutputModule : public OutputModule {

   public:
      XMLOutputModule(edm::ParameterSet const&);
      virtual ~XMLOutputModule();

      // ---------- const member functions ---------------------

      // ---------- static member functions --------------------

      // ---------- member functions ---------------------------

   private:
      virtual void write(EventPrincipal const& e);
      virtual void writeLuminosityBlock(SubRunPrincipal const&){}
      virtual void writeRun(RunPrincipal const&){}

      XMLOutputModule(XMLOutputModule const&); // stop default

      const XMLOutputModule& operator=(XMLOutputModule const&); // stop default

      // ---------- member data --------------------------------
      std::ofstream stream_;
      std::string indentation_;
  };
}

#endif
