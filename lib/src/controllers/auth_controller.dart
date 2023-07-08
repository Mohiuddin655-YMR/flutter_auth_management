part of 'controllers.dart';

typedef IdentityBuilder = String Function(String uid);

class AuthController extends Cubit<AuthResponse> {
  final AuthMessages _msg;
  final AuthHandler authHandler;
  final BackupHandler dataHandler;

  AuthController({
    AuthMessages? messages,
    AuthDataSource? auth,
    BackupSource? backup,
  })  : _msg = messages ?? const AuthMessages(),
        authHandler = AuthHandlerImpl.fromSource(auth ?? AuthDataSourceImpl()),
        dataHandler = BackupHandlerImpl(source: backup),
        super(AuthResponse.initial());

  AuthController.fromHandler({
    required this.authHandler,
    required this.dataHandler,
    AuthMessages? messages,
  })  : _msg = messages ?? const AuthMessages(),
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
          _msg.loggedIn ?? "User logged in!",
        ));
      } else {
        emit(AuthResponse.unauthenticated(
          _msg.loggedOut ?? "User logged out!",
        ));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByApple([Auth? authenticator]) async {
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
            accessToken: result.accessToken,
            idToken: result.idToken,
            refreshToken: result.refreshToken,
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.apple.name,
          );
          await dataHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signIn ?? "Apple sign in successful!",
          ));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByBiometric() async {
    emit(AuthResponse.loading(AuthProvider.biometric, _msg.loading));
    final response = await authHandler.signInWithBiometric();
    try {
      if (response.isSuccessful) {
        final user = await dataHandler.getCache();
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
            _msg.signIn ?? "Biometric sign in successful!",
          ));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? loginResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByEmail(EmailAuthenticator authenticator) async {
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
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            );
            await dataHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signIn ?? "Sign in successful!",
            ));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.message));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signInByFacebook([Auth? authenticator]) async {
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
            accessToken: result.accessToken,
            idToken: result.idToken,
            refreshToken: result.refreshToken,
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          );
          await dataHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signIn ?? "Facebook sign in successful!",
          ));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByGithub([Auth? authenticator]) async {
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
            accessToken: result.accessToken,
            idToken: result.idToken,
            refreshToken: result.refreshToken,
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.github.name,
          );
          await dataHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signIn ?? "Github sign in successful!",
          ));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByGoogle([Auth? authenticator]) async {
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
            accessToken: result.accessToken,
            idToken: result.idToken,
            refreshToken: result.refreshToken,
            id: currentData?.uid ?? result.id ?? uid,
            name: result.name,
            photo: result.photo,
            email: result.email,
            provider: AuthProvider.google.name,
          );
          await dataHandler.setCache(user);
          emit(AuthResponse.authenticated(
            user,
            _msg.signIn ?? "Google sign in successful!",
          ));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByUsername(UsernameAuthenticator authenticator) async {
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
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.username.name,
            );
            await dataHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signIn ?? "Sign in successful!",
            ));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.exception));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signUpByEmail(EmailAuthenticator authenticator) async {
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
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            );
            await dataHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signUp ?? "Sign up successful!",
            ));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.exception));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signUpByUsername(UsernameAuthenticator authenticator) async {
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      emit(AuthResponse.failure("Username isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email, _msg.loading));
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
              provider: AuthProvider.username.name,
            );
            await dataHandler.setCache(user);
            emit(AuthResponse.authenticated(
              user,
              _msg.signUp ?? "Sign up successful!",
            ));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.exception));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signOut([AuthProvider? provider]) async {
    emit(AuthResponse.loading(provider, _msg.loading));
    try {
      final response = await authHandler.signOut(provider);
      if (response.isSuccessful) {
        await dataHandler.removeCache();
        emit(AuthResponse.unauthenticated(
          _msg.signOut ?? "Sign out successful!",
        ));
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }
}

class AuthMessages {
  final String? loading;
  final String? loggedIn;
  final String? loggedOut;
  final String? failure;

  final String? signIn;
  final String? signOut;
  final String? signUp;

  const AuthMessages({
    this.loading,
    this.loggedIn,
    this.loggedOut,
    this.signIn,
    this.signOut,
    this.failure,
    this.signUp,
  });
}
