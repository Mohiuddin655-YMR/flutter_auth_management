import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth.dart';

class AuthNotifier<T extends Auth> extends ChangeNotifier {
  final StreamController<T?> _controller = StreamController();

  T? value;

  AuthNotifier();

  void notify(T? value) {
    this.value = value;
    _controller.add(value);
    notifyListeners();
  }

  Stream<T?> get stream => _controller.stream;

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
