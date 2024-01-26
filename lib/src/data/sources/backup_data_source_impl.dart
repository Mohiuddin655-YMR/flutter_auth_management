part of 'authorized_data_source.dart';

extension _LocalExtension on Future<LocalDatabase> {
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
        return db.removeItem(key);
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
