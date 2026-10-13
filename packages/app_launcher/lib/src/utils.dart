/// A windows absolute path (`C:\dir`, `C:/dir`) or UNC path (`\\server\share`).
final _windowsAbsolutePathRegExp = RegExp(r'^([a-zA-Z]:[\\/]|\\\\)');

/// Convert a path to a URI.
///
/// A path that is not a uri with a scheme is a file path. A windows drive path
/// (`C:\Users\x\img.png`) is a file path too (the drive letter is not a
/// scheme).
Uri pathToUriDefaultToFile(String path) {
  if (_windowsAbsolutePathRegExp.hasMatch(path)) {
    return Uri.file(path, windows: true);
  }
  try {
    var uri = Uri.parse(path);
    if (uri.scheme.isEmpty) {
      return Uri.file(path);
    }
    return uri;
  } catch (_) {
    return Uri.file(path);
  }
}
