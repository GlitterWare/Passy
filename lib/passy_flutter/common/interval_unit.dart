enum IntervalUnit {
  years,
  months,
  weeks,
  days,
  hours,
  minutes,
  seconds,
}

abstract class IntervalUnitsInMilliseconds {
  static const int year = 31556952000;
  static const int month = 2629746000;
  static const int week = 604800000;
  static const int day = 86400000;
  static const int hour = 3600000;
  static const int minute = 60000;
  static const int second = 1000;

  static int getByUnit(IntervalUnit unit) {
    switch (unit) {
      case IntervalUnit.years:
        return year;
      case IntervalUnit.months:
        return month;
      case IntervalUnit.weeks:
        return week;
      case IntervalUnit.days:
        return day;
      case IntervalUnit.hours:
        return hour;
      case IntervalUnit.minutes:
        return minute;
      case IntervalUnit.seconds:
        return second;
    }
  }
}
