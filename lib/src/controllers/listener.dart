part of 'controllers.dart';

/// to listen auth status anywhere with [AuthObserver]
class AuthObserver extends StatelessWidget {
  final void Function(BuildContext context, AuthResponse state)? listener;
  final Widget Function(BuildContext context, AuthResponse state) builder;

  const AuthObserver({
    super.key,
    this.listener,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    var provider = context.findAuthProvider();
    if (provider != null) {
      return ValueListenableBuilder(
        valueListenable: provider.notifier,
        builder: (context, value, old) {
          if (listener != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              listener!(context, value);
              AuthManager.onStatusChange(value);
            });
          }
          return builder(context, value);
        },
      );
    } else {
      throw UnimplementedError("Auth provider not found!");
    }
  }
}
