import 'package:dev_build/shell.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_python/python.dart';
import 'package:tekartik_app_python/src/python.dart';

import 'create_venv.dart';

Future<void> main() async {
  await pythonEnvInit(paths: [venvPath]);
  //await Directory(dirname(path)).create(recursive: true);
  stdout.writeln('${await which('python3')}');
  await run('python3 --version');
}
