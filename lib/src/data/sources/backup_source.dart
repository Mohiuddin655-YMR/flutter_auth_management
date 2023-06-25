part of 'sources.dart';

abstract class BackupSource<T extends Authenticator> extends AuthDataSource<T> {
  BackupSource({
    super.preferences,
  });

  @override
  Future<Response<T>> create(T data) async {
    final response = Response<T>();
    var isSuccessful = await preferences.input("uid", data.source);
    if (isSuccessful) {
      return response.withStatus(Status.ok);
    } else {
      return response.withStatus(Status.failure);
    }
  }

  @override
  Future<Response<T>> delete(T data) async {
    final response = Response<T>();
    var isSuccessful = await preferences.input("uid", null);
    if (isSuccessful) {
      return response.withStatus(Status.ok);
    } else {
      return response.withStatus(Status.failure);
    }
  }

  @override
  Future<Response<T>> load() async {
    final response = Response<T>();
    var result = preferences.output("uid");
    if (result is Map<String, dynamic>) {
      var data = build(result);
      return response.withData(data);
    } else {
      return response.withStatus(Status.failure);
    }
  }
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
