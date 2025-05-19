import 'package:dev_build/shell.dart';
import 'package:path/path.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

var _pythonEnvInitiliazed = false;

/// Allow trying a given path (venv)
Future<void> pythonEnvInit({List<String>? paths}) async {
  if (!_pythonEnvInitiliazed) {
    _pythonEnvInitiliazed = true;

    if (paths != null) {
      for (var path in paths) {
        if (Directory(path).existsSync()) {
          var pythonPath = join(path, 'bin', 'python3');
          var pipPath = join(path, 'bin', 'pip3');
          shellEnvironment =
              ShellEnvironment()
                ..aliases['python3'] = pythonPath
                ..aliases['python'] = pythonPath;
          shellEnvironment =
              ShellEnvironment()
                ..aliases['pip3'] = pipPath
                ..aliases['pip'] = pipPath;
          return;
        }
      }
    }
  }
}

Version? _tryParseVersion(String part) {
  try {
    return parseVersion(part);
  } catch (e) {
    // ignore
  }
  return null;
}

/// A class to hold Python executable information
class PyExectuableInfo {
  /// The executable path
  final String executable;

  /// The version of the executable
  final Version version;

  /// Constructor for PyExectuableInfo
  PyExectuableInfo({required this.executable, required this.version});

  @override
  String toString() {
    return '$executable ($version)';
  }
}

Map<String, PyExectuableInfo>? _installedPackages;

Future<Map<String, PyExectuableInfo>> _checkInstalledPackages() async {
  return _installedPackages ??= await () async {
    var map = <String, PyExectuableInfo>{};
    var lines = (await run('pip3 list', verbose: false)).outLines;
    for (var line in lines) {
      var parts = line.trim().split(' ').where((s) => s.isNotEmpty).toList();
      if (parts.length == 2) {
        var version = _tryParseVersion(parts.last);
        if (version != null) {
          map[parts.first] = PyExectuableInfo(
            executable: parts.first,
            version: version,
          );
        }
      }
    }
    return map;
  }();
}

/// Debug flag
var pythonDebug = false; // devWarning(true);

/// Check if a package is installed, and if not, install it
Future<void> pythonCheckOrInstallPackage(String package) async {
  var map = await _checkInstalledPackages();
  if (map.containsKey(package)) {
    if (pythonDebug) {
      stdout.writeln('Package $package already installed');
    }
    stdout.writeln('Package $package already installed');
  } else {
    await run('pip3 install $package');
  }
}
