import 'dart:async';

import 'package:auth_management/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as i;

class FirebaseAuthorizer extends Authorizer {
  i.FirebaseAuth? _firebaseAuth;

  i.FirebaseAuth get firebaseAuth {
    return _firebaseAuth ?? i.FirebaseAuth.instance;
  }

  @override
  String? customAuthDomain;

  @override
  String? tenantId;

  @override
  Future<void> applyActionCode(String code) {
    return firebaseAuth.applyActionCode(code);
  }

  @override
  Stream<IUser?> authStateChanges() {
    final controller = StreamController<IUser?>();
    firebaseAuth.authStateChanges().listen((root) {
      if (root != null) {
        controller.add(_user(root));
      }
    });
    return controller.stream;
  }

  IUser? _user(i.User? root) {
    if (root != null) {
      return IUser(
        displayName: root.displayName,
        email: root.email,
        emailVerified: root.emailVerified,
        isAnonymous: root.isAnonymous,
        metadata: _iUserMetadata(root.metadata),
        phoneNumber: root.phoneNumber,
        photoURL: root.photoURL,
        refreshToken: root.refreshToken,
        providerData: _iProviderData(root.providerData),
        tenantId: root.tenantId,
        uid: root.uid,
        multiFactor: _multiFactor(root.multiFactor),
        delete: root.delete,
        getIdToken: root.getIdToken,
        getIdTokenResult: (forceRefresh) {
          return root.getIdTokenResult(forceRefresh).then((value) {
            return IIdTokenResult(
              authTime: value.authTime,
              claims: value.claims,
              expirationTime: value.expirationTime,
              issuedAtTime: value.issuedAtTime,
              signInProvider: value.signInProvider,
              token: value.token,
            );
          });
        },
        linkWithCredential: (a) {
          return root.linkWithCredential(_authCredential(a)!).then((value) {
            return IUserCredential(
              additionalUserInfo: _iAdditionalUserInfo(
                value.additionalUserInfo,
              ),
              credential: _iAuthCredential(value.credential),
              user: _user(value.user),
            );
          });
        },
        linkWithProvider: (a) {
          return root.linkWithProvider(_authProvider(a)).then((b) {
            return _iUserCredential(b)!;
          });
        },
        reauthenticateWithProvider: root.reauthenticateWithProvider,
        reauthenticateWithPopup: root.reauthenticateWithPopup,
        reauthenticateWithRedirect: root.reauthenticateWithRedirect,
        linkWithPopup: root.linkWithPopup,
        linkWithRedirect: root.linkWithRedirect,
        linkWithPhoneNumber: root.linkWithPhoneNumber,
        reauthenticateWithCredential: root.reauthenticateWithCredential,
        reload: root.reload,
        sendEmailVerification: root.sendEmailVerification,
        unlink: root.unlink,
        updatePassword: root.updatePassword,
        updatePhoneNumber: root.updatePhoneNumber,
        updateDisplayName: root.updateDisplayName,
        updatePhotoURL: root.updatePhotoURL,
        updateProfile: root.updateProfile,
        verifyBeforeUpdateEmail: root.verifyBeforeUpdateEmail,
      );
    }
    return null;
  }

  i.AuthCredential? _authCredential(IAuthCredential? a) {
    if (a == null) return null;
    return i.AuthCredential(
      accessToken: a.accessToken,
      providerId: a.providerId,
      signInMethod: a.signInMethod,
      token: a.token,
    );
  }

  i.AuthProvider _authProvider(IAuthProvider value) {
    return i.SAMLAuthProvider(value.providerId);
  }

  IAdditionalUserInfo? _iAdditionalUserInfo(i.AdditionalUserInfo? value) {
    return null;
  }

  IAuthCredential? _iAuthCredential(i.AuthCredential? value) {
    return null;
  }

  IUserCredential? _iUserCredential(i.UserCredential? root) {
    return null;
  }

  IUserMetadata _iUserMetadata(i.UserMetadata data) {
    return IUserMetadata(
      creationTime: data.creationTime,
      lastSignInTime: data.lastSignInTime,
    );
  }

  List<IUserInfo> _iProviderData(List<i.UserInfo> value) {
    return value.map((e) {
      return IUserInfo(
        displayName: e.displayName,
        email: e.email,
        phoneNumber: e.phoneNumber,
        photoURL: e.photoURL,
        providerId: e.providerId,
        uid: e.uid,
      );
    }).toList();
  }

  IMultiFactor _multiFactor(i.MultiFactor data) {
    return IMultiFactor(
      getSession: () async {},
    );
    // return IMultiFactor(
    //   getSession: () {
    //     return data.getSession().then((value) {
    //       return IMultiFactorSession(value.id);
    //     });
    //   },
    //   enroll: (a) async {
    //     return
    //   },
    //   unenroll: data.unenroll,
    //   getEnrolledFactors: data.getEnrolledFactors,
    // );
  }

  @override
  Future<IActionCodeInfo> checkActionCode(String code) {
    // TODO: implement checkActionCode
    throw UnimplementedError();
  }

  @override
  Future<void> confirmPasswordReset(
      {required String code, required String newPassword}) {
    // TODO: implement confirmPasswordReset
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> createUserWithEmailAndPassword(
      {required String email, required String password}) {
    // TODO: implement createUserWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  // TODO: implement currentUser
  IUser? get currentUser => throw UnimplementedError();

  @override
  Future<IUserCredential> getRedirectResult() {
    // TODO: implement getRedirectResult
    throw UnimplementedError();
  }

  @override
  Stream<IUser?> idTokenChanges() {
    // TODO: implement idTokenChanges
    throw UnimplementedError();
  }

  @override
  bool isSignInWithEmailLink(String emailLink) {
    // TODO: implement isSignInWithEmailLink
    throw UnimplementedError();
  }

  @override
  // TODO: implement languageCode
  String? get languageCode => throw UnimplementedError();

  @override
  // TODO: implement pluginConstants
  Map get pluginConstants => throw UnimplementedError();

  @override
  Future<void> revokeTokenWithAuthorizationCode(String authorizationCode) {
    // TODO: implement revokeTokenWithAuthorizationCode
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(
      {required String email, IActionCodeSettings? actionCodeSettings}) {
    // TODO: implement sendPasswordResetEmail
    throw UnimplementedError();
  }

  @override
  Future<void> sendSignInLinkToEmail(
      {required String email,
      required IActionCodeSettings actionCodeSettings}) {
    // TODO: implement sendSignInLinkToEmail
    throw UnimplementedError();
  }

  @override
  Future<void> setLanguageCode(String? languageCode) {
    // TODO: implement setLanguageCode
    throw UnimplementedError();
  }

  @override
  Future<void> setPersistence(IPersistence persistence) {
    // TODO: implement setPersistence
    throw UnimplementedError();
  }

  @override
  Future<void> setSettings(
      {bool appVerificationDisabledForTesting = false,
      String? userAccessGroup,
      String? phoneNumber,
      String? smsCode,
      bool? forceRecaptchaFlow}) {
    // TODO: implement setSettings
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> signInAnonymously() {
    // TODO: implement signInAnonymously
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> signInWithCredential(IAuthCredential credential) {
    // TODO: implement signInWithCredential
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> signInWithCustomToken(String token) {
    // TODO: implement signInWithCustomToken
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> signInWithEmailAndPassword(
      {required String email, required String password}) {
    // TODO: implement signInWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> signInWithEmailLink(
      {required String email, required String emailLink}) {
    // TODO: implement signInWithEmailLink
    throw UnimplementedError();
  }

  @override
  Future<IConfirmationResult> signInWithPhoneNumber(String phoneNumber,
      [IRecaptchaVerifier? verifier]) {
    // TODO: implement signInWithPhoneNumber
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> signInWithPopup(IAuthProvider provider) {
    // TODO: implement signInWithPopup
    throw UnimplementedError();
  }

  @override
  Future<IUserCredential> signInWithProvider(IAuthProvider provider) {
    // TODO: implement signInWithProvider
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithRedirect(IAuthProvider provider) {
    // TODO: implement signInWithRedirect
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<void> useAuthEmulator(String host, int port,
      {bool automaticHostMapping = true}) {
    // TODO: implement useAuthEmulator
    throw UnimplementedError();
  }

  @override
  Stream<IUser?> userChanges() {
    // TODO: implement userChanges
    throw UnimplementedError();
  }

  @override
  Future<String> verifyPasswordResetCode(String code) {
    // TODO: implement verifyPasswordResetCode
    throw UnimplementedError();
  }

  @override
  Future<void> verifyPhoneNumber(
      {String? phoneNumber,
      IPhoneMultiFactorInfo? multiFactorInfo,
      required IPhoneVerificationCompleted verificationCompleted,
      required IPhoneVerificationFailed verificationFailed,
      required IPhoneCodeSent codeSent,
      required IPhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      String? autoRetrievedSmsCodeForTesting,
      Duration timeout = const Duration(seconds: 30),
      int? forceResendingToken,
      IMultiFactorSession? multiFactorSession}) {
    // TODO: implement verifyPhoneNumber
    throw UnimplementedError();
  }
}
