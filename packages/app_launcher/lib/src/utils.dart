/// Convert a path to a URI.
Uri pathToUriDefaultToFile(String path) {
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
