part of '../../utils.dart';

class DateProvider {
  const DateProvider._();

  static int get currentMS {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static int get currentDay {
    return DateTime.now().day;
  }

  static int get currentMonth {
    return DateTime.now().month;
  }

  static int get currentYear {
    return DateTime.now().year;
  }

  static int toDay(int timeMills) {
    return DateTime.fromMillisecondsSinceEpoch(timeMills).day;
  }

  static int toMonth(int timeMills) {
    return DateTime.fromMillisecondsSinceEpoch(timeMills).month;
  }

  static int toYear(int timeMills) {
    return DateTime.fromMillisecondsSinceEpoch(timeMills).year;
  }

  static String toDate(
    int ms, {
    String? format,
    String? local,
    TimeFormats? timeFormat,
    DateFormats dateFormat = DateFormats.dateDMCY,
    String? separator,
  }) {
    return ms.toDate(
      format: format,
      local: local,
      timeFormat: timeFormat,
      dateFormat: dateFormat,
      separator: separator,
    );
  }

  static String toDateFromUTC(
    int year,
    int month,
    int day, [
    TimeFormats timeFormat = TimeFormats.none,
    DateFormats dateFormat = DateFormats.none,
    String? pattern,
    String separator = "",
    String? local,
  ]) {
    if ((year + month + day) > 0) {
      return DateTime.utc(year, month, day).toDate(
        timeFormat: timeFormat,
        dateFormat: dateFormat,
        format: pattern,
        separator: separator,
        local: local,
      );
    } else {
      return '';
    }
  }

  static int toMSFromUTC(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
  ]) {
    return DateTime.utc(
      year,
      month - 1,
      day,
      hour,
      minute,
      second,
    ).millisecond;
  }

  static int toMSFromSource(String? source) {
    return DateTime.tryParse(source ?? "")?.millisecond ?? 0;
  }

  static bool isToday(int? ms) => ms.isToday;

  static bool isTomorrow(int? ms) => ms.isTomorrow;

  static bool isYesterday(int? ms) => ms.isYesterday;

  static String activeTime(int? ms) => ms.liveTime;

  static String toRealStatus(
    int ms, {
    TimeFormats timeFormat = TimeFormats.timeHMa,
    DateFormats dateFormat = DateFormats.dateDMCY,
    String? pattern,
    String separator = " at ",
    String? local,
    String Function(int value)? onPrepareBySecond,
    String Function(int value)? onPrepareByMinute,
    String Function(int value)? onPrepareByHour,
    String Function(int value)? onPrepareByDay,
  }) {
    return ms.toLiveTime(
      timeFormat: timeFormat,
      dateFormat: dateFormat,
      format: pattern,
      separator: separator,
      local: local,
      onPrepareBySecond: onPrepareBySecond,
      onPrepareByMinute: onPrepareByMinute,
      onPrepareByHour: onPrepareByHour,
      onPrepareByDay: onPrepareByDay,
    );
  }
}

enum TimeFormats {
  hour("hh"),
  minute("mm"),
  second("ss"),
  zone("TZD"),
  timeMS("mm:ss"),
  timeHM("hh:mm"),
  timeHMa("hh:mm a"),
  timeHMSa("hh:mm:ss a"),
  timeHMSZone("hh:mm:ss TZD"),
  none("");

  final String value;

  const TimeFormats(this.value);
}

enum DateFormats {
  day("dd"),
  dayFullName("EEEE"),
  dayShortName("EE"),
  month("MM"),
  monthFullName("MMMM"),
  monthShortName("MMM"),
  yearFull("yyyy"),
  yearShort("yy"),
  dateDMY("dd-MM-yyyy"),
  dateDMCY("dd MMMM, yyyy"),
  dateMDCY("MMMM dd, yyyy"),
  dateYMD("yyyy-MM-dd"),
  dateECDMCY("EEEE, dd MMMM, yyyy"),
  dateECMDCY("EEEE, dd MMMM, yyyy"),
  none("");

  final String value;

  const DateFormats(this.value);
}

extension TimeFormatExtension on TimeFormats? {
  String get use => this?.value ?? "";

  bool get isUsable => use.isNotEmpty;
}

extension DateFormatExtension on DateFormats? {
  String get use => this?.value ?? "";

  bool get isUsable => use.isNotEmpty;
}

extension TimeExtension on int? {
  int get _v => this ?? 0;

  bool get isToday => DateTime.fromMillisecondsSinceEpoch(_v).isToday;

  bool get isTomorrow => DateTime.fromMillisecondsSinceEpoch(_v).isTomorrow;

  bool get isYesterday => DateTime.fromMillisecondsSinceEpoch(_v).isYesterday;

  String get liveTime => toLiveTime();

  String toDate({
    String? format,
    String? local,
    TimeFormats? timeFormat,
    DateFormats dateFormat = DateFormats.dateDMCY,
    String? separator,
  }) {
    return DateTime.fromMillisecondsSinceEpoch(_v).toDate(
      timeFormat: timeFormat,
      dateFormat: dateFormat,
      format: format,
      separator: separator,
      local: local,
    );
  }

  String toLiveTime({
    TimeFormats timeFormat = TimeFormats.timeHMa,
    DateFormats dateFormat = DateFormats.dateDMCY,
    String? format,
    String separator = " at ",
    String? local,
    String Function(int value)? onPrepareBySecond,
    String Function(int value)? onPrepareByMinute,
    String Function(int value)? onPrepareByHour,
    String Function(int value)? onPrepareByDay,
  }) {
    return DateTime.fromMillisecondsSinceEpoch(_v).toLiveTime(
      timeFormat: timeFormat,
      dateFormat: dateFormat,
      format: format,
      separator: separator,
      local: local,
      onPrepareBySecond: onPrepareBySecond,
      onPrepareByMinute: onPrepareByMinute,
      onPrepareByHour: onPrepareByHour,
      onPrepareByDay: onPrepareByDay,
    );
  }
}

extension DateExtension on DateTime? {
  DateTime get _v => this ?? DateTime.now();

  bool get isToday => isDay(DateTime.now());

  bool get isNow => isDay(DateTime.now());

  bool get isTomorrow {
    return isDay(DateTime.now().add(const Duration(days: 1)));
  }

  bool get isYesterday {
    return isDay(DateTime.now().subtract(const Duration(days: 1)));
  }

  String get liveTime => toLiveTime();

  bool isDay(DateTime now) {
    return now.day == _v.day && now.month == _v.month && now.year == _v.year;
  }

  String toDate({
    String? format,
    String? local,
    TimeFormats? timeFormat,
    DateFormats dateFormat = DateFormats.dateDMCY,
    String? separator,
  }) {
    if ((format ?? "").isEmpty) {
      if (timeFormat.isUsable && dateFormat.isUsable) {
        format = "${dateFormat.use}'${separator ?? ' '}'${timeFormat.use}";
      } else if (timeFormat.isUsable) {
        format = timeFormat.use;
      } else {
        format = dateFormat.use;
      }
    }
    return DateFormat(format, local).format(_v);
  }

  String toLiveTime({
    String? format,
    String? local,
    TimeFormats timeFormat = TimeFormats.timeHMa,
    DateFormats dateFormat = DateFormats.dateDMCY,
    String separator = " at ",
    String Function(int value)? onPrepareBySecond,
    String Function(int value)? onPrepareByMinute,
    String Function(int value)? onPrepareByHour,
    String Function(int value)? onPrepareByDay,
  }) {
    var time = _v;
    var difference = DateTime.now().difference(time);
    int days = difference.inDays;
    int hours = difference.inHours;
    int minutes = difference.inMinutes;
    int seconds = difference.inSeconds;

    if (days > 0) {
      if (onPrepareByDay != null) {
        return onPrepareByDay(days);
      } else {
        if (time.isYesterday) {
          return "Yesterday$separator${time.toDate(
            timeFormat: timeFormat,
            local: local,
          )}";
        } else {
          return time.toDate(
            timeFormat: timeFormat,
            dateFormat: dateFormat,
            format: format,
            separator: separator,
            local: local,
          );
        }
      }
    } else {
      if (hours > 0) {
        if (hours < 12) {
          return onPrepareByHour?.call(hours) ??
              "$hours ${hours > 1 ? "hours" : "hour"} ago";
        } else {
          return "Today$separator${time.toDate(
            timeFormat: timeFormat,
            local: local,
          )}";
        }
      } else {
        if (minutes > 0) {
          return onPrepareByMinute?.call(minutes) ??
              "$minutes ${minutes > 1 ? "minutes" : "minute"} ago";
        } else {
          if (seconds > 0) {
            return onPrepareBySecond?.call(seconds) ?? "Now";
          } else {
            if (time.isTomorrow) {
              return "Tomorrow$separator${time.toDate(
                timeFormat: timeFormat,
                local: local,
              )}";
            } else {
              return time.toDate(
                timeFormat: timeFormat,
                dateFormat: dateFormat,
                format: format,
                separator: separator,
                local: local,
              );
            }
          }
        }
      }
    }
  }
}
