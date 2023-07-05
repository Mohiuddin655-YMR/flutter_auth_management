part of 'sources.dart';

class KeepDataSource<T extends Auth> extends BackupSourceImpl<T> {
  KeepDataSource({
    super.preferences,
  });

  @override
  Future<void> onCreated(T data) async {}

  @override
  Future<void> onDeleted(String id) async {}

  @override
  T build(source) => Auth.from(source) as T;
}
