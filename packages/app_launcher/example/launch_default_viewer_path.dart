import 'package:tekartik_app_io_launcher/src/launch_default_viewer.dart';

import 'launch_image_viewer.dart';

Future<void> main() async {
  var imgPath = await getTestImagePath();
  await launchDefaultViewerPath(imgPath);
}
