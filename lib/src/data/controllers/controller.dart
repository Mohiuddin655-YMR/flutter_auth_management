part of 'controllers.dart';

class AuthControllerImpl<T extends Auth> extends AuthController<T> {
  final AuthMessages msg;
  final AuthHandler authHandler;
  final BackupHandler<T> backupHandler;
  final _liveAuth = StreamController<T?>();
  final _liveResponse = StreamController<AuthResponse<T>>();

  Future<T?> get _auth => backupHandler.cache;

  AuthControllerImpl({
    AuthDataSource? auth,
    BackupDataSource<T>? backup,
    AuthMessages? messages,
  }) : this.fromHandler(
          messages: messages,
          authHandler: AuthHandlerImpl(source: auth),
          backupHandler: BackupHandlerImpl<T>(source: backup),
        );

  AuthControllerImpl.fromHandler({
    AuthHandler? authHandler,
    BackupHandler<T>? backupHandler,
    AuthMessages? messages,
  })  : msg = messages ?? const AuthMessages(),
        authHandler = authHandler ?? AuthHandlerImpl(),
        backupHandler = backupHandler ?? BackupHandlerImpl<T>();

  @override
  Future<T?> get auth {
    return _auth.then((value) {
      return value != null && value.isLoggedIn ? value : null;
    });
  }

  @override
  Stream<T?> get liveAuth => _liveAuth.stream;

  @override
  Stream<AuthResponse<T>> get liveResponse => _liveResponse.stream;

  @override
  Future<bool> get isBiometricEnabled async {
    return _auth.then((value) => value != null && value.isBiometric);
  }

  @override
  Future<bool> get isLoggedIn => auth.then((value) => value != null);

  @override
  Future<AuthResponse<T>> emit(AuthResponse<T> data) async {
    _liveResponse.add(data);
    return data;
  }

  @override
  void close() {
    _liveAuth.close();
    _liveResponse.close();
  }

  Future<bool> _clear() {
    return backupHandler.clear().then((value) {
      if (value) auth.then(_liveAuth.add);
      return value;
    });
  }

  @override
  Future<T?> update(Map<String, dynamic> data) {
    return auth.then((user) {
      if (user != null) {
        return backupHandler.update(user.id, data).then((value) {
          return auth.then((update) {
            _liveAuth.add(update);
            return update;
          });
        });
      } else {
        final current = backupHandler.build(data);
        return backupHandler.set(current).then((value) {
          _liveAuth.add(current);
          return current;
        });
      }
    });
  }

  @override
  Future<AuthResponse<T>> delete() async {
    emit(const AuthResponse.loading(
      AuthActions.delete,
      AuthProviders.none,
      AuthType.delete,
    ));
    var data = await auth;
    if (data != null) {
      try {
        return authHandler.delete.then((response) {
          if (response.isSuccessful) {
            return _clear().then((value) {
              return backupHandler.onDeleteUser(data.id).then((value) {
                return emit(AuthResponse.unauthenticated(
                  AuthActions.delete,
                  message: msg.delete.done,
                  provider: AuthProviders.none,
                  type: AuthType.delete,
                ));
              });
            });
          } else {
            return emit(AuthResponse.rollback(
              AuthActions.delete,
              data,
              message: response.message,
              provider: AuthProviders.none,
              type: AuthType.delete,
            ));
          }
        });
      } catch (_) {
        return emit(AuthResponse.rollback(
          AuthActions.delete,
          data,
          message: msg.delete.failure ?? _,
          provider: AuthProviders.none,
          type: AuthType.delete,
        ));
      }
    } else {
      return emit(AuthResponse.rollback(
        AuthActions.delete,
        data,
        message: msg.loggedIn.failure,
        provider: AuthProviders.none,
        type: AuthType.delete,
      ));
    }
  }

  @override
  Future<bool> addBiometric(
    bool enabled, {
    BiometricConfig? config,
  }) async {
    final auth = await _auth;
    if (auth != null && auth.isLoggedIn) {
      try {
        final response = await authHandler.signInWithBiometric(config: config);
        if (response.isSuccessful) {
          return update(auth.copy(biometric: enabled).source).then((_) => true);
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

  @override
  Future<bool> biometricEnable(bool enabled) async {
    final auth = await _auth;
    if (auth != null && auth.isLoggedIn) {
      try {
        return update(auth.copy(biometric: enabled).source).then((_) => true);
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Future<AuthResponse<T>> isSignIn([
    AuthProviders? provider,
  ]) async {
    try {
      final signedIn = await authHandler.isSignIn(provider);
      final data = signedIn ? await auth : null;
      if (data != null) {
        return AuthResponse.authenticated(
          AuthActions.isSignIn,
          data,
          provider: provider,
          type: AuthType.signedIn,
        );
      } else {
        return AuthResponse.unauthenticated(
          AuthActions.isSignIn,
          provider: provider,
          type: AuthType.signedIn,
        );
      }
    } catch (_) {
      return AuthResponse.failure(
        AuthActions.isSignIn,
        msg.loggedIn.failure ?? _,
        provider: provider,
        type: AuthType.signedIn,
      );
    }
  }

  @override
  Future<AuthResponse<T>> signInByApple({
    String? id,
    Authenticator? authenticator,
    SignByBiometricCallback? onBiometric,
    bool storeToken = false,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByApple,
      AuthProviders.apple,
      AuthType.oauth,
    ));
    try {
      final response = await authHandler.signInWithApple();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.empty()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.apple.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByApple,
                  value,
                  message: msg.signInWithApple.done,
                  provider: AuthProviders.apple,
                  type: AuthType.oauth,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByApple,
                  value,
                  message: msg.signInWithApple.done,
                  provider: AuthProviders.apple,
                  type: AuthType.oauth,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByApple,
              msg.authorization,
              provider: AuthProviders.apple,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByApple,
            current.exception,
            provider: AuthProviders.apple,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          AuthActions.signInByApple,
          response.exception,
          provider: AuthProviders.apple,
          type: AuthType.oauth,
        ));
      }
    } catch (_) {
      return emit(AuthResponse.failure(
        AuthActions.signInByApple,
        msg.signInWithApple.failure ?? _,
        provider: AuthProviders.apple,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInByBiometric({
    BiometricConfig? config,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByBiometric,
      AuthProviders.biometric,
      AuthType.biometric,
    ));
    try {
      final user = await _auth;
      if (user != null && user.isBiometric) {
        final response = await authHandler.signInWithBiometric(config: config);
        if (response.isSuccessful) {
          final token = user.accessToken;
          final provider = AuthProviders.from(user.provider);
          var current = Response<UserCredential>();
          if ((user.email.isValid || user.username.isValid) &&
              user.password.isValid) {
            if (provider.isEmail) {
              current = await authHandler.signInWithEmailNPassword(
                email: user.email ?? "",
                password: user.password ?? "",
              );
            } else if (provider.isUsername) {
              current = await authHandler.signInWithUsernameNPassword(
                username: user.username ?? "",
                password: user.password ?? "",
              );
            }
          } else if (token.isValid || user.idToken.isValid) {
            if (provider.isApple) {
              current = await authHandler.signInWithCredential(
                credential: OAuthProvider("apple.com").credential(
                  idToken: user.idToken,
                  accessToken: token,
                ),
              );
            } else if (provider.isFacebook) {
              current = await authHandler.signInWithCredential(
                credential: FacebookAuthProvider.credential(token.use),
              );
            } else if (provider.isGoogle) {
              current = await authHandler.signInWithCredential(
                credential: GoogleAuthProvider.credential(
                  idToken: user.idToken,
                  accessToken: token,
                ),
              );
            }
          }
          if (current.isSuccessful) {
            return update(user.copy(loggedIn: true).source).then((value) {
              return emit(AuthResponse.authenticated(
                AuthActions.signInByBiometric,
                value,
                message: msg.signInWithBiometric.done,
                provider: AuthProviders.biometric,
                type: AuthType.biometric,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByBiometric,
              current.exception,
              provider: AuthProviders.biometric,
              type: AuthType.biometric,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByBiometric,
            response.exception,
            provider: AuthProviders.biometric,
            type: AuthType.biometric,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          AuthActions.signInByBiometric,
          msg.biometric,
          provider: AuthProviders.biometric,
          type: AuthType.biometric,
        ));
      }
    } catch (_) {
      return emit(AuthResponse.failure(
        AuthActions.signInByBiometric,
        msg.signInWithBiometric.failure ?? _,
        provider: AuthProviders.biometric,
        type: AuthType.biometric,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByEmail,
      AuthProviders.email,
      AuthType.login,
    ));
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      return emit(AuthResponse.failure(
        AuthActions.signInByEmail,
        msg.email,
        provider: AuthProviders.email,
        type: AuthType.login,
      ));
    } else if (!Validator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        AuthActions.signInByEmail,
        msg.password,
        provider: AuthProviders.email,
        type: AuthType.login,
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
              provider: AuthProviders.email.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByEmail,
                  value,
                  message: msg.signInWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.login,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByEmail,
                  value,
                  message: msg.signInWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.login,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByEmail,
              msg.authorization,
              provider: AuthProviders.email,
              type: AuthType.login,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByEmail,
            response.exception,
            provider: AuthProviders.email,
            type: AuthType.login,
          ));
        }
      } catch (_) {
        return emit(AuthResponse.failure(
          AuthActions.signInByEmail,
          msg.signInWithEmail.failure ?? _,
          provider: AuthProviders.email,
          type: AuthType.login,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signInByFacebook({
    OAuthAuthenticator? authenticator,
    SignByBiometricCallback? onBiometric,
    bool storeToken = false,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByFacebook,
      AuthProviders.facebook,
      AuthType.oauth,
    ));
    try {
      final response = await authHandler.signInWithFacebook();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.empty()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.facebook.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByFacebook,
                  value,
                  message: msg.signInWithFacebook.done,
                  provider: AuthProviders.facebook,
                  type: AuthType.oauth,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByFacebook,
                  value,
                  message: msg.signInWithFacebook.done,
                  provider: AuthProviders.facebook,
                  type: AuthType.oauth,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByFacebook,
              msg.authorization,
              provider: AuthProviders.facebook,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByFacebook,
            current.exception,
            provider: AuthProviders.facebook,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          AuthActions.signInByFacebook,
          response.exception,
          provider: AuthProviders.facebook,
          type: AuthType.oauth,
        ));
      }
    } catch (_) {
      return emit(AuthResponse.failure(
        AuthActions.signInByFacebook,
        msg.signInWithFacebook.failure ?? _,
        provider: AuthProviders.facebook,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInByGithub({
    OAuthAuthenticator? authenticator,
    SignByBiometricCallback? onBiometric,
    bool storeToken = false,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByGithub,
      AuthProviders.github,
      AuthType.oauth,
    ));
    try {
      final response = await authHandler.signInWithGithub();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.empty()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.github.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByGithub,
                  value,
                  message: msg.signInWithGithub.done,
                  provider: AuthProviders.github,
                  type: AuthType.oauth,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByGithub,
                  value,
                  message: msg.signInWithGithub.done,
                  provider: AuthProviders.github,
                  type: AuthType.oauth,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByGithub,
              msg.authorization,
              provider: AuthProviders.github,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByGithub,
            current.exception,
            provider: AuthProviders.github,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          AuthActions.signInByGithub,
          response.exception,
          provider: AuthProviders.github,
          type: AuthType.oauth,
        ));
      }
    } catch (_) {
      return emit(AuthResponse.failure(
        AuthActions.signInByGithub,
        msg.signInWithGithub.failure ?? _,
        provider: AuthProviders.github,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInByGoogle({
    OAuthAuthenticator? authenticator,
    SignByBiometricCallback? onBiometric,
    bool storeToken = false,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByGoogle,
      AuthProviders.google,
      AuthType.oauth,
    ));
    try {
      final response = await authHandler.signInWithGoogle();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.empty()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.google.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByGoogle,
                  value,
                  message: msg.signInWithGoogle.done,
                  provider: AuthProviders.google,
                  type: AuthType.oauth,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByGoogle,
                  value,
                  message: msg.signInWithGoogle.done,
                  provider: AuthProviders.google,
                  type: AuthType.oauth,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByGoogle,
              msg.authorization,
              provider: AuthProviders.google,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByGoogle,
            current.exception,
            provider: AuthProviders.google,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          AuthActions.signInByGoogle,
          response.exception,
          provider: AuthProviders.google,
          type: AuthType.oauth,
        ));
      }
    } catch (_) {
      return emit(AuthResponse.failure(
        AuthActions.signInByGoogle,
        msg.signInWithGoogle.failure ?? _,
        provider: AuthProviders.google,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInByPhone(
    PhoneAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    bool storeToken = false,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByPhone,
      AuthProviders.phone,
      AuthType.phone,
    ));
    PhoneAuthCredential? raw = authenticator.credential;
    final isValidCredential = raw != null;
    final verId = authenticator.verificationId;
    final code = authenticator.smsCode;
    if (!Validator.isValidString(verId) && !isValidCredential) {
      return emit(AuthResponse.failure(
        AuthActions.signInByPhone,
        msg.verificationId,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      ));
    } else if (!Validator.isValidString(code) && !isValidCredential) {
      return emit(AuthResponse.failure(
        AuthActions.signInByPhone,
        msg.otp,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      ));
    } else {
      try {
        raw ??= PhoneAuthProvider.credential(
          verificationId: verId,
          smsCode: code,
        );

        final response = await authHandler.signInWithCredential(
          credential: raw,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken && raw.token != null ? "${raw.token}" : null,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProviders.phone.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByPhone,
                  value,
                  message: msg.signInWithPhone.done,
                  provider: AuthProviders.phone,
                  type: AuthType.phone,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByPhone,
                  value,
                  message: msg.signInWithPhone.done,
                  provider: AuthProviders.phone,
                  type: AuthType.phone,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByPhone,
              msg.authorization,
              provider: AuthProviders.phone,
              type: AuthType.phone,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByPhone,
            response.exception,
            provider: AuthProviders.phone,
            type: AuthType.phone,
          ));
        }
      } catch (_) {
        return emit(AuthResponse.failure(
          AuthActions.signInByPhone,
          msg.signInWithPhone.failure ?? _,
          provider: AuthProviders.phone,
          type: AuthType.phone,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signInByUsername,
      AuthProviders.username,
      AuthType.login,
    ));
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      return emit(AuthResponse.failure(
        AuthActions.signInByUsername,
        msg.username,
        provider: AuthProviders.username,
        type: AuthType.login,
      ));
    } else if (!Validator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        AuthActions.signInByUsername,
        msg.password,
        provider: AuthProviders.username,
        type: AuthType.login,
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
              provider: AuthProviders.username.name,
              biometric: await isBiometricEnabled,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByUsername,
                  value,
                  message: msg.signInWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.login,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signInByUsername,
                  value,
                  message: msg.signInWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.login,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signInByUsername,
              msg.authorization,
              provider: AuthProviders.username,
              type: AuthType.login,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signInByUsername,
            response.exception,
            provider: AuthProviders.username,
            type: AuthType.login,
          ));
        }
      } catch (_) {
        return emit(AuthResponse.failure(
          AuthActions.signInByUsername,
          msg.signInWithUsername.failure ?? _,
          provider: AuthProviders.username,
          type: AuthType.login,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signUpByEmail,
      AuthProviders.email,
      AuthType.register,
    ));
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      return emit(AuthResponse.failure(
        AuthActions.signUpByEmail,
        msg.email,
        provider: AuthProviders.email,
        type: AuthType.register,
      ));
    } else if (!Validator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        AuthActions.signUpByEmail,
        msg.password,
        provider: AuthProviders.email,
        type: AuthType.register,
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
              provider: AuthProviders.email.name,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signUpByEmail,
                  value,
                  message: msg.signUpWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.register,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signUpByEmail,
                  value,
                  message: msg.signUpWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.register,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signUpByEmail,
              msg.authorization,
              provider: AuthProviders.email,
              type: AuthType.register,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signUpByEmail,
            response.exception,
            provider: AuthProviders.email,
            type: AuthType.register,
          ));
        }
      } catch (_) {
        return emit(AuthResponse.failure(
          AuthActions.signUpByEmail,
          msg.signUpWithEmail.failure ?? _,
          provider: AuthProviders.email,
          type: AuthType.register,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    emit(const AuthResponse.loading(
      AuthActions.signUpByUsername,
      AuthProviders.username,
      AuthType.register,
    ));
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      return emit(AuthResponse.failure(
        AuthActions.signUpByUsername,
        msg.username,
        provider: AuthProviders.username,
        type: AuthType.register,
      ));
    } else if (!Validator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        AuthActions.signUpByUsername,
        msg.password,
        provider: AuthProviders.username,
        type: AuthType.register,
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
              provider: AuthProviders.username.name,
              loggedIn: true,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.isBiometric);
              return update(
                user.copy(biometric: biometric).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signUpByUsername,
                  value,
                  message: msg.signUpWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.register,
                ));
              });
            } else {
              return update(user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  AuthActions.signUpByUsername,
                  value,
                  message: msg.signUpWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.register,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              AuthActions.signUpByUsername,
              msg.authorization,
              provider: AuthProviders.username,
              type: AuthType.register,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            AuthActions.signUpByUsername,
            response.exception,
            provider: AuthProviders.username,
            type: AuthType.register,
          ));
        }
      } catch (_) {
        return emit(AuthResponse.failure(
          AuthActions.signUpByUsername,
          msg.signUpWithUsername.failure ?? _,
          provider: AuthProviders.username,
          type: AuthType.register,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signOut([
    AuthProviders provider = AuthProviders.none,
  ]) async {
    emit(AuthResponse.loading(AuthActions.signOut, provider, AuthType.logout));
    try {
      final response = await authHandler.signOut(provider);
      if (response.isSuccessful) {
        return _auth.then((data) async {
          if (data != null) {
            if (data.isBiometric) {
              return update(data.copy(loggedIn: false).source).then((value) {
                return emit(AuthResponse.unauthenticated(
                  AuthActions.signOut,
                  message: msg.signOut.done,
                  provider: provider,
                  type: AuthType.logout,
                ));
              });
            } else {
              return _clear().then((value) {
                return emit(AuthResponse.unauthenticated(
                  AuthActions.signOut,
                  message: msg.signOut.done,
                  provider: provider,
                  type: AuthType.logout,
                ));
              });
            }
          } else {
            return emit(AuthResponse.unauthenticated(
              AuthActions.signOut,
              message: msg.signOut.done,
              provider: provider,
              type: AuthType.logout,
            ));
          }
        });
      } else {
        return emit(AuthResponse.failure(
          AuthActions.signOut,
          response.exception,
          provider: provider,
          type: AuthType.logout,
        ));
      }
    } catch (_) {
      return emit(AuthResponse.failure(
        AuthActions.signOut,
        msg.signOut.failure ?? _,
        provider: provider,
        type: AuthType.logout,
      ));
    }
  }

  @override
  Future<Response<void>> verifyPhoneNumber(
    String phoneNumber, {
    int? forceResendingToken,
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(PhoneAuthCredential credential)? onComplete,
    void Function(FirebaseAuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
  }) async {
    return authHandler.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      multiFactorInfo: multiFactorInfo,
      multiFactorSession: multiFactorSession,
      timeout: timeout,
      onComplete: (PhoneAuthCredential credential) async {
        if (onComplete != null) {
          onComplete(credential);
        } else {
          await signInByPhone(PhoneAuthenticator.fromCredential(
            credential: credential,
            phone: phoneNumber,
          ));
        }
      },
      onCodeSent: (String verId, int? forceResendingToken) {
        if (onCodeSent != null) onCodeSent(verId, forceResendingToken);
      },
      onFailed: (FirebaseAuthException exception) {
        if (onFailed != null) onFailed(exception);
      },
      onCodeAutoRetrievalTimeout: (String verId) {
        if (onCodeAutoRetrievalTimeout != null) {
          onCodeAutoRetrievalTimeout(verId);
        }
      },
    );
  }
}
