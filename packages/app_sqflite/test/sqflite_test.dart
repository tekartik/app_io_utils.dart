import 'package:tekartik_app_io_sqflite/sqflite.dart';
import 'package:test/test.dart';

void main() {
  DatabaseFactory factory;
  setUpAll(() async {});

  test('databases path', () async {
    factory = databaseFactory;
    var dummyDatabasesPath = await factory.getDatabasesPath();
    expect(dummyDatabasesPath, isNotNull);
  });

  test('init', () async {
    // ignore: deprecated_member_use_from_same_package
    factory = getDatabaseFactory(packageName: 'com.tekartik.dummy.app');
    var dummyDatabasesPath = await factory.getDatabasesPath();
    expect(dummyDatabasesPath, isNotNull);
    expect(dummyDatabasesPath, contains('dummy.app'));
    print(dummyDatabasesPath);
    // ignore: deprecated_member_use_from_same_package
    factory = getDatabaseFactory();
    expect(await factory.getDatabasesPath(), isNotNull);
    expect(await factory.getDatabasesPath(), isNot(dummyDatabasesPath));
  });

  test('get', () async {
    factory = getDatabaseFactory(packageName: 'com.tekartik.dummy.app');
    var dummyDatabasesPath = await factory.getDatabasesPath();
    expect(dummyDatabasesPath, isNotNull);
    expect(dummyDatabasesPath, contains('dummy.app'));
    print(dummyDatabasesPath);
    factory = getDatabaseFactory();
    expect(await factory.getDatabasesPath(), isNotNull);
    expect(await factory.getDatabasesPath(), isNot(dummyDatabasesPath));
  });
}
