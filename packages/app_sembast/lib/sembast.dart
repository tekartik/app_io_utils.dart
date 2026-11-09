import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart' as sembast_memory;

import 'src/sembast.dart' as src;

export 'package:sembast/sembast.dart';

/// In memory factory (sembast memory with a simulated file system), for unit
/// tests.
DatabaseFactory get databaseFactoryMemory =>
    sembast_memory.databaseFactoryMemoryFs;

/// The sembast factory of an io program: sembast_sqflite on the
/// sqflite_common_ffi factory.
///
/// On Linux, macOS and Windows the database names are relative to [rootPath],
/// or to `<userAppDataPath>/<packageName>/databases`. On the other io
/// platforms the parameters are ignored; on the web this throws
/// [UnimplementedError] (use `tekartik_app_flutter_sembast` in a Flutter
/// app).
///
/// Every factory returned uses the one process-wide ffi factory and each call
/// sets its databases path: call it once and keep the result.
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    src.getDatabaseFactory(packageName: packageName, rootPath: rootPath);
