part of 'controllers.dart';

typedef IdentityBuilder = String Function(String uid);
typedef SignByBiometricCallback = Future<bool> Function(bool biometric);
typedef SignOutCallback = Future Function(Authorizer authorizer);
typedef UndoAccountCallback = Future<bool> Function(Authorizer authorizer);

class AuthController {
  final AuthMessages _msg;
  final AuthHandler authHandler;
  final BackupHandler backupHandler;

  AuthController({
    AuthDataSource? auth,
    BackupDataSource? backup,
    AuthMessages? messages,
  }) : this.fromHandler(
          messages: messages,
          authHandler: AuthHandlerImpl(source: auth),
          backupHandler: BackupHandlerImpl(source: backup),
        );

  AuthController.fromHandler({
    AuthHandler? authHandler,
    BackupHandler? backupHandler,
    AuthMessages? messages,
  })  : _msg = messages ?? const AuthMessages(),
        authHandler = authHandler ?? AuthHandlerImpl(),
        backupHandler = backupHandler ?? BackupHandlerImpl();

  String get _id => _user?.uid ?? "uid";

  User? get _user => FirebaseAuth.instance.currentUser;

  Future<Authorizer?> get authorizer {
    return backupHandler.getCache().then((value) {
      return value != null && value.loggedIn ? value : null;
    });
  }

  Future<Authorizer?> get _auth => backupHandler.getCache();

  Future<bool> get isBiometricEnabled async {
    return _auth.then((value) => value != null && value.biometric);
  }

  Future<bool> biometricEnable(bool enabled) async {
    final auth = await _auth;
    if (auth != null && auth.loggedIn) {
      try {
        return backupHandler.setCache(auth.copy(biometric: enabled));
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> addBiometric(
    bool enabled, {
    BiometricConfig? config,
  }) async {
    final auth = await _auth;
    if (auth != null && auth.loggedIn) {
      try {
        final response = await authHandler.signInWithBiometric(config: config);
        if (response.isSuccessful) {
          return backupHandler.setCache(auth.copy(biometric: enabled));
        } else {
          return false;
        }
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> isLoggedIn([AuthType? provider]) {
    return isSignIn(provider).then((value) => value.isAuthenticated);
  }

  Future<AuthResponse> isSignIn([AuthType? provider]) async {
    try {
      final signedIn = await authHandler.isSignIn(provider);
      final data = signedIn ? await backupHandler.getCache() : null;
      if (data != null) {
        return AuthResponse.authenticated(data.copy(loggedIn: true));
      } else {
        return const AuthResponse.unauthenticated();
      }
    } catch (_) {
      return AuthResponse.failure(_msg.loggedIn.failure ?? _);
    }
  }

  Future<AuthResponse> signInByApple({
    Authorizer? authenticator,
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.apple, _msg.loading));
    try {
      final response = await authHandler.signInWithApple();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authorizer()).copy(
            id: currentData?.uid ?? result.id ?? _id,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthType.apple.name,
            accessToken: result.accessToken,
            idToken: result.idToken,
            biometric: await isBiometricEnabled,
            loggedIn: true,
          );
          if (onBiometric != null) {
            await backupHandler.setCache(user.copy(
              biometric: await onBiometric(user.biometric),
            ));
          } else {
            await backupHandler.setCache(user);
          }
          return AuthManager.emit(AuthResponse.authenticated(
            user,
            _msg.signInWithApple.done,
          ));
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signInWithApple.failure ?? finalResponse.exception,
          ));
        }
      } else {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signInWithApple.failure ?? response.exception,
        ));
      }
    } catch (_) {
      return AuthManager.emit(AuthResponse.failure(
        _msg.signInWithApple.failure ?? _,
      ));
    }
  }

  Future<AuthResponse> signInByBiometric({
    BiometricConfig? config,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.biometric, _msg.loading));
    try {
      final user = await _auth;
      if (user != null && user.biometric) {
        final response = await authHandler.signInWithBiometric(config: config);
        if (response.isSuccessful) {
          final token = user.accessToken;
          final provider = user.provider;
          var loginResponse = Response();
          if ((user.email.isValid || user.username.isValid) &&
              user.password.isValid) {
            if (provider.isEmail) {
              loginResponse = await authHandler.signInWithEmailNPassword(
                email: user.email ?? "",
                password: user.password ?? "",
              );
            } else if (provider.isUsername) {
              loginResponse = await authHandler.signInWithUsernameNPassword(
                username: user.username ?? "",
                password: user.password ?? "",
              );
            }
          } else if (token.isValid || user.idToken.isValid) {
            if (provider.isApple) {
              loginResponse = await authHandler.signUpWithCredential(
                credential: OAuthProvider("apple.com").credential(
                  idToken: user.idToken,
                  accessToken: token,
                ),
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
            await backupHandler.setCache(user.copy(loggedIn: true));
            return AuthManager.emit(AuthResponse.authenticated(
              user.copy(loggedIn: true),
              _msg.signInWithBiometric.done,
            ));
          } else {
            return AuthManager.emit(AuthResponse.failure(
              _msg.signInWithBiometric.failure ?? loginResponse.exception,
            ));
          }
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signInWithBiometric.failure ?? response.exception,
          ));
        }
      } else {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signInWithBiometric.failure ?? "Biometric not initialized!",
        ));
      }
    } catch (_) {
      return AuthManager.emit(AuthResponse.failure(
        _msg.signInWithBiometric.failure ?? _,
      ));
    }
  }

  Future<AuthResponse> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.email, _msg.loading));
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Email isn't valid!",
      ));
    } else if (!Validator.isValidPassword(password)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Password isn't valid!",
      ));
    } else {
      try {
        final response = await authHandler.signInWithEmailNPassword(
          email: email,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthType.email.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              await backupHandler.setCache(user.copy(
                biometric: await onBiometric(user.biometric),
              ));
            } else {
              await backupHandler.setCache(user);
            }
            return AuthManager.emit(AuthResponse.authenticated(
              user,
              _msg.signInWithEmail.done,
            ));
          } else {
            return AuthManager.emit(AuthResponse.failure(
              _msg.signInWithEmail.failure ?? response.message,
            ));
          }
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signInWithEmail.failure ?? response.exception,
          ));
        }
      } catch (_) {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signInWithEmail.failure ?? _,
        ));
      }
    }
  }

  Future<AuthResponse> signInByFacebook({
    Authorizer? authenticator,
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.facebook, _msg.loading));
    try {
      final response = await authHandler.signInWithFacebook();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authorizer()).copy(
            id: currentData?.uid ?? result.id ?? _id,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthType.facebook.name,
            accessToken: result.accessToken,
            idToken: result.idToken,
            biometric: await isBiometricEnabled,
            loggedIn: true,
          );
          if (onBiometric != null) {
            await backupHandler.setCache(user.copy(
              biometric: await onBiometric(user.biometric),
            ));
          } else {
            await backupHandler.setCache(user);
          }
          return AuthManager.emit(AuthResponse.authenticated(
            user,
            _msg.signInWithFacebook.done,
          ));
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signInWithFacebook.failure ?? finalResponse.exception,
          ));
        }
      } else {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signInWithFacebook.failure ?? response.exception,
        ));
      }
    } catch (_) {
      return AuthManager.emit(AuthResponse.failure(
        _msg.signInWithFacebook.failure ?? _,
      ));
    }
  }

  Future<AuthResponse> signInByGithub({
    Authorizer? authenticator,
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.github, _msg.loading));
    try {
      final response = await authHandler.signInWithGithub();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authorizer()).copy(
            id: currentData?.uid ?? result.id ?? _id,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthType.github.name,
            accessToken: result.accessToken,
            idToken: result.idToken,
            biometric: await isBiometricEnabled,
            loggedIn: true,
          );
          if (onBiometric != null) {
            await backupHandler.setCache(user.copy(
              biometric: await onBiometric(user.biometric),
            ));
          } else {
            await backupHandler.setCache(user);
          }
          return AuthManager.emit(AuthResponse.authenticated(
            user,
            _msg.signInWithGithub.done,
          ));
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signInWithGithub.failure ?? finalResponse.exception,
          ));
        }
      } else {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signInWithGithub.failure ?? response.exception,
        ));
      }
    } catch (_) {
      return AuthManager.emit(AuthResponse.failure(
        _msg.signInWithGithub.failure ?? _,
      ));
    }
  }

  Future<AuthResponse> signInByGoogle({
    Authorizer? authenticator,
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.google, _msg.loading));
    try {
      final response = await authHandler.signInWithGoogle();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authorizer()).copy(
            id: currentData?.uid ?? result.id ?? _id,
            name: result.name,
            photo: result.photo,
            email: result.email,
            provider: AuthType.google.name,
            accessToken: result.accessToken,
            idToken: result.idToken,
            biometric: await isBiometricEnabled,
            loggedIn: true,
          );
          if (onBiometric != null) {
            await backupHandler.setCache(user.copy(
              biometric: await onBiometric(user.biometric),
            ));
          } else {
            await backupHandler.setCache(user);
          }
          return AuthManager.emit(AuthResponse.authenticated(
            user,
            _msg.signInWithGoogle.done,
          ));
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signInWithGoogle.failure ?? finalResponse.exception,
          ));
        }
      } else {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signInWithGoogle.failure ?? response.exception,
        ));
      }
    } catch (_) {
      return AuthManager.emit(AuthResponse.failure(
        _msg.signInWithGoogle.failure ?? _,
      ));
    }
  }

  Future<AuthResponse> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.username, _msg.loading));
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Username isn't valid!",
      ));
    } else if (!Validator.isValidPassword(password)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Password isn't valid!",
      ));
    } else {
      try {
        final response = await authHandler.signInWithUsernameNPassword(
          username: username,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthType.username.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              await backupHandler.setCache(user.copy(
                biometric: await onBiometric(user.biometric),
              ));
            } else {
              await backupHandler.setCache(user);
            }
            return AuthManager.emit(AuthResponse.authenticated(
              user,
              _msg.signInWithUsername.done,
            ));
          } else {
            return AuthManager.emit(AuthResponse.failure(
              _msg.signInWithUsername.failure ?? response.exception,
            ));
          }
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signInWithUsername.failure ?? response.exception,
          ));
        }
      } catch (_) {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signInWithUsername.failure ?? _,
        ));
      }
    }
  }

  Future<AuthResponse> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.email, _msg.loading));
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Email isn't valid!",
      ));
    } else if (!Validator.isValidPassword(password)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Password isn't valid!",
      ));
    } else {
      try {
        final response = await authHandler.signUpWithEmailNPassword(
          email: email.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthType.email.name,
              loggedIn: true,
            );
            if (onBiometric != null) {
              await backupHandler.setCache(user.copy(
                biometric: await onBiometric(user.biometric),
              ));
            } else {
              await backupHandler.setCache(user);
            }
            return AuthManager.emit(AuthResponse.authenticated(
              user,
              _msg.signUpWithEmail.done,
            ));
          } else {
            return AuthManager.emit(AuthResponse.failure(
              _msg.signUpWithEmail.failure ?? response.exception,
            ));
          }
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signUpWithEmail.failure ?? response.exception,
          ));
        }
      } catch (_) {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signUpWithEmail.failure ?? _,
        ));
      }
    }
  }

  Future<AuthResponse> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    AuthManager.emit(AuthResponse.loading(AuthType.username, _msg.loading));
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Username isn't valid!",
      ));
    } else if (!Validator.isValidPassword(password)) {
      return AuthManager.emit(const AuthResponse.failure(
        "Password isn't valid!",
      ));
    } else {
      try {
        final response = await authHandler.signUpWithUsernameNPassword(
          username: username.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthType.username.name,
              loggedIn: true,
            );
            if (onBiometric != null) {
              await backupHandler.setCache(user.copy(
                biometric: await onBiometric(user.biometric),
              ));
            } else {
              await backupHandler.setCache(user);
            }
            return AuthManager.emit(AuthResponse.authenticated(
              user,
              _msg.signUpWithUsername.done,
            ));
          } else {
            return AuthManager.emit(AuthResponse.failure(
              _msg.signUpWithUsername.failure ?? response.exception,
            ));
          }
        } else {
          return AuthManager.emit(AuthResponse.failure(
            _msg.signUpWithUsername.failure ?? response.exception,
          ));
        }
      } catch (_) {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signUpWithUsername.failure ?? _,
        ));
      }
    }
  }

  Future<AuthResponse> signOut({
    AuthType? provider,
    SignOutCallback? callback,
  }) async {
    AuthManager.emit(AuthResponse.loading(provider, _msg.loading));
    try {
      final response = await authHandler.signOut(provider);
      if (response.isSuccessful) {
        var data = await _auth;
        if (data != null) {
          if (data.biometric) {
            await backupHandler.setCache(data.copy(loggedIn: false));
          } else {
            await backupHandler.removeCache();
          }
          if (callback != null) {
            await callback(data.copy(id: response.data?.id));
          }
        }
        return AuthManager.emit(AuthResponse.unauthenticated(
          _msg.signOut.done,
        ));
      } else {
        return AuthManager.emit(AuthResponse.failure(
          _msg.signOut.failure ?? response.exception,
        ));
      }
    } catch (_) {
      return AuthManager.emit(AuthResponse.failure(
        _msg.signOut.failure ?? _,
      ));
    }
  }

  Future<AuthResponse> deleteAccount({
    UndoAccountCallback? callback,
  }) async {
    AuthManager.emit(AuthResponse.loading(null, _msg.loading));
    var data = await authorizer;
    if (data != null && _user != null) {
      try {
        return authHandler.delete(_user).then((response) {
          if (response.isSuccessful) {
            return backupHandler.removeCache().then((value) {
              return backupHandler.onDeleted(data.id).then((value) {
                return AuthManager.emit(
                  AuthResponse.unauthenticated(_msg.signOut.done),
                );
              });
            });
          } else {
            return AuthManager.emit(
              AuthResponse.rollback(data, response.message),
            );
          }
        });
      } catch (_) {
        return AuthManager.emit(AuthResponse.rollback(data, "$_"));
      }
    } else {
      return AuthManager.emit(AuthResponse.rollback(
        data,
        "You're not logged in!",
      ));
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
