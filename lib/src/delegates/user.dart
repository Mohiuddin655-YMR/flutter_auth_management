import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_entity/entity.dart';

abstract class IUserDelegate {
  const IUserDelegate();

  auth.User? get user;

  Future<Response<void>> delete();

  Future<Response<String>> getIdToken([bool forceRefresh = false]);

  Future<Response<auth.IdTokenResult>> getIdTokenResult([
    bool forceRefresh = false,
  ]);

  Future<Response<auth.UserCredential>> linkWithCredential(
    auth.AuthCredential credential,
  );

  Future<Response<auth.ConfirmationResult>> linkWithPhoneNumber(
    String phoneNumber, [
    auth.RecaptchaVerifier? verifier,
  ]);

  Future<Response<auth.UserCredential>> linkWithPopup(
      auth.AuthProvider provider);

  Future<Response<auth.UserCredential>> linkWithProvider(
    auth.AuthProvider provider,
  );

  Future<Response<void>> linkWithRedirect(auth.AuthProvider provider);

  Future<Response<void>> reload();

  Future<Response<auth.UserCredential>> reauthenticateWithCredential(
    auth.AuthCredential credential,
  );

  Future<Response<auth.UserCredential>> reauthenticateWithPopup(
    auth.AuthProvider provider,
  );

  Future<Response<auth.UserCredential>> reauthenticateWithProvider(
    auth.AuthProvider provider,
  );

  Future<Response<void>> reauthenticateWithRedirect(
    auth.AuthProvider provider,
  );

  Future<Response<void>> sendEmailVerification([
    auth.ActionCodeSettings? actionCodeSettings,
  ]);

  Future<Response<void>> updateDisplayName(String? displayName);

  Future<Response<void>> updatePassword(String newPassword);

  Future<Response<void>> updatePhoneNumber(auth.PhoneAuthCredential credential);

  Future<Response<void>> updatePhotoURL(String? photoUrl);

  Future<Response<void>> updateProfile({
    String? displayName,
    String? photoURL,
  });

  Future<Response<auth.User>> unlink(String providerId);

  Future<Response<void>> verifyBeforeUpdateEmail(
    String newEmail, [
    auth.ActionCodeSettings? actionCodeSettings,
  ]);
}

class UserDelegate extends IUserDelegate {
  const UserDelegate();

  @override
  auth.User? get user {
    try {
      return auth.FirebaseAuth.instance.currentUser;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<Response<void>> delete() async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.delete().then((value) {
        return Response(status: Status.ok, message: "Account deleted!");
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<String>> getIdToken([bool forceRefresh = false]) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.getIdToken(forceRefresh).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.IdTokenResult>> getIdTokenResult([
    bool forceRefresh = false,
  ]) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.getIdTokenResult(forceRefresh).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> linkWithCredential(
    auth.AuthCredential credential,
  ) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.linkWithCredential(credential).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.ConfirmationResult>> linkWithPhoneNumber(
    String phoneNumber, [
    auth.RecaptchaVerifier? verifier,
  ]) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.linkWithPhoneNumber(phoneNumber, verifier).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> linkWithPopup(
    auth.AuthProvider provider,
  ) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.linkWithPopup(provider).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> linkWithProvider(
      auth.AuthProvider provider) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.linkWithProvider(provider).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> linkWithRedirect(auth.AuthProvider provider) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.linkWithRedirect(provider).then((value) {
        return Response(status: Status.ok);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> reload() async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.reload().then((value) {
        return Response(status: Status.ok);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> reauthenticateWithCredential(
    auth.AuthCredential credential,
  ) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.reauthenticateWithCredential(credential).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> reauthenticateWithPopup(
    auth.AuthProvider provider,
  ) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.reauthenticateWithPopup(provider).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> reauthenticateWithProvider(
    auth.AuthProvider provider,
  ) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.reauthenticateWithProvider(provider).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> reauthenticateWithRedirect(
    auth.AuthProvider provider,
  ) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.reauthenticateWithRedirect(provider).then((value) {
        return Response(status: Status.ok);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> sendEmailVerification([
    auth.ActionCodeSettings? actionCodeSettings,
  ]) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.sendEmailVerification(actionCodeSettings).then((value) {
        return Response(status: Status.ok);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> updateDisplayName(String? displayName) async {
    final user = this.user;
    if (user == null) {
      return Response(
        status: Status.notFound,
        exception: "User account hasn't found!",
      );
    }
    try {
      await user.updateDisplayName(displayName);
      return Response(status: Status.ok, message: "Display name updated!");
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> updatePassword(String newPassword) async {
    final user = this.user;
    if (user == null) {
      return Response(
        status: Status.notFound,
        exception: "User account hasn't found!",
      );
    }
    try {
      await user.updatePassword(newPassword);
      return Response(status: Status.ok, message: "Password updated!");
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> updatePhoneNumber(
    auth.PhoneAuthCredential credential,
  ) async {
    final user = this.user;
    if (user == null) {
      return Response(
        status: Status.notFound,
        exception: "User account hasn't found!",
      );
    }
    try {
      await user.updatePhoneNumber(credential);
      return Response(status: Status.ok, message: "Phone number updated!");
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> updatePhotoURL(String? photoUrl) async {
    final user = this.user;
    if (user == null) {
      return Response(
        status: Status.notFound,
        exception: "User account hasn't found!",
      );
    }
    try {
      await user.updatePhotoURL(photoUrl);
      return Response(status: Status.ok, message: "Photo url updated!");
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = this.user;
    if (user == null) {
      return Response(
        status: Status.notFound,
        exception: "User account hasn't found!",
      );
    }
    try {
      await user.updateProfile(displayName: displayName, photoURL: photoURL);
      return Response(status: Status.ok, message: "Profile updated!");
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.User>> unlink(String providerId) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.unlink(providerId).then((value) {
        return Response(status: Status.ok, data: value);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> verifyBeforeUpdateEmail(
    String newEmail, [
    auth.ActionCodeSettings? actionCodeSettings,
  ]) async {
    final user = this.user;
    if (user == null) {
      return Response(status: Status.invalid, exception: "User invalid!");
    }
    try {
      return user.sendEmailVerification(actionCodeSettings).then((value) {
        return Response(status: Status.ok);
      });
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }
}
