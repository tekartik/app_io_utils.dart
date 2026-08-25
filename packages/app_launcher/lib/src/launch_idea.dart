import 'dart:io';

import 'package:process_run/shell.dart';

/// Launch IntelliJ IDEA.
///
/// [args] are passed to the IDE, typically the project or file paths to open.
///
/// Returns true if the IDE was launched...no garantuee
Future<bool> launchIdea({List<String>? args, bool verbose = false}) async {
  Future<bool> doRun(String command) async {
    try {
      await run(command, commandVerbose: verbose);
      return true;
    } catch (e) {
      if (verbose) {
        stderr.writeln('launchIdea: $command failed $e');
      }
      return false;
    }
  }

  var argsText = (args ?? <String>[])
      .map((arg) => shellArgument(arg))
      .join(' ');
  String withArgs(String command) =>
      argsText.isEmpty ? command : '$command $argsText';

  if (Platform.isMacOS) {
    if (await which('open') != null) {
      for (var app in [
        'IntelliJ IDEA.app',
        'IntelliJ IDEA Ultimate.app',
        'IntelliJ IDEA CE.app',
      ]) {
        var command = 'open -na ${shellArgument(app)}';
        if (argsText.isNotEmpty) {
          command = '$command --args $argsText';
        }
        if (await doRun(command)) {
          return true;
        }
      }
    }
  } else if (Platform.isWindows) {
    /// Toolbox adds idea.cmd/idea.bat to the path, a regular install idea64.exe
    for (var bin in ['idea', 'idea64', 'idea.cmd', 'idea.bat', 'idea64.exe']) {
      if (await which(bin) != null) {
        if (await doRun(withArgs(bin))) {
          return true;
        }
      }
    }
    return await doRun(withArgs('start "" idea64.exe'));
  }

  /// Linux (and fallback), idea is the toolbox/tarball command line launcher
  for (var bin in [
    'idea',
    'intellij-idea-ultimate',
    'intellij-idea-community',
  ]) {
    if (await which(bin) != null) {
      if (await doRun(withArgs(bin))) {
        return true;
      }
    }
  }
  return false;
}
