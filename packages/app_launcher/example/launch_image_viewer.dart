import 'package:dev_build/build_support.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

String? _imagePath;
Future<String> getTestImagePath() async {
  return _imagePath ??= await () async {
    var path = '.';
    var configMap = await pathGetPackageConfigMap(path);
    var pkgPath = pathPackageConfigMapGetPackagePath(
      path,
      configMap,
      'tekaly_assets',
    )!;
    var imgPath = join(pkgPath, 'lib', 'img', 'tekartik_logo_256.png');
    return imgPath;
  }();
}

Future<void> main() async {
  var imgPath = await getTestImagePath();
  await launchImageViewer(imgPath);
}
