part of 'sources.dart';

abstract class BackupDataSourceImpl extends BackupDataSource {
  BackupDataSourceImpl({
    super.database,
  });

  @override
  Future<Auth?> getCache() async {
    var result = await database.output(key);
    if (result.isNotEmpty) {
      return Auth.from(result);
    } else {
      return null;
    }
  }

  @override
  Future<bool> setCache(Auth? data) async {
    var isSuccessful = await database.input(key, data?.source);
    return isSuccessful;
  }

  @override
  Future<bool> removeCache() async {
    var isSuccessful = await database.input(key, null);
    return isSuccessful;
  }
}
