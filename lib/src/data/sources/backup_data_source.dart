part of 'sources.dart';

abstract class BackupSourceImpl extends BackupSource {
  BackupSourceImpl({
    super.database,
  });

  @override
  Future<Auth> getCache() async {
    var result = await database.output(key);
    if (result.isNotEmpty) {
      return Auth.from(result);
    } else {
      return Future.error("Data not initialized!");
    }
  }

  @override
  Future<bool> setCache(Auth data) async {
    var isSuccessful = await database.input(key, data.source);
    if (isSuccessful) {
      return true;
    } else {
      return Future.error("Data not inserted!");
    }
  }

  @override
  Future<bool> removeCache() async {
    var isSuccessful = await database.input(key, null);
    if (isSuccessful) {
      return true;
    } else {
      return Future.error("Data not removed!");
    }
  }
}
