part of 'repositories.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource source;

  AuthRepositoryImpl({
    required this.source,
  });

  @override
  User? get user => source.user;

  @override
  Future<Response> get delete => source.delete;

  @override
  Future<bool> isSignIn([AuthProviders? provider]) => source.isSignIn();

  @override
  Future<Response<Credential>> signInWithApple() => source.signInWithApple();

  @override
  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  }) {
    return source.signInWithBiometric(config: config);
  }

  @override
  Future<Response<UserCredential>> signInWithCredential({
    required AuthCredential credential,
  }) {
    return source.signInWithCredential(credential: credential);
  }

  @override
  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return source.signInWithEmailNPassword(email: email, password: password);
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    return source.signInWithFacebook();
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    return source.signInWithGithub();
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    return source.signInWithGoogle();
  }

  @override
  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return source.signInWithUsernameNPassword(
      username: username,
      password: password,
    );
  }

  @override
  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return source.signUpWithEmailNPassword(email: email, password: password);
  }

  @override
  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return source.signUpWithUsernameNPassword(
      username: username,
      password: password,
    );
  }

  @override
  Future<Response<Auth>> signOut([AuthProviders? provider]) => source.signOut();

  @override
  Future<Response<void>> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(PhoneAuthCredential credential) onComplete,
    required void Function(FirebaseAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  }) {
    return source.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      multiFactorInfo: multiFactorInfo,
      multiFactorSession: multiFactorSession,
      timeout: timeout,
      onComplete: onComplete,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }
}
