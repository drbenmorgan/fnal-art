#ifndef art_Persistency_Provenance_FileIndex_h
#define art_Persistency_Provenance_FileIndex_h

/*----------------------------------------------------------------------

FileIndex.h



----------------------------------------------------------------------*/

#include <vector>
#include <cassert>
#include "art/Persistency/Provenance/RunID.h"
#include "art/Persistency/Provenance/SubRunID.h"
#include "art/Persistency/Provenance/EventID.h"
#include "art/Persistency/Provenance/Transient.h"

#include <iosfwd>

namespace art {

   class FileIndex;

}
class art::FileIndex {

public:
   typedef long long EntryNumber_t;

   FileIndex();
   ~FileIndex() {}

   void addEntry(EventID const &eID, EntryNumber_t entry);

   enum EntryType {kRun, kSubRun, kEvent, kEnd};

   class Element {
   public:
      static EntryNumber_t const invalidEntry = -1LL;
      Element() : eventID_(), entry_(invalidEntry) {
      }
      Element(EventID const &eID, EntryNumber_t entry = invalidEntry) :
         eventID_(eID), entry_(entry) {
      }
      EntryType getEntryType() const {
         return eventID_.isValid()?kEvent:(eventID_.subRunID().isValid()?kSubRun:kRun);
      }
      EventID eventID_;
      EntryNumber_t entry_;
   };

   typedef std::vector<Element>::const_iterator const_iterator;

   void sortBy_Run_SubRun_Event();
   void sortBy_Run_SubRun_EventEntry();

   const_iterator
   findPosition(EventID const &eID) const;

   const_iterator
   findEventPosition(EventID const &eID, bool exact) const;

   const_iterator
   findSubRunPosition(SubRunID const &srID, bool exact) const;

   const_iterator
   findRunPosition(RunID const &rID, bool exact) const;

   const_iterator
   findSubRunOrRunPosition(SubRunID const &srID) const;

   bool
   containsEvent(EventID const &eID, bool exact) const {
      return findEventPosition(eID, exact) != entries_.end();
   }

   bool
   containsSubRun(SubRunID const &srID, bool exact) const {
      return findSubRunPosition(srID, exact) != entries_.end();
   }

   bool
   containsRun(RunID const &rID, bool exact) const {
      return findRunPosition(rID, exact) != entries_.end();
   }

   const_iterator begin() const {return entries_.begin();}

   const_iterator end() const {return entries_.end();}

   std::vector<Element>::size_type size() const {return entries_.size();}

   bool empty() const {return entries_.empty();}

   bool allEventsInEntryOrder() const;

   bool eventsUniqueAndOrdered() const;

   enum SortState { kNotSorted, kSorted_Run_SubRun_Event, kSorted_Run_SubRun_EventEntry};

   struct Transients {
      Transients();
      bool allInEntryOrder_;
      bool resultCached_;
      SortState sortState_;
   };

private:

   bool& allInEntryOrder() const {return transients_.get().allInEntryOrder_;}
   bool& resultCached() const {return transients_.get().resultCached_;}
   SortState& sortState() const {return transients_.get().sortState_;}

   std::vector<Element> entries_;
   mutable Transient<Transients> transients_;
};

namespace art {
  bool operator<(FileIndex::Element const& lh, FileIndex::Element const& rh);

  inline
  bool operator>(FileIndex::Element const& lh, FileIndex::Element const& rh) {return rh < lh;}

  inline
  bool operator>=(FileIndex::Element const& lh, FileIndex::Element const& rh) {return !(lh < rh);}

  inline
  bool operator<=(FileIndex::Element const& lh, FileIndex::Element const& rh) {return !(rh < lh);}

  inline
  bool operator==(FileIndex::Element const& lh, FileIndex::Element const& rh) {return !(lh < rh || rh < lh);}

  inline
  bool operator!=(FileIndex::Element const& lh, FileIndex::Element const& rh) {return lh < rh || rh < lh;}

  class Compare_Run_SubRun_EventEntry {
  public:
    bool operator()(FileIndex::Element const& lh, FileIndex::Element const& rh);
  };

  std::ostream&
  operator<< (std::ostream& os, FileIndex const& fileIndex);
}

#endif /* art_Persistency_Provenance_FileIndex_h */

// Local Variables:
// mode: c++
// End:
