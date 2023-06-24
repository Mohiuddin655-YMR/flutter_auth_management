part of 'controllers.dart';

class DefaultAuthController<T extends Authenticator>
    extends Cubit<AuthResponse<T>> {
  final AuthHandler authHandler;
  final DataHandler<T>? dataHandler;
  final String Function(String uid)? createUid;

  DefaultAuthController._(this.authHandler, this.dataHandler);

  factory DefaultAuthController.fromHandler(
    AuthHandler authHandler,
    DataHandler<T> dataHandler,
  ) {
    return DefaultAuthController._(authHandler, dataHandler);
  }

  factory DefaultAuthController.fromSource({
    required AuthDataSource authSource,
    required AuthenticatorDataSource<T>? dataSource,
  }) {
    return DefaultAuthController._(
      AuthHandlerImpl.fromSource(authSource),
      AuthenticatorDataSourceImpl<T>(),
    );
  }

  DefaultAuthController({
    required this.authHandler,
    required this.dataHandler,
    this.createUid,
  }) : super(AuthResponse.initial());

  String get uid => user?.uid ?? "uid";

  User? get user => FirebaseAuth.instance.currentUser;

  Future isLoggedIn([AuthProvider? provider]) async {
    try {
      emit(AuthResponse.loading(provider));
      final signedIn = await authHandler.isSignIn(provider);
      if (signedIn) {
        emit(AuthResponse.authenticated(state.data));
      } else {
        emit(AuthResponse.unauthenticated("User logged out!"));
      }
    } catch (e) {
      emit(AuthResponse.failure(e.toString()));
    }
  }

  Future signInByApple([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.apple));
    try {
      final response = await authHandler.signInWithApple();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: createUid?.call(currentData?.uid ?? result.id ?? uid) ??
                currentData?.uid ??
                result.id,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          ) as T;
          await dataHandler.insert(user);
          emit(AuthResponse.authenticated(user));
        } else {
          emit(AuthResponse.failure(finalResponse.message));
        }
      } else {
        emit(AuthResponse.failure(response.message));
      }
    } catch (_) {
      emit(AuthResponse.failure(_.toString()));
    }
  }

  Future signInByBiometric() async {
    emit(AuthResponse.loading(AuthProvider.biometric));
    final response = await authHandler.signInWithBiometric();
    try {
      if (response.isSuccessful) {
        final userResponse = await dataHandler.get(createUid?.call(uid) ?? uid);
        final user = userResponse.data;
        if (userResponse.isSuccessful && user is Authenticator) {
          final email = user.email;
          final password = user.password;
          final loginResponse = await authHandler.signInWithEmailNPassword(
            email: email ?? "example@gmail.com",
            password: password ?? "password",
          );
          if (loginResponse.isSuccessful) {
            emit(AuthResponse.authenticated(user));
          } else {
            emit(AuthResponse.failure(loginResponse.message));
          }
        } else {
          emit(AuthResponse.failure(userResponse.message));
        }
      } else {
        emit(AuthResponse.failure(response.message));
      }
    } catch (_) {
      emit(AuthResponse.failure(_));
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
      emit(AuthResponse.loading(AuthProvider.email));
      try {
        final response = await authHandler.signInWithEmailNPassword(
          email: email ?? "example@gmail.com",
          password: password ?? "password",
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: createUid?.call(result.uid) ?? result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            ) as T;
            emit(AuthResponse.authenticated(user));
          } else {
            emit(AuthResponse.failure(response.exception));
          }
        } else {
          emit(AuthResponse.failure(response.exception));
        }
      } catch (e) {
        emit(AuthResponse.failure(e.toString()));
      }
    }
  }

  Future signInByFacebook([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.facebook));
    try {
      final response = await authHandler.signInWithFacebook();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: createUid?.call(currentData?.uid ?? result.id ?? uid) ??
                currentData?.uid ??
                result.id,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          ) as T;
          await dataHandler.insert(user);
          emit(AuthResponse.authenticated(user));
        } else {
          emit(AuthResponse.failure(finalResponse.message));
        }
      } else {
        emit(AuthResponse.failure(response.message));
      }
    } catch (_) {
      emit(AuthResponse.failure(_.toString()));
    }
  }

  Future signInByGithub([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.github));
    try {
      final response = await authHandler.signInWithGithub();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: createUid?.call(currentData?.uid ?? result.id ?? uid) ??
                currentData?.uid ??
                result.id,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          ) as T;
          await dataHandler.insert(user);
          emit(AuthResponse.authenticated(user));
        } else {
          emit(AuthResponse.failure(finalResponse.message));
        }
      } else {
        emit(AuthResponse.failure(response.message));
      }
    } catch (_) {
      emit(AuthResponse.failure(_));
    }
  }

  Future signInByGoogle([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.google));
    try {
      final response = await authHandler.signInWithGoogle();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: createUid?.call(currentData?.uid ?? result.id ?? uid) ??
                currentData?.uid ??
                result.id,
            name: result.name,
            photo: result.photo,
            email: result.email,
            provider: AuthProvider.google.name,
          ) as T;
          await dataHandler.insert(user);
          emit(AuthResponse.authenticated(user));
        } else {
          emit(AuthResponse.failure(finalResponse.message));
        }
      } else {
        emit(AuthResponse.failure(response.message));
      }
    } catch (_) {
      emit(AuthResponse.failure(_));
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
      emit(AuthResponse.loading(AuthProvider.username));
      try {
        final response = await authHandler.signInWithUsernameNPassword(
          username: username,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: createUid?.call(result.uid) ?? result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.username.name,
            ) as T;
            emit(AuthResponse.authenticated(user));
          } else {
            emit(AuthResponse.failure(response.exception));
          }
        } else {
          emit(AuthResponse.failure(response.exception));
        }
      } catch (e) {
        emit(AuthResponse.failure(e.toString()));
      }
    }
  }

  Future signOut([AuthProvider? provider]) async {
    emit(AuthResponse.loading(provider));
    try {
      final response = await authHandler.signOut(provider);
      if (response.isSuccessful) {
        final userResponse = await dataHandler.delete(
          createUid?.call(uid) ?? uid,
        );
        if (userResponse.isSuccessful || userResponse.snapshot != null) {
          emit(AuthResponse.unauthenticated());
        } else {
          emit(AuthResponse.failure(userResponse.message));
        }
      } else {
        emit(AuthResponse.failure(response.message));
      }
    } catch (_) {
      emit(AuthResponse.failure(_));
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
      emit(AuthResponse.loading(AuthProvider.email));
      try {
        final response = await authHandler.signUpWithEmailNPassword(
          email: email.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: createUid?.call(result.uid) ?? result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            ) as T;
            await dataHandler.insert(user);
            emit(AuthResponse.authenticated(user));
          } else {
            emit(AuthResponse.failure(response.exception));
          }
        } else {
          emit(AuthResponse.failure(response.exception));
        }
      } catch (e) {
        emit(AuthResponse.failure(e.toString()));
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
      emit(AuthResponse.loading(AuthProvider.email));
      try {
        final response = await authHandler.signUpWithUsernameNPassword(
          username: username.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: createUid?.call(result.uid) ?? result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            ) as T;
            await dataHandler.insert(user);
            emit(AuthResponse.authenticated(user));
          } else {
            emit(AuthResponse.failure(response.exception));
          }
        } else {
          emit(AuthResponse.failure(response.exception));
        }
      } catch (e) {
        emit(AuthResponse.failure(e.toString()));
      }
    }
  }
}

abstract class AuthenticatorDataSource<T extends Authenticator>
    extends LocalDataSourceImpl<T> {
  AuthenticatorDataSource({
    required super.path,
  });
}

class AuthenticatorDataSourceImpl<T extends Authenticator>
    extends AuthenticatorDataSource<T> {
  AuthenticatorDataSourceImpl({
    super.path = "authenticators",
  });

  @override
  T build(source) {
    return Authenticator.from(source) as T;
  }
}
