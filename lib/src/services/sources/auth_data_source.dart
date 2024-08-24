import '../../delegates/auth.dart';
import '../../delegates/user.dart';

abstract class AuthDataSource {
  final IAuthDelegate authDelegate;
  final IUserDelegate userDelegate;

  AuthDataSource({
    IAuthDelegate? auth,
    IUserDelegate? user,
  })  : authDelegate = auth ?? AuthDelegate(),
        userDelegate = user ?? const UserDelegate();
}
