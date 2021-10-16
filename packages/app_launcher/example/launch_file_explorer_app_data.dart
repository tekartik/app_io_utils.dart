import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

Future<void> main() async {
  var appDataPath = userAppDataPath;
  await launchFileExplorer(appDataPath, verbose: true);
}
