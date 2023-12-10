part of 'controllers.dart';

/// to observe the auth state with live update when auth status change
class AuthProvider extends InheritedWidget {
  final AuthController controller;
  final AuthNotifier notifier;

  AuthProvider({
    super.key,
    required this.controller,
    required Widget child,
  })  : notifier = AuthNotifier(const AuthResponse.initial()),
        super(child: _Support(controller: controller, child: child));

  static AuthProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
  }

  static AuthController controllerOf(
    BuildContext context, [
    AuthController? secondary,
  ]) {
    return of(context)?.controller ?? secondary ?? AuthController();
  }

  @override
  bool updateShouldNotify(covariant AuthProvider oldWidget) {
    return notifier.value != oldWidget.notifier.value;
  }

  void notify(AuthResponse value) => notifier.setValue(value);
}
