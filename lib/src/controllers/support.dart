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
    return FutureBuilder(
      future: controller.isLoggedIn(),
      builder: (context, snapshot) {
        return child;
      },
    );
  }
}
