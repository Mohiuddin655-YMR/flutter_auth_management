part of 'controllers.dart';

typedef IdentityBuilder = String Function(String uid);
typedef SignOutCallback = Future Function(Auth);

class AuthController extends Cubit<AuthResponse> {
  final AuthMessages _msg;
  final AuthHandler authHandler;
  final BackupHandler backupHandler;

  AuthController({
    AuthHandler? authHandler,
    BackupHandler? backupHandler,
    AuthMessages? messages,
  })  : _msg = messages ?? const AuthMessages(),
        authHandler = authHandler ?? AuthHandlerImpl(),
        backupHandler = backupHandler ?? BackupHandlerImpl(),
        super(AuthResponse.initial());

  String get uid => user?.uid ?? "uid";

  User? get user => FirebaseAuth.instance.currentUser;

  Future isLoggedIn([AuthProvider? provider]) async {
    try {
      emit(AuthResponse.loading(provider, _msg.loading));
      final signedIn = await authHandler.isSignIn(provider);
      if (signedIn) {
        emit(AuthResponse.authenticated(
          state.data,
          _msg.loggedIn.done,
        ));
      } else {
        emit(AuthResponse.unauthenticated(
          _msg.loggedOut.done,
        ));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.loggedIn.failure ?? _));
    }
  }

  Future signInByApple({
    Auth? authenticator,
    bool biometric = false,
  }) async {
    emit(AuthResponse.loading(AuthProvider.apple, _msg.loading));
    try {
      final response = await authHandler.signInWithApple();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Auth()).copy(
            biometric: biometric,
            accessToken: biometric ? result.accessToken : null,
            idToken: biometric ? result.idToken : null,
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.apple.name,
          );
          await backupHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signInWithApple.done,
          ));
        } else {
          emit(AuthResponse.failure(
            _msg.signInWithApple.failure ?? finalResponse.exception,
          ));
        }
      } else {
        emit(AuthResponse.failure(
          _msg.signInWithApple.failure ?? response.exception,
        ));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.signInWithApple.failure ?? _));
    }
  }

  Future signInByBiometric() async {
    emit(AuthResponse.loading(AuthProvider.biometric, _msg.loading));
    try {
      final user = await backupHandler.getCache();
      if (user.biometric) {
        final response = await authHandler.signInWithBiometric();
        if (response.isSuccessful) {
          final token = user.accessToken;
          final provider = user.provider;
          var loginResponse = Response();
          if ((user.email.isValid || user.username.isValid) &&
              user.password.isValid) {
            if (provider.isEmail) {
              loginResponse = await authHandler.signInWithEmailNPassword(
                email: user.email ?? "example@gmail.com",
                password: user.password ?? "password",
              );
            } else if (provider.isUsername) {
              loginResponse = await authHandler.signInWithUsernameNPassword(
                username: user.username ?? "username",
                password: user.password ?? "password",
              );
            }
          } else if (token.isValid || user.idToken.isValid) {
            if (provider.isApple) {
              loginResponse = await authHandler.signUpWithCredential(
                credential: AppleAuthProvider.credential(token.use),
              );
            } else if (provider.isFacebook) {
              loginResponse = await authHandler.signUpWithCredential(
                credential: FacebookAuthProvider.credential(token.use),
              );
            } else if (provider.isGoogle) {
              loginResponse = await authHandler.signUpWithCredential(
                credential: GoogleAuthProvider.credential(
                  idToken: user.idToken,
                  accessToken: token,
                ),
              );
            }
          }
          if (loginResponse.isSuccessful) {
            emit(AuthResponse.authenticated(
              user,
              _msg.signInWithBiometric.done,
            ));
          } else {
            emit(AuthResponse.failure(
              _msg.signInWithBiometric.failure ?? loginResponse.exception,
            ));
          }
        } else {
          emit(AuthResponse.failure(
            _msg.signInWithBiometric.failure ?? response.exception,
          ));
        }
      } else {
        emit(AuthResponse.failure(
          _msg.signInWithBiometric.failure ?? "Biometric not initialized!",
        ));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.signInWithBiometric.failure ?? _));
    }
  }

  Future signInByEmail(
    EmailAuthenticator authenticator, {
    bool biometric = false,
  }) async {
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      emit(AuthResponse.failure("Email isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email, _msg.loading));
      try {
        final response = await authHandler.signInWithEmailNPassword(
          email: email,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              biometric: biometric,
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            );
            await backupHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signInWithEmail.done,
            ));
          } else {
            emit(AuthResponse.failure(
              _msg.signInWithEmail.failure ?? response.message,
            ));
          }
        } else {
          emit(AuthResponse.failure(
            _msg.signInWithEmail.failure ?? response.exception,
          ));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.signInWithEmail.failure ?? _));
      }
    }
  }

  Future signInByFacebook({
    Auth? authenticator,
    bool biometric = false,
  }) async {
    emit(AuthResponse.loading(AuthProvider.facebook, _msg.loading));
    try {
      final response = await authHandler.signInWithFacebook();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Auth()).copy(
            biometric: biometric,
            accessToken: biometric ? result.accessToken : null,
            idToken: biometric ? result.idToken : null,
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          );
          await backupHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signInWithFacebook.done,
          ));
        } else {
          emit(AuthResponse.failure(
            _msg.signInWithFacebook.failure ?? finalResponse.exception,
          ));
        }
      } else {
        emit(AuthResponse.failure(
          _msg.signInWithFacebook.failure ?? response.exception,
        ));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.signInWithFacebook.failure ?? _));
    }
  }

  Future signInByGithub({
    Auth? authenticator,
    bool biometric = false,
  }) async {
    emit(AuthResponse.loading(AuthProvider.github, _msg.loading));
    try {
      final response = await authHandler.signInWithGithub();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Auth()).copy(
            biometric: biometric,
            accessToken: biometric ? result.accessToken : null,
            idToken: biometric ? result.idToken : null,
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.github.name,
          );
          await backupHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signInWithGithub.done,
          ));
        } else {
          emit(AuthResponse.failure(
            _msg.signInWithGithub.failure ?? finalResponse.exception,
          ));
        }
      } else {
        emit(AuthResponse.failure(
          _msg.signInWithGithub.failure ?? response.exception,
        ));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.signInWithGithub.failure ?? _));
    }
  }

  Future signInByGoogle({
    Auth? authenticator,
    bool biometric = false,
  }) async {
    emit(AuthResponse.loading(AuthProvider.google, _msg.loading));
    try {
      final response = await authHandler.signInWithGoogle();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Auth()).copy(
            biometric: biometric,
            accessToken: biometric ? result.accessToken : null,
            idToken: biometric ? result.idToken : null,
            id: currentData?.uid ?? result.id ?? uid,
            name: result.name,
            photo: result.photo,
            email: result.email,
            provider: AuthProvider.google.name,
          );
          await backupHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signInWithGoogle.done,
          ));
        } else {
          emit(AuthResponse.failure(
            _msg.signInWithGoogle.failure ?? finalResponse.exception,
          ));
        }
      } else {
        emit(AuthResponse.failure(
          _msg.signInWithGoogle.failure ?? response.exception,
        ));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.signInWithGoogle.failure ?? _));
    }
  }

  Future signInByUsername(
    UsernameAuthenticator authenticator, {
    bool biometric = false,
  }) async {
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      emit(AuthResponse.failure("Username isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.username, _msg.loading));
      try {
        final response = await authHandler.signInWithUsernameNPassword(
          username: username,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              biometric: biometric,
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.username.name,
            );
            await backupHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signInWithUsername.done,
            ));
          } else {
            emit(AuthResponse.failure(
              _msg.signInWithUsername.failure ?? response.exception,
            ));
          }
        } else {
          emit(AuthResponse.failure(
            _msg.signInWithUsername.failure ?? response.exception,
          ));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.signInWithUsername.failure ?? _));
      }
    }
  }

  Future signUpByEmail(
    EmailAuthenticator authenticator, {
    bool biometric = false,
  }) async {
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      emit(AuthResponse.failure("Email isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email, _msg.loading));
      try {
        final response = await authHandler.signUpWithEmailNPassword(
          email: email.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              biometric: biometric,
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            );
            await backupHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signUpWithEmail.done,
            ));
          } else {
            emit(AuthResponse.failure(
              _msg.signUpWithEmail.failure ?? response.exception,
            ));
          }
        } else {
          emit(AuthResponse.failure(
            _msg.signUpWithEmail.failure ?? response.exception,
          ));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.signUpWithEmail.failure ?? _));
      }
    }
  }

  Future signUpByUsername(
    UsernameAuthenticator authenticator, {
    bool biometric = false,
  }) async {
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      emit(AuthResponse.failure("Username isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.username, _msg.loading));
      try {
        final response = await authHandler.signUpWithUsernameNPassword(
          username: username.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              biometric: biometric,
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.username.name,
            );
            await backupHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signUpWithUsername.done,
            ));
          } else {
            emit(AuthResponse.failure(
              _msg.signUpWithUsername.failure ?? response.exception,
            ));
          }
        } else {
          emit(AuthResponse.failure(
            _msg.signUpWithUsername.failure ?? response.exception,
          ));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.signUpWithUsername.failure ?? _));
      }
    }
  }

  Future signOut({
    AuthProvider? provider,
    SignOutCallback? callback,
  }) async {
    emit(AuthResponse.loading(provider, _msg.loading));
    try {
      final response = await authHandler.signOut(provider);
      if (response.isSuccessful) {
        var data = await backupHandler.getCache();
        if (callback != null) await callback(data.copy(id: response.data?.id));
        if (!data.biometric) await backupHandler.removeCache();
        emit(AuthResponse.unauthenticated(_msg.signOut.done));
      } else {
        emit(AuthResponse.failure(_msg.signOut.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.signOut.failure ?? _));
    }
  }
}

class AuthMessages {
  final String? loading;

  final AuthMessage loggedIn;
  final AuthMessage loggedOut;

  final AuthMessage signInWithApple;
  final AuthMessage signInWithBiometric;
  final AuthMessage signInWithEmail;
  final AuthMessage signInWithFacebook;
  final AuthMessage signInWithGithub;
  final AuthMessage signInWithGoogle;
  final AuthMessage signInWithUsername;

  final AuthMessage signUpWithEmail;
  final AuthMessage signUpWithUsername;

  final AuthMessage signOut;

  const AuthMessages({
    this.loading,
    this.loggedIn = const AuthMessage(
      done: "User logged in!",
    ),
    this.loggedOut = const AuthMessage(
      done: "User logged out!",
    ),
    this.signInWithApple = const AuthMessage(
      done: "Apple sign in successful!",
    ),
    this.signInWithBiometric = const AuthMessage(
      done: "Biometric sign in successful!",
    ),
    this.signInWithEmail = const AuthMessage(
      done: "Sign in successful!",
    ),
    this.signInWithFacebook = const AuthMessage(
      done: "Facebook sign in successful!",
    ),
    this.signInWithGithub = const AuthMessage(
      done: "Github sign in successful!",
    ),
    this.signInWithGoogle = const AuthMessage(
      done: "Google sign in successful!",
    ),
    this.signInWithUsername = const AuthMessage(
      done: "Sign in successful!",
    ),
    this.signUpWithEmail = const AuthMessage(
      done: "Sign up successful!",
    ),
    this.signUpWithUsername = const AuthMessage(
      done: "Sign up successful!",
    ),
    this.signOut = const AuthMessage(
      done: "Sign out successful!",
    ),
  });
}

class AuthMessage {
  final String? done;
  final String? failure;

  const AuthMessage({
    this.done,
    this.failure,
  });
}
