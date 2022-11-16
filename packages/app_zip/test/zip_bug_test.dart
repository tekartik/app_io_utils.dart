import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('zip_executable', () async {
    // Only tested on linux so far
    if (Platform.isLinux) {
      var path = join('.dart_tool', 'archive', 'test', 'zip_executable');
      var srcPath = join(path, 'src');

      try {
        await Directory(path).delete(recursive: true);
      } catch (_) {}
      await Directory(srcPath).create(recursive: true);

      // Create an executable file and zip it
      var file = File(join(srcPath, 'test.bin'));
      await file.writeAsString('bin', flush: true);
      await Process.run('chmod', ['+x', file.path]);
      // Check permission
      // permission executable b001001001 = 0x49
      expect((file.statSync()).mode & 0x49, 0x49);

      var dstFilePath = join(path, 'test.zip');
      ZipFileEncoder().zipDirectory(Directory(srcPath), filename: dstFilePath);

      // Read
      List<int> bytes = await File(dstFilePath).readAsBytes();

      // Decode the Zip file
      final archive = ZipDecoder().decodeBytes(bytes);

      var archiveFile = archive.first;
      // Fails unixPermissions is null
      expect(archiveFile.unixPermissions & 0x49, 0x49);
    }
  }, skip: true);
}
