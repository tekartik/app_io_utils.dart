import 'launch_default_viewer.dart';

/// Launch the default browser on [uri] (the default viewer of the url).
///
/// Falls back to chrome. Returns false when nothing could be launched.
Future<bool> launchBrowser(Uri uri, {bool verbose = false}) =>
    launchDefaultViewer(uri, verbose: verbose);
