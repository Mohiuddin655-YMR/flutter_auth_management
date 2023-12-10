part of 'controllers.dart';

class _Support extends StatelessWidget {
  final AuthController controller;
  final Widget child;

  const _Support({
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    AuthManager.init(context);
    return _Secondary(
      controller: controller,
      child: child,
    );
  }
}

class _Secondary extends StatefulWidget {
  final AuthController controller;
  final Widget child;

  const _Secondary({
    required this.controller,
    required this.child,
  });

  @override
  State<_Secondary> createState() => _SecondaryState();
}

class _SecondaryState extends State<_Secondary> {
  @override
  void initState() {
    widget.controller.isLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
