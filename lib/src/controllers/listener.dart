part of 'controllers.dart';

typedef OnAuthListener = void Function(
  BuildContext context,
  AuthResponse response,
);

class AuthListener extends StatelessWidget {
  final OnAuthListener listener;
  final Widget child;

  const AuthListener({
    super.key,
    required this.listener,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final provider = AuthProvider.of(context);
    if (provider != null) {
      return _Listener(
        observer: provider.notifier,
        listener: listener,
        child: child,
      );
    } else {
      throw UnimplementedError("Auth provider not found!");
    }
  }
}

class _Listener extends StatefulWidget {
  final ValueListenable<AuthResponse> observer;
  final OnAuthListener listener;
  final Widget child;

  const _Listener({
    required this.observer,
    required this.listener,
    required this.child,
  });

  @override
  State<_Listener> createState() => _ListenerState();
}

class _ListenerState extends State<_Listener> {
  @override
  void initState() {
    super.initState();
    widget.observer.addListener(_change);
  }

  @override
  void didUpdateWidget(_Listener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observer != widget.observer) {
      oldWidget.observer.removeListener(_change);
      widget.observer.addListener(_change);
    }
  }

  @override
  void dispose() {
    widget.observer.removeListener(_change);
    super.dispose();
  }

  void _change() => widget.listener(context, widget.observer.value);

  @override
  Widget build(BuildContext context) => widget.child;
}
