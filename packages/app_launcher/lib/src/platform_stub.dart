/// Only for io
Future<bool> launchTextEdit(String path, {bool verbose = false}) =>
    _stub('launchTextEdit');

/// Only for io
Future<bool> launchChrome(Uri uri, {bool verbose = false}) =>
    _stub('launchChrome');

/// Only for io
Future<bool> launchFirefox(Uri uri, {bool verbose = false}) =>
    _stub('launchFirefox');

/// Only for io
Future<bool> launchBrowser(Uri uri, {bool verbose = false}) =>
    _stub('launchBrowser');

/// Only for io
Future<bool> launchFileExplorer(String path, {bool verbose = false}) =>
    _stub('launchFileExplorer');

/// Only for io
Future<bool> launchImageViewer(String path, {bool verbose = false}) =>
    _stub('launchImageViewer');

/// Only for io
Future<bool> launchDefaultViewer(Uri uri, {bool verbose = false}) =>
    _stub('launchImageViewer');

/// Only for io
Future<bool> launchDefaultViewerPath(String path, {bool verbose = false}) =>
    _stub('launchDefaultViewerPath');

/// Always throw.
T _stub<T>(String message) {
  throw UnimplementedError(message);
}
