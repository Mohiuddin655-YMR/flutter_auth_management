part of '../../utils.dart';

class Validator {
  const Validator._();

  static bool equals(Object? value, Object? compareValue) {
    return value.equals(compareValue);
  }

  static bool isMatched(Object matcher, Object value) {
    return Validator.isValidObject(matcher) &&
        matcher.toString() == value.toString();
  }

  static bool isMatchedList(List<String>? matchers, List<String>? values) {
    final booleans = <bool>[];
    matchers ??= [];
    values ??= [];
    final mLength = matchers.length;
    final vLength = values.length;
    if (mLength > 0 && mLength == vLength) {
      for (int index = 0; index < vLength; index++) {
        if (Validator.isMatched(matchers[index], values[index])) {
          booleans.add(true);
        }
      }
    }
    return booleans.length == vLength;
  }

  static bool isChecked(dynamic checker, List<dynamic>? list) {
    return checker != null &&
        list != null &&
        list.isNotEmpty &&
        list.contains(checker);
  }

  static bool isDigit(String? value) {
    return value != null && Regs.numeric.hasMatch(value);
  }

  static bool isLetter(String? value) {
    return value != null && Regs.letter.hasMatch(value);
  }

  static bool isNumeric(String? value) {
    return value != null && double.tryParse(value) != null;
  }

  static bool isValidDay(dynamic day) {
    int current = Converter.toInt(day);
    return (current >= 1) && (current <= 31);
  }

  static bool isValidMonth(dynamic month) {
    int current = Converter.toInt(month);
    return (current >= 1) && (current <= 12);
  }

  static bool isValidYear(dynamic year, int requireAge) {
    int current = Converter.toInt(year);
    int currentYear = DateProvider.currentYear;
    return (current > 1900) &&
        (current < currentYear) &&
        ((currentYear - current) >= requireAge);
  }

  static bool isValidPath(String? path) {
    return path != null && path.isNotEmpty && Regs.path.hasMatch(path);
  }

  static bool isValidPhone(String? phone) {
    return phone != null && phone.isNotEmpty && Regs.phone.hasMatch(phone);
  }

  static bool isValidEmail(String? email) {
    return email != null && email.isNotEmpty && Regs.email.hasMatch(email);
  }

  static bool isValidPassword(String? password, [int minLength = 6]) {
    return password != null &&
        password.isNotEmpty &&
        password.length >= minLength;
  }

  static bool isValidRetypePassword(String? password, String? retypePassword) {
    return isValidPassword(password) && equals(password, retypePassword);
  }

  static bool isValidDigit(String? value) {
    return value != null &&
        value.isNotEmpty &&
        equals(value, Converter.toNumeric(value, true));
  }

  static bool isValidDigitWithLetter(String? value) {
    return value != null &&
        value.isNotEmpty &&
        equals(value, Converter.toDigitWithLetter(value));
  }

  static bool isValidDigitWithPlus(String value) {
    return isValidString(value) &&
        equals(value, Converter.toDigitWithPlus(value));
  }

  static bool isValidLetter(String? value) {
    return value != null &&
        value.isNotEmpty &&
        equals(value, Converter.toLetter(value));
  }

  static bool isValidList(List<dynamic>? list) {
    return list != null && list.isNotEmpty;
  }

  static bool isValidSet<T>(Set<dynamic>? list) {
    return list != null && list.isNotEmpty;
  }

  static bool isValidObject(dynamic value) {
    return value != null;
  }

  static bool isInstance<T>(dynamic value, T instance) {
    return value != null && value.runtimeType == instance.runtimeType;
  }

  static bool isValidString(
    String? value, {
    int maxLength = 0,
    int minLength = 0,
    RegExp? regs,
  }) {
    bool a = value != null &&
        value.isNotEmpty &&
        !equals(value.toLowerCase(), 'null');
    bool b = maxLength <= 0 ? a : a && value.length <= maxLength;
    bool c = b && value.length >= minLength;
    bool d = regs != null ? regs.hasMatch(value ?? '') : c;
    return d;
  }

  static bool isValidStrings(
    List<String> values, {
    int maxLength = 0,
    int minLength = 0,
    RegExp? regs,
  }) {
    List<bool> list = [];
    for (String value in values) {
      if (Validator.isValidString(
        value,
        maxLength: maxLength,
        minLength: minLength,
        regs: regs,
      )) {
        list.add(true);
      }
    }
    return list.length == values.length;
  }

  static bool isValidWebURL(String? url) {
    return url != null && url.isNotEmpty && Regs.url.hasMatch(url);
  }

  static bool isRank(double rating, double min) {
    return rating >= min;
  }
}

extension ValidatorObjectExtension on Object? {
  bool equals(dynamic compareValue) {
    return this == compareValue;
  }
}
