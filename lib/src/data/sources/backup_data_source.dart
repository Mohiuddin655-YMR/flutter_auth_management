part of 'sources.dart';

abstract class BackupDataSourceImpl extends BackupDataSource {
  BackupDataSourceImpl({
    super.database,
  });

  @override
  Future<Authorizer?> getCache() async {
    var result = await database.output(key);
    if (result.isNotEmpty) {
      return Authorizer.from(result);
    } else {
      return null;
    }
  }

  @override
  Future<bool> setCache(Authorizer? data) async {
    var isSuccessful = await database.input(key, data?.source);
    return isSuccessful;
  }

  @override
  Future<bool> removeCache() async {
    var isSuccessful = await database.input(key, null);
    return isSuccessful;
  }
}
