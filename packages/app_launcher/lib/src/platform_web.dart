Future<bool> launchTextEdit(String path, {bool verbose = false}) =>
    _stub('launchTextEdit');
Future<bool> launchChrome(Uri uri, {bool verbose = false}) =>
    _stub('launchChrome');
Future<bool> launchBrowser(Uri uri, {bool verbose = false}) =>
    _stub('launchBrowser');
Future<bool> launchFileExplorer(String path, {bool verbose = false}) =>
    _stub('launchFileExplorer');

/// Always throw.
T _stub<T>(String message) {
  throw UnimplementedError(message);
}
