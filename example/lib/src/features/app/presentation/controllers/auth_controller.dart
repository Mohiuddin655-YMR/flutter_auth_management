import 'package:auth_management/core.dart';
import 'package:flutter_andomie/core.dart';

import '../../../index.dart';

class CustomAuthController extends AuthController {
  CustomAuthController({
    super.backupHandler,
    super.messages,
  });

  Future<bool> signIn(AuthInfo data) async {
    await super.signInByEmail(
      EmailAuthenticator(
        email: data.email.use,
        password: data.password.use,
      ),
      biometric: true,
    );
    return true;
  }

  Future<bool> signInWithApple(AuthInfo data) async {
    await super.signInByApple();
    return true;
  }

  Future<bool> signInWithBiometric(AuthInfo data) async {
    try {
      await super.signInByBiometric();
    } catch (_) {
      emit(AuthResponse.failure(_));
    }
    return true;
  }

  Future<bool> signInWithGoogle(AuthInfo data) async {
    await super.signInByGoogle();
    return true;
  }

  Future<bool> signInWithFacebook(AuthInfo data) async {
    await super.signInByFacebook();
    return true;
  }

  Future<bool> signUp(AuthInfo data) async {
    await super.signUpByEmail(
      EmailAuthenticator(
        email: data.email.use,
        password: data.password.use,
      ),
      biometric: true,
    );
    return true;
  }

  Future<bool> forgot(AuthInfo data) async {
    return true;
  }
}
