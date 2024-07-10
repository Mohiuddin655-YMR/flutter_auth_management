import 'additional_user_info.dart';
import 'auth_credential.dart';
import 'user.dart';

class IUserCredential {
  final IAdditionalUserInfo? additionalUserInfo;
  final IAuthCredential? credential;
  final IUser? user;

  const IUserCredential({
    this.additionalUserInfo,
    this.credential,
    this.user,
  });
}
