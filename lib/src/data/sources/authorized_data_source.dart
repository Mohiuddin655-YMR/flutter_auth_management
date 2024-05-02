import 'dart:convert';
import 'dart:core';

import 'package:flutter_entity/flutter_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../delegates/backup.dart';
import '../../models/auth.dart';
import '../../services/sources/authorized_data_source.dart';

part '../../extensions/backup.dart';

class AuthorizedDataSourceImpl<T extends Auth> extends AuthorizedDataSource<T> {
  final BackupDelegate<T>? delegate;

  AuthorizedDataSourceImpl([this.delegate]);

  @override
  Future<T?> get cache {
    return database.output(key).then((value) {
      if (value.isNotEmpty) {
        return build(value);
      } else {
        return null;
      }
    });
  }

  @override
  Future<bool> set(T? data) {
    return database.input(key, data?.source);
  }

  @override
  Future<bool> update(Map<String, dynamic> data) {
    return cache.then((value) {
      if (value != null) {
        final current = value.source..addAll(data);
        return database.input(key, current);
      } else {
        return false;
      }
    });
  }

  @override
  Future<bool> clear() {
    return database.input(key, null);
  }

  @override
  Future<T?> onFetchUser(String id) {
    if (delegate != null) {
      return delegate!.get(id);
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<void> onCreateUser(T data) {
    if (delegate != null) {
      return delegate!.create(data);
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<void> onDeleteUser(String id) {
    if (delegate != null) {
      return delegate!.delete(id);
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<void> onUpdateUser(String id, Map<String, dynamic> data) {
    if (delegate != null) {
      return delegate!.update(id, data);
    } else {
      return Future.value(null);
    }
  }

  @override
  T build(Map<String, dynamic> source) {
    if (delegate != null) {
      return delegate!.build(source);
    } else {
      return Auth.from(source) as T;
    }
  }
}
