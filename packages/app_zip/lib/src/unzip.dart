import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:tekartik_io_utils/file_utils.dart';

Future unzip(String zipFilePath, {String? dst}) async {
  dst ??= join(dirname(zipFilePath), basenameWithoutExtension(zipFilePath));
  // Read the Zip file from disk.
  List<int> bytes = await File(zipFilePath).readAsBytes();

  // Decode the Zip file
  final archive = ZipDecoder().decodeBytes(bytes);

  // Extract the contents of the Zip archive to disk.
  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      var outFile = File(join(dst, filename));
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
      var outDir = Directory(join(dst, filename));
      await outDir.create(recursive: true);
    }
  }
}
