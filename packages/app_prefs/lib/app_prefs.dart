/// Persistent preferences for io programs: [getPrefsFactory] and
/// [prefsFactory] (sembast files in the user data folder), plus the whole
/// `package:tekartik_prefs/prefs.dart` API. Io only, it does not compile for
/// the web.
library;

import 'package:tekartik_prefs/prefs.dart';

import 'src/prefs.dart' as src;

export 'package:tekartik_prefs/prefs.dart';

/// The default prefs factory, stored under
/// `<userAppDataPath>/com.tekartik.app_prefs/prefs/`, the same instance at
/// every read (and the same as `getPrefsFactory()`).
PrefsFactory get prefsFactory => src.prefsFactory;

/// The prefs factory of [packageName], stored under
/// `<userAppDataPath>/<packageName>/prefs/` on Linux and Windows, cached per
/// package name.
///
/// On the other io platforms (macOS...) [packageName] is ignored and
/// [prefsFactory] is returned.
PrefsFactory getPrefsFactory({String? packageName}) =>
    src.getPrefsFactory(packageName: packageName);
