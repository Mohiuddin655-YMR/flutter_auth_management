part of 'delegate.dart';

/// this class is used to saved the granted and declined permissions after login
class IFacebookPermissions {
  /// save the granted permissions by the user
  final List<String> granted;

  /// save the declined permissions by the user
  final List<String> declined;

  const IFacebookPermissions({
    required this.granted,
    required this.declined,
  });
}
