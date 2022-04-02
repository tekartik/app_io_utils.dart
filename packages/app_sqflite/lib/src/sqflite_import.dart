import 'package:sqflite_common/sqlite_api.dart';

// Temp direct call needed when nndb ready
extension DatabasesFactorySetDatabasesPathExt on DatabaseFactory {
  Future<void> compatSetDatabasesPath(String path) {
    return setDatabasesPath(path);
  }
}
