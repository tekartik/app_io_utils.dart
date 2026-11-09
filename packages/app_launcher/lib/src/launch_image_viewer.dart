import 'launch_default_viewer.dart';

/// Open the image file at [path] in its default viewer, same as
/// [launchDefaultViewerPath].
Future<bool> launchImageViewer(String path, {bool verbose = false}) async {
  return await launchDefaultViewerPath(path, verbose: verbose);
}
