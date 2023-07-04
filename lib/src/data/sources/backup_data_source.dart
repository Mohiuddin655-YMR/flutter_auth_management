part of 'sources.dart';

class BackupDataSourceImpl<T extends Authenticator>
    extends BackupDataSource<T> {
  final String key = "uid";

  BackupDataSourceImpl({
    super.preferences,
  });

  @override
  Future<void> onCreated(T data) async {}

  @override
  Future<void> onDeleted(String id) async {}

  @override
  Future<T> getCache() async {
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
  Future<bool> removeCache() async {
    var isSuccessful = await preferences.input(key, null);
    if (isSuccessful) {
      return true;
    } else {
      return Future.error("Data not removed!");
    }
  }

  @override
  T build(source) => Authenticator.from(source) as T;
}
