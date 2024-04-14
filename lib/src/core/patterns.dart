class AuthPatterns {
  static final RegExp email = RegExp(AuthRegs.email.value);
  static final RegExp phone = RegExp(AuthRegs.phone3.value);
  static final RegExp username = RegExp(AuthRegs.username.value);
  static final RegExp usernameWithDot = RegExp(AuthRegs.usernameWithDot.value);
}

enum AuthRegs {
  email(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"),
  username(r"^[a-zA-Z0-9_]{3,16}$"),
  usernameWithDot(r"^[a-zA-Z0-9_.]{3,16}$"),
  phone(r'^[+]*[(]{0,1}[0-9]{1,4}+$'),
  phone2(r'^(?:[+0][1-9])?[0-9]{10,12}$'),
  phone3(r'^\+?[0-9]{7,15}$');

  const AuthRegs(this.value);

  final String value;
}
