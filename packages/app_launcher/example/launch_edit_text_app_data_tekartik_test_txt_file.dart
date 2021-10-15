import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

Future<void> main() async {
  var appDataPath = userAppDataPath;
  if (!Directory(appDataPath).existsSync()) {
    Directory(appDataPath).createSync(recursive: true);
  }
  await launchTextEdit(join(appDataPath, 'tekartik_test.txt'));
}
