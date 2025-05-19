import 'package:dev_build/shell.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_python/python.dart';
import 'package:tekartik_app_python/src/python.dart';

final venvPath = join('.local', 'venv');
Future<void> main() async {
  await pythonEnvInit();
  //await Directory(dirname(path)).create(recursive: true);
  await run('python3 -m venv ${shellArgument(venvPath)}');
}
