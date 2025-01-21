import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

/// [dst] is a .zip file name
Future<void> zip(String directoryPath, {String? dst}) async {
  dst ??= join(
      dirname(directoryPath), '${basenameWithoutExtension(directoryPath)}.zip');

  await Directory(dirname(dst)).create(recursive: true);
  await ZipFileEncoder().zipDirectory(Directory(directoryPath), filename: dst);
}
