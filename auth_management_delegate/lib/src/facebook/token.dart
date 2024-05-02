part of 'delegate.dart';

class IFacebookAccessToken {
  /// DateTime with the expires date of this token
  final DateTime expires;

  /// DateTime with the last refresh date of this token
  final DateTime lastRefresh;

  /// the facebook user id
  final String userId;

  /// token provided by facebook to make api calls to the GRAPH API
  final String token;

  /// the facebook application Id
  final String applicationId;

  /// the graph Domain name returned by facebook
  final String? graphDomain;

  /// list of string with the rejected permission by the user (on Web is null)
  final List<String>? declinedPermissions;

  /// list of string with the approved permission by the user (on Web is null)
  final List<String>? grantedPermissions;

  /// is `true` when the token is expired
  final bool isExpired;

  /// DateTime with the date at which user data access expires
  final DateTime dataAccessExpirationTime;

  const IFacebookAccessToken({
    required this.declinedPermissions,
    required this.grantedPermissions,
    required this.userId,
    required this.expires,
    required this.lastRefresh,
    required this.token,
    required this.applicationId,
    this.graphDomain,
    required this.isExpired,
    required this.dataAccessExpirationTime,
  });
}
