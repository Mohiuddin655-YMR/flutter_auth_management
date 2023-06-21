part of '../../utils.dart';

class Replacement {
  const Replacement._();

  static String auto(String value) {
    for (int index = 0; index < value.length; index++) {
      for (String reg in Regex.none) {
        value = value.replaceAll(reg, "");
      }
      for (String s in Regex.slash) {
        value = value.replaceAll(s, "_");
      }
    }
    return value;
  }

  static String single(
    String value,
    String replacement,
    List<String>? regex,
  ) {
    if (regex != null && regex.isNotEmpty) {
      for (String reg in regex) {
        value = value.replaceAll(reg, replacement);
      }
    }
    return value;
  }

  static String multiple(
    String value,
    List<String> replacements,
    List<String> regex,
  ) {
    final valid = Validator.isMatched(regex.length, replacements.length);
    if (regex.isNotEmpty && valid) {
      for (int index = 0; index < value.length; index++) {
        value = value.replaceAll(regex[index], replacements[index]);
      }
    }
    return value;
  }
}

class Regex {
  static const List<String> none = [
    "!",
    "@",
    "#",
    "\$",
    "^",
    "*",
    "+",
    "=",
    "{",
    "}",
    "[",
    "]",
    "\\",
    "|",
    ":",
    ";",
    "<",
    ">",
    "?",
    "/",
    "%",
    "(",
    ")",
    ".",
  ];

  static const List<String> slash = [
    " ",
    "\"",
    "'",
    ",",
    "-",
    "&",
  ];
}
