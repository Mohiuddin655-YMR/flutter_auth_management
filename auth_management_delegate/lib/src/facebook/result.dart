part of 'delegate.dart';

enum IFacebookLoginStatus { success, cancelled, failed, operationInProgress }

/// class to handle a login request
class IFacebookLoginResult {
  /// contain status of a previous login request
  final IFacebookLoginStatus status;

  /// contain a message when the login request fail
  final String? message;

  /// contain the access token information for the current session
  /// this will be null when the login request fail
  final IFacebookAccessToken? accessToken;

  const IFacebookLoginResult({
    required this.status,
    this.message,
    this.accessToken,
  });
}
