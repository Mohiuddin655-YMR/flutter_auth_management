part of 'delegate.dart';

enum IAppleCredentialState {
  /// The user is authorized.
  authorized,

  /// Authorization for the given user has been revoked.
  revoked,

  /// The user wasn't found.
  notFound,
}
