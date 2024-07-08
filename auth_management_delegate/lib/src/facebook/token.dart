part of 'delegate.dart';

enum IFacebookAccessTokenType { classic, limited }

abstract class IFacebookAccessToken {
  final String tokenString;
  final IFacebookAccessTokenType type;

  const IFacebookAccessToken({
    required this.tokenString,
    required this.type,
  });
}

class IFacebookLimitedToken extends IFacebookAccessToken {
  final String userId;
  final String userName;
  final String? userEmail;
  final String nonce;

  const IFacebookLimitedToken({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.nonce,
    super.type = IFacebookAccessTokenType.limited,
    required super.tokenString,
  });
}

class IFacebookClassicToken extends IFacebookAccessToken {
  /// DateTime with the expires date of this token
  final DateTime expires;

  /// the facebook user id
  final String userId;

  /// the facebook application Id
  final String applicationId;

  /// list of string with the rejected permission by the user (on Web is null)
  final List<String>? declinedPermissions;

  /// list of string with the approved permission by the user (on Web is null)
  final List<String>? grantedPermissions;

  final String? authenticationToken;

  const IFacebookClassicToken({
    required this.declinedPermissions,
    required this.grantedPermissions,
    required this.userId,
    required this.expires,
    required super.tokenString,
    required this.applicationId,
    this.authenticationToken,
    super.type = IFacebookAccessTokenType.classic,
  });
}
