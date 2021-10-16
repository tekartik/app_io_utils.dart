import 'package:tekartik_app_io_launcher/launcher.dart';

Future<void> main() async {
  await launchBrowser(Uri.parse('https://www.google.com'), verbose: true);
}
