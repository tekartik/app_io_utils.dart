import 'package:process_run/stdio.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

import 'password_set.dart';

void main(List<String> arguments) async {
  var value = await secureEnvKey.getValueOrNull();
  // Never print the value itself
  stdout.writeln(value == null ? 'not set' : 'set (${value.length} chars)');
}
