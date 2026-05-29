import 'package:process_run/stdio.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

import 'password_set.dart';

void main(List<String> arguments) async {
  stdout.writeln('value ${await secureEnvKey.getValueOrNull()}');
}
