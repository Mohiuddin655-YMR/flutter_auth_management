part of '../../utils.dart';

class Converter {
  const Converter._();

  static String modify() {
    return "";
  }

  static String asString(List<String> list) {
    String buffer = '';
    if (list.isNotEmpty) {
      int size = list.length;
      int end = size - 1;
      int and = size - 2;
      for (int index = 0; index < size; index++) {
        if (index == and) {
          buffer = '$buffer${list[index]} and ';
        } else if (index == end) {
          buffer = '$buffer${list[index]}';
        } else {
          buffer = '$buffer${list[index]}, ';
        }
      }
    }
    return buffer;
  }

  static int toCountingNumber(List<dynamic>? list) =>
      list != null && list.isNotEmpty ? list.length : 0;

  static String toCountingState(
    int current,
    int total, [
    String separator = "/",
  ]) {
    return "$current$separator$total";
  }

  static String toCountingText(List<dynamic>? list) =>
      list != null && list.isNotEmpty ? "${list.length}" : "0";

  static String toCountingWithPlus(int size, int limit) =>
      size > limit ? "$limit+" : "$size";

  static String toLetter(String? value) {
    String buffer = '';

    if (value != null) {
      for (String character in value.characters) {
        if (Validator.isLetter(character)) {
          buffer = '$buffer$character';
        }
      }
    }

    return buffer;
  }

  static String toDigitWithLetter(String? value) {
    String buffer = '';

    if (value != null) {
      for (String character in value.characters) {
        if (Validator.isDigit(character) || Validator.isLetter(character)) {
          buffer = '$buffer$character';
        }
      }
    }

    return buffer;
  }

  static String toDigitWithPlus(String? value) {
    String buffer = '';

    if (value != null) {
      for (String character in value.characters) {
        if (character == '+' || Validator.isDigit(character)) {
          buffer = '$buffer$character';
        }
      }
    }

    return buffer;
  }

  static double toDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }

  static int toInt(dynamic value) {
    if (value is String) {
      return int.tryParse(value) ?? 0;
    } else if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else {
      return 0;
    }
  }

  static String toKMB(
    int counter,
    String singularName,
    String pluralName, [
    Counter counterType = Counter.kmb,
  ]) {
    if (counter > 1) {
      switch (counterType) {
        case Counter.k:
          return "${Counter.toKCount(counter)} $pluralName";
        case Counter.km:
          return "${Counter.toKMCount(counter)} $pluralName";
        case Counter.kmb:
        default:
          return "${Counter.toKMBCount(counter)} $pluralName";
      }
    } else {
      return "$counter $singularName";
    }
  }

  static String toKMBFromList(
    List<dynamic> list,
    String singularName,
    String pluralName, [
    Counter counterType = Counter.kmb,
  ]) {
    return toKMB(list.length, singularName, pluralName, counterType);
  }

  static List<T> toList<T>({
    List<dynamic>? list,
    String? value,
    String regex = ",",
  }) {
    if (list != null && list.isNotEmpty && list.first is T) {
      return list.cast<T>();
    } else if (value != null) {
      return value.split(regex).cast<T>();
    } else {
      return [];
    }
  }

  static String? toMail(
    String prefix,
    String suffix, [
    String type = "com",
  ]) {
    final String mail = "$prefix@$suffix.$type";
    return Validator.isValidEmail(mail) ? mail : null;
  }

  static String toNumeric(String? value, [bool onlyDigit = false]) {
    String buffer = '';

    if (value != null) {
      for (String character in value.characters) {
        if (onlyDigit
            ? Validator.isDigit(character)
            : Validator.isNumeric(character)) {
          buffer = '$buffer$character';
        }
      }
    }

    return buffer;
  }

  static List<String> toPathSegments(String path) =>
      toList(value: path, regex: "/");

  static List<T> toReversedList<T>(List<T> list) => list.reversed.toList();

  static Set<T>? toSet<T>(List<T> list) =>
      list.isNotEmpty ? Set.from(list) : null;

  static Uri toUri(String url) => Uri.parse(url);

  static String toUserName(
    String name, {
    List<String>? regexList,
    List<String>? replacements,
  }) {
    final String current = Replacement.auto(name).toLowerCase();
    if (replacements != null) {
      return Replacement.multiple(current, replacements, regexList ?? []);
    } else {
      return Replacement.single(current, "", regexList);
    }
  }

  static T? toValue<T>(dynamic value) => value is T ? value : null;
}
