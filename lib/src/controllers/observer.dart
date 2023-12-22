part of 'controllers.dart';

typedef AuthConsumerBuilder = Widget Function(
  BuildContext context,
  AuthResponse response,
);

/// to listen auth status anywhere with [AuthConsumer]
class AuthConsumer extends StatefulWidget {
  final OnAuthListener listener;
  final AuthConsumerBuilder builder;

  const AuthConsumer({
    super.key,
    required this.listener,
    required this.builder,
  });

  @override
  State<AuthConsumer> createState() => _AuthConsumerState();
}

class _AuthConsumerState extends State<AuthConsumer> {
  AuthResponse response = const AuthResponse.initial();

  @override
  Widget build(context) {
    return AuthListener(
      listener: (context, value) {
        widget.listener(context, value);
        setState(() => response = value);
      },
      child: widget.builder(context, response),
    );
  }
}
