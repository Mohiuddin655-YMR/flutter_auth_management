part of 'controllers.dart';

class DefaultAuthController<T extends AuthInfo> extends Cubit<AuthResponse<T>> {
  final AuthHandler authHandler;
  final DataHandler<T> dataHandler;
  final String Function(String uid)? createUid;

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

  Future signUpByEmail(AuthInfo entity) async {
    final email = entity.email;
    final password = entity.password;
    if (!Validator.isValidEmail(email)) {
      emit(AuthResponse.failure("Email isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email));
      try {
        final response = await authHandler.signUpWithEmailNPassword(
          email: email,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = entity.copy(
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

  Future signInByApple(AuthInfo entity) async {
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
          final user = entity.copy(
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
        if (userResponse.isSuccessful && user is AuthInfo) {
          final email = user.email;
          final password = user.password;
          final loginResponse = await authHandler.signInWithEmail(
            email: email,
            password: password,
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

  Future signInByEmail(AuthInfo entity) async {
    final email = entity.email;
    final password = entity.password;
    if (!Validator.isValidEmail(email)) {
      emit(AuthResponse.failure("Email isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email));
      try {
        final response = await authHandler.signInWithEmail(
          email: email,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = entity.copy(
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

  Future signInByFacebook(AuthInfo entity) async {
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
          final user = entity.copy(
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

  Future signInByGithub(AuthInfo entity) async {
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
          final user = entity.copy(
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

  Future signInByGoogle(AuthInfo entity) async {
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
          final user = entity.copy(
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
}
