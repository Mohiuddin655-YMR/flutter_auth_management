import '../providers/phone_auth.dart';
import 'action_code_settings.dart';
import 'auth_credential.dart';
import 'auth_provider.dart';
import 'confirmation_result.dart';
import 'id_token_result.dart';
import 'multi_factor.dart';
import 'recaptcha_verifier.dart';
import 'user_credential.dart';
import 'user_info.dart';
import 'user_metadata.dart';

typedef IUserDelete = Future<void> Function();

typedef IUserGetIdToken = Future<String?> Function([bool forceRefresh]);

typedef IUserGetIdTokenResult = Future<IIdTokenResult> Function(
  bool forceRefresh,
);

typedef IUserLinkWithCredential = Future<IUserCredential> Function(
  IAuthCredential credential,
);

typedef IUserLinkWithProvider = Future<IUserCredential> Function(
  IAuthProvider provider,
);

typedef IUserReauthenticateWithProvider = Future<IUserCredential> Function(
  IAuthProvider provider,
);

typedef IUserReauthenticateWithPopup = Future<IUserCredential> Function(
  IAuthProvider provider,
);

typedef IUserReauthenticateWithRedirect = Future<void> Function(
  IAuthProvider provider,
);

typedef IUserLinkWithPopup = Future<IUserCredential> Function(
  IAuthProvider provider,
);

typedef IUserLinkWithRedirect = Future<void> Function(IAuthProvider provider);

typedef IUserLinkWithPhoneNumber = Future<IConfirmationResult> Function(
  String phoneNumber, [
  IRecaptchaVerifier? verifier,
]);

typedef IUserReauthenticateWithCredential = Future<IUserCredential> Function(
  IAuthCredential credential,
);

typedef IUserReload = Future<void> Function();

typedef IUserSendEmailVerification = Future<void> Function([
  IActionCodeSettings? actionCodeSettings,
]);

typedef IUserUnlink = Future<IUser> Function(String providerId);

typedef IUserUpdatePassword = Future<void> Function(String newPassword);

typedef IUserUpdatePhoneNumber = Future<void> Function(
  IPhoneAuthCredential phoneCredential,
);

typedef IUserUpdateDisplayName = Future<void> Function(String? displayName);

typedef IUserUpdatePhotoURL = Future<void> Function(String? photoURL);

typedef IUserUpdateProfile = Future<void> Function({
  String? displayName,
  String? photoURL,
});

typedef IUserVerifyBeforeUpdateEmail = Future<void> Function(
  String newEmail, [
  IActionCodeSettings? actionCodeSettings,
]);

abstract class IUser {
  /// FIELDS
  final String? displayName;
  final String? email;
  final bool emailVerified;
  final bool isAnonymous;
  final IUserMetadata metadata;
  final String? phoneNumber;
  final String? photoURL;
  final List<IUserInfo> providerData;
  final String? refreshToken;
  final String? tenantId;
  final String uid;
  final IMultiFactor multiFactor;

  /// CALLBACKS
  final IUserDelete delete;
  final IUserGetIdToken getIdToken;
  final IUserGetIdTokenResult getIdTokenResult;
  final IUserLinkWithCredential linkWithCredential;
  final IUserLinkWithProvider linkWithProvider;
  final IUserReauthenticateWithProvider reauthenticateWithProvider;
  final IUserReauthenticateWithPopup reauthenticateWithPopup;
  final IUserReauthenticateWithRedirect reauthenticateWithRedirect;
  final IUserLinkWithPopup linkWithPopup;
  final IUserLinkWithRedirect linkWithRedirect;
  final IUserLinkWithPhoneNumber linkWithPhoneNumber;
  final IUserReauthenticateWithCredential reauthenticateWithCredential;
  final IUserReload reload;
  final IUserSendEmailVerification sendEmailVerification;
  final IUserUnlink unlink;
  final IUserUpdatePassword updatePassword;
  final IUserUpdatePhoneNumber updatePhoneNumber;
  final IUserUpdateDisplayName updateDisplayName;
  final IUserUpdatePhotoURL updatePhotoURL;
  final IUserUpdateProfile updateProfile;
  final IUserVerifyBeforeUpdateEmail verifyBeforeUpdateEmail;

  const IUser({
    /// FIELDS
    this.displayName,
    this.email,
    required this.emailVerified,
    required this.isAnonymous,
    required this.metadata,
    this.phoneNumber,
    this.photoURL,
    required this.providerData,
    this.refreshToken,
    this.tenantId,
    required this.uid,
    required this.multiFactor,

    /// CALLBACKS
    required this.delete,
    required this.getIdToken,
    required this.getIdTokenResult,
    required this.linkWithCredential,
    required this.linkWithProvider,
    required this.reauthenticateWithProvider,
    required this.reauthenticateWithPopup,
    required this.reauthenticateWithRedirect,
    required this.linkWithPopup,
    required this.linkWithRedirect,
    required this.linkWithPhoneNumber,
    required this.reauthenticateWithCredential,
    required this.reload,
    required this.sendEmailVerification,
    required this.unlink,
    required this.updatePassword,
    required this.updatePhoneNumber,
    required this.updateDisplayName,
    required this.updatePhotoURL,
    required this.updateProfile,
    required this.verifyBeforeUpdateEmail,
  });
}
