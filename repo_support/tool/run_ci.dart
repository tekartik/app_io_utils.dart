import 'package:dev_test/package.dart';
import 'package:path/path.dart';

Future main() async {
  /*
  for (var dir in [
    'app_platform',
    'app_prefs',
    'app_sqflite',
    join('example', 'sqflite_test_app'),
  ]) {
    await packageRunCi(join('..', 'packages', dir));
  }*/
  await packageRunCi(join('..'), recursive: true);
}
