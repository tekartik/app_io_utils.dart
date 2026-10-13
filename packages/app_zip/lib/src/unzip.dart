import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:tekartik_io_utils/file_utils.dart';

/// Unzip a zip file to a destination folder (default to a folder named after the zip file without the .zip extension)
Future<void> unzip(String zipFilePath, {String? dst}) async {
  dst ??= join(dirname(zipFilePath), basenameWithoutExtension(zipFilePath));
  // Read the Zip file from disk.
  List<int> bytes = await File(zipFilePath).readAsBytes();

  // Decode the Zip file
  final archive = ZipDecoder().decodeBytes(bytes);

  // Check every entry before writing anything (zip slip).
  final dstPath = normalize(absolute(dst));
  final outPaths = [
    for (final file in archive) _unzipEntryPath(dstPath, file.name),
  ];

  // Extract the contents of the Zip archive to disk.
  for (final (index, file) in archive.indexed) {
    final outPath = outPaths[index];
    if (file.isFile) {
      final data = file.content as List<int>;
      var outFile = File(outPath);
      outFile.parent.createSync(recursive: true);
      await outFile.writeAsBytes(data, flush: true);

      // devPrint(file.mode?.toRadixString(16));
      // devPrint(file.unixPermissions?.toRadixString(16));
      // Support file permission
      if (supportsFilePermission &&
          ((file.unixPermissions & executablePermissionModeMask) != 0)) {
        await setExecutablePermission(outFile.path);
      }
    } else {
      var outDir = Directory(outPath);
      await outDir.create(recursive: true);
    }
  }
}

/// The path of an archive entry in [dstPath] (absolute and normalized).
///
/// Throws if the entry would be written outside [dstPath] (`../` or an
/// absolute name).
String _unzipEntryPath(String dstPath, String name) {
  var path = normalize(join(dstPath, name));
  if (path != dstPath && !isWithin(dstPath, path)) {
    throw FileSystemException(
      'unzip: entry outside the destination directory, refused',
      name,
    );
  }
  return path;
}
