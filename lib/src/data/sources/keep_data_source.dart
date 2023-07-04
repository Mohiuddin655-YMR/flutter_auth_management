part of 'sources.dart';

class KeepDataSourceImpl<T extends Authenticator> extends BackupDataSource<T> {
  final String key;

  KeepDataSourceImpl({
    String? key,
    super.preferences,
  }) : key = key ?? "_authorize_id";

  @override
  T build(source) => Authenticator.from(source) as T;

  @override
  Future<T> getCache(String? id) async {
    var result = await preferences.output(key);
    if (result.isNotEmpty) {
      return build(result);
    } else {
      return Future.error("Data not found!");
    }
  }

  @override
  Future<bool> setCache(T data) async {
    var isSuccessful = await preferences.input(key, data.source);
    if (isSuccessful) {
      return true;
    } else {
      return Future.error("Data not inserted!");
    }
  }

  @override
  Future<bool> removeCache(String? id) async {
    var isSuccessful = await preferences.input(key, null);
    if (isSuccessful) {
      return true;
    } else {
      return Future.error("Data not removed!");
    }
  }

  @override
  Future<void> clearCache() => removeCache(key);
}

extension _LocalExtension on Future<SharedPreferences> {
  Future<bool> input(
    String key,
    Map<String, dynamic>? value,
  ) async {
    try {
      final db = await this;
      var data = jsonEncode(value ?? {});
      if (data.isNotEmpty) {
        return db.setString(key, data);
      } else {
        return db.remove(key);
      }
    } catch (_) {
      return Future.error(_);
    }
  }

  Future<Map<String, dynamic>> output<T extends Entity>(String key) async {
    try {
      final db = await this;
      final raw = db.getString(key);
      final data = jsonDecode(raw ?? "{}");
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return {};
      }
    } catch (_) {
      return Future.error(_);
    }
  }
}
