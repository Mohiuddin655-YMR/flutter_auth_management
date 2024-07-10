import '../providers/phone_auth.dart';
import 'action_code_info.dart';
import 'action_code_settings.dart';
import 'auth_credential.dart';
import 'auth_provider.dart';
import 'confirmation_result.dart';
import 'exception.dart';
import 'multi_factor.dart';
import 'persistence.dart';
import 'recaptcha_verifier.dart';
import 'user.dart';
import 'user_credential.dart';

typedef IPhoneVerificationCompleted = void Function(
  IPhoneAuthCredential phoneAuthCredential,
);

typedef IPhoneVerificationFailed = void Function(IAuthException error);

typedef IPhoneCodeSent = void Function(
  String verificationId,
  int? forceResendingToken,
);

typedef IPhoneCodeAutoRetrievalTimeout = void Function(
  String verificationId,
);

abstract class Authorizer {
  const Authorizer();

  IUser? get currentUser;

  String? get languageCode;

  Future<void> useAuthEmulator(
    String host,
    int port, {
    bool automaticHostMapping = true,
  });

  String? get tenantId;

  set tenantId(String? tenantId);

  String? get customAuthDomain;

  set customAuthDomain(String? customAuthDomain);

  Future<void> applyActionCode(String code);

  Future<IActionCodeInfo> checkActionCode(String code);

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  Future<IUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<IUserCredential> getRedirectResult();

  bool isSignInWithEmailLink(String emailLink);

  Stream<IUser?> authStateChanges();

  Stream<IUser?> idTokenChanges();

  Stream<IUser?> userChanges();

  Future<void> sendPasswordResetEmail({
    required String email,
    IActionCodeSettings? actionCodeSettings,
  });

  Future<void> sendSignInLinkToEmail({
    required String email,
    required IActionCodeSettings actionCodeSettings,
  });

  Future<void> setLanguageCode(String? languageCode);

  Future<void> setSettings({
    bool appVerificationDisabledForTesting = false,
    String? userAccessGroup,
    String? phoneNumber,
    String? smsCode,
    bool? forceRecaptchaFlow,
  });

  Future<void> setPersistence(IPersistence persistence);

  Future<IUserCredential> signInAnonymously();

  Future<IUserCredential> signInWithCredential(IAuthCredential credential);

  Future<IUserCredential> signInWithCustomToken(String token);

  Future<IUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<IUserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  });

  Future<IUserCredential> signInWithProvider(
    IAuthProvider provider,
  );

  Future<IConfirmationResult> signInWithPhoneNumber(
    String phoneNumber, [
    IRecaptchaVerifier? verifier,
  ]);

  Future<IUserCredential> signInWithPopup(IAuthProvider provider);

  Future<void> signInWithRedirect(IAuthProvider provider);

  Future<void> signOut();

  Future<String> verifyPasswordResetCode(String code);

  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    IPhoneMultiFactorInfo? multiFactorInfo,
    required IPhoneVerificationCompleted verificationCompleted,
    required IPhoneVerificationFailed verificationFailed,
    required IPhoneCodeSent codeSent,
    required IPhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    IMultiFactorSession? multiFactorSession,
  });

  Future<void> revokeTokenWithAuthorizationCode(String authorizationCode);

  /// SUPER PROPERTIES
  Map<dynamic, dynamic> get pluginConstants;
}
