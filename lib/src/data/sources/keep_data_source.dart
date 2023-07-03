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
  Future<Response<T>> get() async {
    final response = Response<T>();
    var result = preferences.output(key);
    if (result is Map<String, dynamic>) {
      var data = build(result);
      return response.withData(data);
    } else {
      return response.withStatus(Status.failure);
    }
  }

  @override
  Future<Response<T>> set(T data) async {
    final response = Response<T>();
    var isSuccessful = await preferences.input(key, data.source);
    if (isSuccessful) {
      return response.withStatus(Status.ok);
    } else {
      return response.withStatus(Status.failure);
    }
  }

  @override
  Future<Response<T>> delete() async {
    final response = Response<T>();
    var isSuccessful = await preferences.input(key, null);
    if (isSuccessful) {
      return response.withStatus(Status.ok);
    } else {
      return response.withStatus(Status.failure);
    }
  }

  @override
  Future<Response<T>> clear() async {
    final response = Response<T>();
    var isSuccessful = await preferences.input(key, null);
    if (isSuccessful) {
      return response.withStatus(Status.ok);
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
