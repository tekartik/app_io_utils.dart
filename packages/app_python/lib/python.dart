/// Python helpers for Dart scripts: route `python3`/`pip3` of the process_run
/// shells to a virtualenv ([pythonEnvInit]) and pip install a missing package
/// ([pythonCheckOrInstallPackage]).
library;

export 'src/python.dart' show pythonEnvInit, pythonCheckOrInstallPackage;
