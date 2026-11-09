/// Open desktop applications from a Dart program: the default browser,
/// Chrome, Firefox, a text editor, the file manager, a terminal or IntelliJ
/// IDEA (Linux, macOS, Windows).
///
/// Every launcher returns `true` when a command was started, `false` when
/// nothing suitable was found or the command failed.
library;

export 'src/platform.dart'
    show
        launchChrome,
        launchFileExplorer,
        launchTextEdit,
        launchBrowser,
        launchFirefox,
        launchImageViewer,
        launchDefaultViewerPath,
        launchDefaultViewer,
        launchTerminal,
        launchIdea,
        LaunchTerminalOptions;
