import 'launch_default_viewer.dart';

/// Launch chrome
///
/// Linux only for now
Future<bool> launchImageViewer(String path, {bool verbose = false}) async {
  return await launchDefaultViewerPath(path, verbose: verbose);
}
