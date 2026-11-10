// ignore_for_file: avoid_print

import 'package:tekartik_app_io_platform/app_platform.dart';
import 'package:tekartik_app_io_platform/platform.dart' as p;

/// Prints the platform the program runs on (`dart run example/main.dart`).
void main() {
  // {io: {platform: linux}}
  print(platformContext.toMap());
  print(p.isWindows ? 'windows' : (p.isMacOS ? 'macos' : 'linux or other'));
  var env = platformContext.io!.environment;
  print(env['HOME'] ?? env['USERPROFILE']);
}
