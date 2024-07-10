import '../auth/auth_credential.dart';
import '../auth/auth_provider.dart';

const _kLinkProviderId = 'emailLink';
const _kProviderId = 'password';

abstract class EmailAuthProvider extends IAuthProvider {
  const EmailAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static String get EMAIL_LINK_SIGN_IN_METHOD {
    return _kLinkProviderId;
  }

  static String get EMAIL_PASSWORD_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  static IAuthCredential credential({
    required String email,
    required String password,
    String? providerId,
  }) {
    return EmailAuthCredential._credential(
      email,
      password,
    );
  }

  static IAuthCredential credentialWithLink({
    required String email,
    required String emailLink,
  }) {
    return EmailAuthCredential._credentialWithLink(email, emailLink);
  }
}

class EmailAuthCredential extends IAuthCredential {
  final String email;
  final String? password;
  final String? emailLink;

  const EmailAuthCredential._(
    String signInMethod, {
    required this.email,
    this.password,
    this.emailLink,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: signInMethod,
        );

  factory EmailAuthCredential._credential(
    String email,
    String password, {
    String? providerId,
  }) {
    return EmailAuthCredential._(
      providerId: providerId,
      providerId ?? _kProviderId,
      email: email,
      password: password,
    );
  }

  factory EmailAuthCredential._credentialWithLink(
    String email,
    String emailLink, {
    String? providerId,
  }) {
    return EmailAuthCredential._(
      _kLinkProviderId,
      email: email,
      emailLink: emailLink,
      providerId: providerId,
    );
  }
}
