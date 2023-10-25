import '../../../../index.dart';

class AuthCacheManager {
  Future<bool> isFirstEntry() async {
    return !(await CacheManager.getBool(NetworkEnums.introOff.path) ?? false);
  }

  Future<bool> isLoggedIn() async {
    return (await CacheManager.getBool(NetworkEnums.login.path)) ?? false;
  }

  Future<void> signOut() async {
    await CacheManager.clearAll();
  }

  Future<void> updateFirstEntry() async {
    await CacheManager.setBool(NetworkEnums.introOff.path, true);
  }

  Future<void> updateLoggedIn(bool isLoggedIn) async {
    await CacheManager.setBool(NetworkEnums.login.path, isLoggedIn);
  }

  Future<void> updateToken(String? token) async {
    if (token != null) {
      await CacheManager.setString(NetworkEnums.token.path, token);
      DioManager.instance.dio.options
          .headers[(MapEntry('Authorization', 'token $token'))];
    } else {
      if (await CacheManager.containsKey(NetworkEnums.token.path)) {
        await CacheManager.remove(NetworkEnums.token.path);
        DioManager.instance.dio.options.headers.clear();
      }
    }
  }

  Future<void> updateTokenFromStorage() async {
    if (await CacheManager.containsKey(NetworkEnums.token.path)) {
      final token = await CacheManager.getString(NetworkEnums.token.path);
      if (token != null) {
        DioManager.instance.dio.options
            .headers[(MapEntry('Authorization', 'token $token'))];
      }
    }
  }
}
