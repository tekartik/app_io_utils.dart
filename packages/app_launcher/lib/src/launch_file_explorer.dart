import 'dart:io';

import 'package:process_run/shell.dart';

import 'launch_utils.dart';

/// File explorer (file manager) commands tried on linux, in order.
///
/// `xdg-open` opens the file manager the user configured, the others are the
/// common desktop environment ones.
const _linuxCommands = <String>[
  'xdg-open',
  'nautilus',
  'dolphin',
  'thunar',
  'nemo',
  'caja',
  'pcmanfm',
  'pcmanfm-qt',
];

/// Launch the file explorer (file manager) on [path], a folder or a file.
///
/// Returns false when no file explorer could be launched.
Future<bool> launchFileExplorer(String path, {bool verbose = false}) async {
  if (Platform.isMacOS) {
    var executable = await which('open') ?? 'open';
    return await startDetached(executable, [path], verbose: verbose);
  }
  if (Platform.isWindows) {
    var executable = await which('explorer') ?? 'explorer';
    // explorer exits with 1 even when it succeeds, detached we don't care.
    return await startDetached(executable, [path], verbose: verbose);
  }
  for (var command in _linuxCommands) {
    var executable = await which(command);
    if (executable == null) {
      continue;
    }
    if (await startDetached(executable, [path], verbose: verbose)) {
      return true;
    }
  }
  return false;
}
