#include "art/Persistency/Provenance/FileIndex.h"
#include "art/Utilities/Algorithms.h"

#include <algorithm>
#include <ostream>
#include <iomanip>

namespace edm {

  FileIndex::FileIndex() : entries_(), transients_() {}

  // The default value for sortState_ reflects the fact that
  // the index is always sorted using Run, SubRun, and Event
  // number by the PoolOutputModule before being written out.
  // In the other case when we create a new FileIndex, the
  // vector is empty, which is consistent with it having been
  // sorted.

  FileIndex::Transients::Transients() : allInEntryOrder_(false), resultCached_(false), sortState_(kSorted_Run_SubRun_Event) {}

  void
  FileIndex::addEntry(RunNumber_t run, SubRunNumber_t lumi, EventNumber_t event, EntryNumber_t entry) {
    entries_.push_back(FileIndex::Element(run, lumi, event, entry));
    resultCached() = false;
    sortState() = kNotSorted;
  }

  void FileIndex::sortBy_Run_SubRun_Event() {
    stable_sort_all(entries_);
    resultCached() = false;
    sortState() = kSorted_Run_SubRun_Event;
  }

  void FileIndex::sortBy_Run_SubRun_EventEntry() {
    stable_sort_all(entries_, Compare_Run_SubRun_EventEntry());
    resultCached() = false;
    sortState() = kSorted_Run_SubRun_EventEntry;
  }

  bool FileIndex::allEventsInEntryOrder() const {
    if (!resultCached()) {
      resultCached() = true;
      EntryNumber_t maxEntry = Element::invalidEntry;
      for (std::vector<FileIndex::Element>::const_iterator it = entries_.begin(), itEnd = entries_.end(); it != itEnd; ++it) {
        if (it->getEntryType() == kEvent) {
	  if (it->entry_ < maxEntry) {
	    allInEntryOrder() = false;
	    return false;
          }
	  maxEntry = it->entry_;
        }
      }
      allInEntryOrder() = true;
      return true;
    }
    return allInEntryOrder();
  }

  bool FileIndex::eventsUniqueAndOrdered() const {

    const_iterator it = begin();
    const_iterator itEnd = end();

    // Set up the iterators to point to first two events
    // (In the trivial case where there is zero or one event,
    // the set must be unique and ordered)

    if (it == itEnd) return true;

    // Step to first event
    while (it->getEntryType() != kEvent) {
      ++it;
      if (it == itEnd) return true;
    }
    const_iterator itPrevious = it;

    // Step to second event
    ++it;
    if (it == itEnd) return true;
    while (it->getEntryType() != kEvent) {
      ++it;
      if (it == itEnd) return true;
    }

    for ( ; it != itEnd; ++it) {
      if (it->getEntryType() == kEvent) {
        if (it->run_ < itPrevious->run_) return false;  // not ordered
        else if (it->run_ == itPrevious->run_) {
          if (it->event_ < itPrevious->event_) return false; // not ordered
          if (it->event_ == itPrevious->event_) return false; // found duplicate
        }
        itPrevious = it;
      }
    }
    return true; // finished and found no duplicates
  }

  FileIndex::const_iterator
  FileIndex::findPosition(RunNumber_t run, SubRunNumber_t lumi, EventNumber_t event) const {

    assert(sortState() == kSorted_Run_SubRun_Event);

    Element el(run, lumi, event);
    const_iterator it = lower_bound_all(entries_, el);
    bool lumiMissing = (lumi == 0 && event != 0);
    if (lumiMissing) {
      const_iterator itEnd = entries_.end();
      while (it->event_ < event && it->run_ <= run && it != itEnd) ++it;
    }
    return it;
  }

  FileIndex::const_iterator
  FileIndex::findEventPosition(RunNumber_t run, SubRunNumber_t lumi, EventNumber_t event, bool exact) const {

    assert(sortState() == kSorted_Run_SubRun_Event);

    const_iterator it = findPosition(run, lumi, event);
    const_iterator itEnd = entries_.end();
    while (it != itEnd && it->getEntryType() != FileIndex::kEvent) {
      ++it;
    }
    if (it == itEnd) return itEnd;
    if (lumi == 0) lumi = it->lumi_;
    if (exact && (it->run_ != run || it->lumi_ != lumi || it->event_ != event)) return itEnd;
    return it;
  }

  FileIndex::const_iterator
  FileIndex::findSubRunPosition(RunNumber_t run, SubRunNumber_t lumi, bool exact) const {
    assert(sortState() != kNotSorted);
    const_iterator it;
    if (sortState() == kSorted_Run_SubRun_EventEntry) {
      Element el(run, lumi, 0U);
      it = lower_bound_all(entries_, el, Compare_Run_SubRun_EventEntry());
    }
    else {
      it = findPosition(run, lumi, 0U);
    }
    const_iterator itEnd = entries_.end();
    while (it != itEnd && it->getEntryType() != FileIndex::kSubRun) {
      ++it;
    }
    if (it == itEnd) return itEnd;
    if (exact && (it->run_ != run || it->lumi_ != lumi)) return itEnd;
    return it;
  }

  FileIndex::const_iterator
  FileIndex::findRunPosition(RunNumber_t run, bool exact) const {
    assert(sortState() != kNotSorted);
    const_iterator it;
    if (sortState() == kSorted_Run_SubRun_EventEntry) {
      Element el(run, 0U, 0U);
      it = lower_bound_all(entries_, el, Compare_Run_SubRun_EventEntry());
    }
    else {
      it = findPosition(run, 0U, 0U);
    }
    const_iterator itEnd = entries_.end();
    while (it != itEnd && it->getEntryType() != FileIndex::kRun) {
      ++it;
    }
    if (it == itEnd) return itEnd;
    if (exact && (it->run_ != run)) return itEnd;
    return it;
  }

  FileIndex::const_iterator
  FileIndex::findSubRunOrRunPosition(RunNumber_t run, SubRunNumber_t lumi) const {
    assert(sortState() != kNotSorted);
    const_iterator it;
    if (sortState() == kSorted_Run_SubRun_EventEntry) {
      Element el(run, lumi, 0U);
      it = lower_bound_all(entries_, el, Compare_Run_SubRun_EventEntry());
    }
    else {
      it = findPosition(run, lumi, 0U);
    }
    const_iterator itEnd = entries_.end();
    while (it != itEnd && it->getEntryType() != FileIndex::kSubRun && it->getEntryType() != FileIndex::kRun) {
      ++it;
    }
    return it;
  }

  bool operator<(FileIndex::Element const& lh, FileIndex::Element const& rh) {
    if(lh.run_ == rh.run_) {
      if(lh.lumi_ == rh.lumi_) {
	return lh.event_ < rh.event_;
      }
      return lh.lumi_ < rh.lumi_;
    }
    return lh.run_ < rh.run_;
  }

  bool Compare_Run_SubRun_EventEntry::operator()(FileIndex::Element const& lh, FileIndex::Element const& rh)
  {
    if(lh.run_ == rh.run_) {
      if(lh.lumi_ == rh.lumi_) {
        if (lh.event_ == 0U && rh.event_ == 0U) return false;
        else if (lh.event_ == 0U) return true;
        else if (rh.event_ == 0U) return false;
	else return lh.entry_ < rh.entry_;
      }
      return lh.lumi_ < rh.lumi_;
    }
    return lh.run_ < rh.run_;
  }

  std::ostream&
  operator<< (std::ostream& os, FileIndex const& fileIndex) {

    os << "\nPrinting FileIndex contents.  This includes a list of all Runs, SubRuns\n"
       << "and Events stored in the root file.\n\n";
    os << std::setw(15) << "Run"
       << std::setw(15) << "SubRun"
       << std::setw(15) << "Event"
       << std::setw(15) << "TTree Entry"
       << "\n";
    for (std::vector<FileIndex::Element>::const_iterator it = fileIndex.begin(), itEnd = fileIndex.end(); it != itEnd; ++it) {
      if (it->getEntryType() == FileIndex::kEvent) {
        os << std::setw(15) << it->run_
           << std::setw(15) << it ->lumi_
           << std::setw(15) << it->event_
           << std::setw(15) << it->entry_
           << "\n";
      }
      else if (it->getEntryType() == FileIndex::kSubRun) {
        os << std::setw(15) << it->run_
           << std::setw(15) << it ->lumi_
           << std::setw(15) << " "
           << std::setw(15) << it->entry_ << "  (SubRun)"
           << "\n";
      }
      else if (it->getEntryType() == FileIndex::kRun) {
        os << std::setw(15) << it->run_
           << std::setw(15) << " "
           << std::setw(15) << " "
           << std::setw(15) << it->entry_ << "  (Run)"
           << "\n";
      }
    }
    return os;
  }
}
