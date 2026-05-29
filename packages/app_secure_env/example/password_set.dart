import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

final secureEnvKey = SecureEnvKey(
  key: 'maSLWhDzFQg0dhIXKxeV',
  password: 'x9cQYGAw8YVnhJyNmjc6cmq29XGnZgvD',
);

void main(List<String> arguments) async {
  await secureEnvKey.setFromInput();
  stdout.writeln(await secureEnvKey.getValue());
  await sharedStdIn.terminate();
}
