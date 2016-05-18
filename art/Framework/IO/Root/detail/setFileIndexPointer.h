#ifndef art_Framework_IO_Root_setFileIndexPointer_h
#define art_Framework_IO_Root_setFileIndexPointer_h

#include "TFile.h"
#include "TTree.h"
#include "art/Framework/IO/Root/Inputfwd.h"
#include "art/Framework/IO/Root/rootErrMsgs.h"
#include "canvas/Persistency/Provenance/rootNames.h"
#include "canvas/Persistency/Provenance/FileIndex.h"

#include <memory>

// This function selects retrieves the FileIndex based on whether it
// is a branch (file format < 7) or tree (file format >= 7).

namespace art {
  namespace detail {

    inline
    void setFileIndexPointer(TFile* file, TTree* metaDataTree, FileIndex *& findexPtr) {

      if (metaDataTree->GetBranch(rootNames::metaBranchRootName<FileIndex>())) {
        metaDataTree->SetBranchAddress(rootNames::metaBranchRootName<FileIndex>(), &findexPtr);
      }
      else {
        TTree* fileIndexTree = static_cast<TTree*>(file->Get(rootNames::fileIndexTreeName().c_str()));
        if (!fileIndexTree)
          throw art::Exception(errors::FileReadError) << couldNotFindTree(rootNames::fileIndexTreeName());

        FileIndex::Element element;
        //        auto elemUniquePtr = std::make_unique<FileIndex::Element>();
        //        auto elemPtr = &*elemUniquePtr;
        auto elemPtr = &element;
        fileIndexTree->SetBranchAddress(rootNames::metaBranchRootName<FileIndex::Element>(), &elemPtr);

        for (size_t i{0}, sz = fileIndexTree->GetEntries(); i != sz ; ++i) {
          input::getEntry(fileIndexTree,i);
          findexPtr->addEntryOnLoad(elemPtr->eventID_, elemPtr->entry_);
        }
      }
    }
  }

}

#endif /* art_Framework_IO_Root_setFileIndexPointer_h */

// Local Variables:
// mode: c++
// End:
