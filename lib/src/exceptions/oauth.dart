class AuthDelegateException {
  final String name;

  const AuthDelegateException(this.name);

  String get message {
    return "$name currently not initialized\n"
        "You can initialize like this:\n\n"
        '''
        ...
        
        Step-1: Add dependencies
        ```yaml
        auth_management_apple_delegate: ^x.y.z
        auth_management_biometric_delegate: ^x.y.z
        auth_management_facebook_delegate: ^x.y.z
        auth_management_google_delegate: ^x.y.z
        ```
        
        Step-2: import necessary dependencies
        ```dart
        import 'package:auth_management_apple_delegate/auth_management_apple_delegate.dart';
        import 'package:auth_management_biometric_delegate/auth_management_biometric_delegate.dart';
        import 'package:auth_management_facebook_delegate/auth_management_facebook_delegate.dart';
        import 'package:auth_management_google_delegate/auth_management_google_delegate.dart';
        ```
        
        Step-3: Add delegate as you like in application root level
        ```dart
        AuthProvider<UserModel>(
          initialCheck: true,
          controller: AuthController.getInstance<UserModel>(
            backup: UserBackupDelegate(), // as BackupDelegate
            oauth: OAuthDelegates(
              appleAuthDelegate: AppleAuthDelegate(), // as IAppleAuthDelegate
              biometricAuthDelegate: BiometricAuthDelegate(), // as IBiometricAuthDelegate
              facebookAuthDelegate: FacebookAuthDelegate(), // as IFacebookAuthDelegate
              googleAuthDelegate: GoogleAuthDelegate(), // as IGoogleAuthDelegate
            ),
          ),
          child: const MaterialApp(
            // ...
          ),
        )
        ````
        ''';
  }
}
