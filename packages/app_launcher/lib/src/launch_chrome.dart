import 'package:process_run/shell.dart';

/// Launch chrome
///
/// Linux only for now
Future<bool> launchChrome(Uri uri, {bool verbose = false}) async {
  Future _run(String command) async {
    await run(command, commandVerbose: verbose);
  }

  var url = shellArgument(uri.toString());
  if (await which('google-chrome') != null) {
    await _run('google-chrome $url');
    return true;
  }
  return false;
}
