part of 'core.dart';

class _Support<T extends Auth> extends StatefulWidget {
  final AuthController<T> controller;
  final Widget child;

  const _Support({
    required this.child,
    required this.controller,
  });

  @override
  State<_Support<T>> createState() => _SupportState<T>();
}

class _SupportState<T extends Auth> extends State<_Support<T>> {
  @override
  void dispose() {
    widget.controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
