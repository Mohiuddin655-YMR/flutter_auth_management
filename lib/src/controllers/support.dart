part of 'controllers.dart';

class _Support extends StatefulWidget {
  final AuthController controller;
  final Widget child;

  const _Support({
    required this.child,
    required this.controller,
  });

  @override
  State<_Support> createState() => _SupportState();
}

class _SupportState extends State<_Support> {

  @override
  void dispose() {
    AuthManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthManager.init(context);
    return widget.child;
  }
}
