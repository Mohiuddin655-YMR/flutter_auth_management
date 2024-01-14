part of 'core.dart';

class AuthObserver<T extends Auth> extends StatelessWidget {
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener? onStateChange;
  final OnAuthResponse<T>? onResponse;
  final Widget child;

  const AuthObserver({
    super.key,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStateChange,
    this.onResponse,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final provider = AuthProvider.of<T>(context);
    if (provider != null) {
      return _Observer<T>(
        observer: provider.notifier,
        onError: onError,
        onLoading: onLoading,
        onMessage: onMessage,
        onStateChange: onStateChange,
        onResponse: onResponse,
        child: child,
      );
    } else {
      throw UnimplementedError("Auth provider not found!");
    }
  }
}

class _Observer<T extends Auth> extends StatefulWidget {
  final AuthNotifier<T> observer;
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener? onStateChange;
  final OnAuthResponse<T>? onResponse;
  final Widget child;

  const _Observer({
    required this.observer,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStateChange,
    this.onResponse,
    required this.child,
  });

  @override
  State<_Observer<T>> createState() => _ObserverState<T>();
}

class _ObserverState<T extends Auth> extends State<_Observer<T>> {
  @override
  void initState() {
    super.initState();
    widget.observer.addListener(_change);
  }

  @override
  void didUpdateWidget(_Observer<T> oldWidget) {
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

  void _change() {
    final data = widget.observer.value;
    if (data.isMessage && widget.onMessage != null) {
      widget.onMessage?.call(context, data.message);
    }
    if (data.isLoading && widget.onLoading != null) {
      widget.onLoading?.call(context, data.isLoading);
    } else if (data.isError && widget.onError != null) {
      widget.onError?.call(context, data.error);
    } else if (data.isState && widget.onStateChange != null) {
      widget.onStateChange?.call(context, data.state);
    } else if (widget.onResponse != null) {
      widget.onResponse?.call(context, data);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
