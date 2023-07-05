part of 'sources.dart';

abstract class BackupSourceImpl<T extends Auth> extends BackupSource<T> {
  BackupSourceImpl({
    super.preferences,
  });

  @override
  Future<T> getCache() async {
    var result = await preferences.output(key);
    if (result.isNotEmpty) {
      return build(result);
    } else {
      return Future.error("Data not initialized!");
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
}
