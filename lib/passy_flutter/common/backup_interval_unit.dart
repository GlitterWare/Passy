enum BackupIntervalUnit {
  years,
  months,
  weeks,
  days,
  hours,
  minutes,
  seconds,
}

abstract class BackupIntervalUnitsInMilliseconds {
  static const int year = 31556952000;
  static const int month = 2629746000;
  static const int week = 604800000;
  static const int day = 86400000;
  static const int hour = 3600000;
  static const int minute = 60000;
  static const int second = 1000;

  static int getByUnit(BackupIntervalUnit unit) {
    switch (unit) {
      case BackupIntervalUnit.years:
        return year;
      case BackupIntervalUnit.months:
        return month;
      case BackupIntervalUnit.weeks:
        return week;
      case BackupIntervalUnit.days:
        return day;
      case BackupIntervalUnit.hours:
        return hour;
      case BackupIntervalUnit.minutes:
        return minute;
      case BackupIntervalUnit.seconds:
        return second;
    }
  }
}
