/// sqflite for `dart:io` programs: a `sqflite_common_ffi` database factory
/// with its databases path under the user application data directory
/// ([getDatabaseFactory]), plus the `sqflite_common` API.
library;

import 'package:sqflite_common/sqlite_api.dart';

import 'src/sqflite.dart' as src;

export 'package:sqflite_common/sqflite_dev.dart';
export 'package:sqflite_common/sqlite_api.dart';

/// The ffi database factory (`databaseFactoryFfi` of `sqflite_common_ffi`),
/// on every io platform. Its databases path is the one last set by
/// [getDatabaseFactory] (the same object), the ffi default otherwise.
DatabaseFactory get databaseFactory => src.databaseFactory;

/// For all flutter app (including linux and windows)
///
/// [packageName] only used on linux and windows for now
@Deprecated('Use getDatabaseFactory')
Future<DatabaseFactory> initDatabaseFactory(String packageName) =>
    src.initDatabaseFactory(packageName);

/// The database factory of an io application, on Linux, Windows and macOS:
/// the process-wide ffi factory with its databases path set to [rootPath],
/// or to `<userAppDataPath>/<packageName>/databases` (created when missing).
///
/// Each call sets the path of that one shared factory: call it once and keep
/// the result. Without [packageName] nor [rootPath] every such program shares
/// `<userAppDataPath>/databases`. On other platforms the ffi factory is
/// returned unchanged.
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    src.getDatabaseFactory(packageName: packageName, rootPath: rootPath);

/// Only needed on Windows during development to find the proper dll location
void sqfliteWindowsFfiInit() => src.sqfliteWindowsFfiInit();
