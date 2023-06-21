part of '../../utils.dart';

enum Counter {
  k,
  km,
  kmb;

  static String toKCount(int value) => value.toKCount;

  static String toKMCount(int value) => value.toKMCount;

  static String toKMBCount(int value) => value.toKMBCount;
}

extension CounterExtension on int {
  String get toKCount {
    if (this >= 1000) {
      return "${this ~/ 1000}K";
    }

    return "$this";
  }

  String get toKMCount {
    if (this >= 1000 && this < 1000000) {
      return "${this ~/ 1000}K";
    }

    if (this >= 1000000) {
      return "${this ~/ 1000000}M";
    }

    return "$this";
  }

  String get toKMBCount {
    if (this >= 1000 && this < 1000000) {
      return "${this ~/ 1000}K";
    }

    if (this >= 1000000 && this < 1000000000) {
      return "${this ~/ 1000000}M";
    }

    if (this >= 1000000000) {
      return "${this ~/ 1000000000}B";
    }

    return "$this";
  }
}
