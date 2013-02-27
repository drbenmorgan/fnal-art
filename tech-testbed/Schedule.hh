#ifndef tech_testbed_Schedule_hh
#define tech_testbed_Schedule_hh

#include "cetlib/exempt_ptr.h"
#include "tech-testbed/EventPrincipal.hh"

#include "tbb/tick_count.h"

#include <cstdint>
#include <memory>
#include <random>

namespace demo {
  class Schedule;

  typedef uint16_t ScheduleID;
}

class demo::Schedule {
public:
  Schedule(ScheduleID sID,
           unsigned int seed,
           size_t scale);

  ScheduleID id() const;
  size_t eventsProcessed() const;
  size_t itemsGenerated() const;
  tbb::tick_count::interval_t timeTaken() const;

  void operator()(std::unique_ptr<EventPrincipal> && ep);

private:
  ScheduleID const sID_;
  std::mt19937_64 engine_;
  std::gamma_distribution<double> dist_;
  size_t eventsProcessed_;
  size_t items_;
  tbb::tick_count::interval_t timeTaken_;
};
#endif /* tech_testbed_Schedule_hh */
