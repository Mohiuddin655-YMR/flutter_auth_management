import 'dart:convert';
import 'dart:core';

import 'package:flutter_andomie/core.dart';

import '../../models/auth.dart';
import '../../services/sources/backup_data_source.dart';

part 'backup_data_source_impl.dart';

abstract class BackupDataSourceImpl<T extends Auth>
    extends BackupDataSource<T> {
  BackupDataSourceImpl({
    super.database,
  });

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
}
