part of 'core.dart';

/// to observe the auth state with live update when auth status change
class AuthProvider<T extends Auth> extends InheritedWidget {
  final AuthController<T> controller;
  final AuthNotifier<T> notifier;

  AuthProvider({
    super.key,
    required this.controller,
    required Widget child,
  })  : notifier = AuthNotifier<T>(const AuthResponse.initial()),
        super(child: _Support<T>(controller: controller, child: child));

  static AuthProvider<T>? of<T extends Auth>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider<T>>();
  }

  static AuthController<T> controllerOf<T extends Auth>(
    BuildContext context, [
    AuthController<T>? secondary,
  ]) {
    return of<T>(context)?.controller ?? secondary ?? AuthControllerImpl<T>();
  }

  @override
  bool updateShouldNotify(covariant AuthProvider<T> oldWidget) {
    return notifier.value != oldWidget.notifier.value;
  }

  void notify(AuthResponse<T> value) => notifier.setValue(value);
}
