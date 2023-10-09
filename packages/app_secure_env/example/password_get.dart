import 'package:tekartik_app_secure_env/secure_env.dart';

import 'password_set.dart';

void main(List<String> arguments) async {
  print('value ${await secureEnvKey.getValue()}');
}
