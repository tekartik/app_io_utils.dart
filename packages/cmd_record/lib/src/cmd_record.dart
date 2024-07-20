#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_cmd_record/src/utils.dart';

Version version = Version(0, 1, 0);

String get currentScriptName => basenameWithoutExtension(Platform.script.path);

/*
Testing

bin/cmd_record.dart example/echo.dart --stdout out
bin/cmd_record.dart -i cat

Global options:
-h, --help          Usage help
-o, --stdout        stdout content as string
-p, --stdout-hex    stdout as hexa string
-e, --stderr        stderr content as string
-f, --stderr-hex    stderr as hexa string
-i, --stdin         Handle first line of stdin
-x, --exit-code     Exit code to return
    --version       Print the command version
*/

const String flagRunInShell = 'run-in-shell';
const String flagStdin = 'stdin';

const String inPrefix = r'$';
const String outPrefix = r'>';
const String errPrefix = r'E';

class History {
  final List<HistoryItem> inItems = [];
  final List<HistoryItem> outItems = [];
  final List<HistoryItem> errItems = [];
  String? executable;
  List<String>? arguments;
  late DateTime date;

  late ProcessResult result;

  Duration? duration;

  Map<String, dynamic> toJson() {
    final record = <String, dynamic>{};
    record['date'] = date.toIso8601String();
    record['duration'] = duration.toString();
    record['executable'] = executable;
    record['arguments'] = arguments;

    if (inItems.isNotEmpty) {
      record['in'] = inItems;
    }

    if (outItems.isNotEmpty) {
      record['out'] = outItems;
    }
    if (errItems.isNotEmpty) {
      record['err'] = errItems;
    }
    record['exitCode'] = result.exitCode;
    return record;
  }
}

class HistoryItem {
  int? time;
  String? line;

  List<dynamic> toJson() => [time, line];

  String getOutput(String prefix) {
    return '${durationToString(Duration(microseconds: time!))} $prefix $line';
  }
}

class HistorySink implements StreamSink<List<int>> {
  final StreamSink? ioSink;

  Stream<HistoryItem> get stream => itemController.stream;

  StreamController<List<int>> lineController = StreamController(sync: true);
  StreamController<HistoryItem> itemController = StreamController(sync: true);

  final Stopwatch stopwatch;

  /// The results corresponding to events that have been added to the sink.
  // final results = <HistoryItem>[];

  /// Whether [close] has been called.
  bool get isClosed => _isClosed;
  var _isClosed = false;

  @override
  Future get done => _doneCompleter.future;
  final _doneCompleter = Completer<dynamic>();

  /// Creates a new sink.
  ///
  /// If [onDone] is passed, it's called when the user calls [close]. Its result
  /// is piped to the [done] future.
  HistorySink(this.ioSink, this.stopwatch) {
    lineController.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((String line) {
      itemController.add(HistoryItem()
        ..time = stopwatch.elapsedMicroseconds
        ..line = line);
    });
  }

  @override
  void add(List<int> data) {
    lineController.add(data);
    ioSink?.add(data);
  }

  @override
  void addError(error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) {
    var completer = Completer<void>.sync();
    stream.listen(add, onError: addError, onDone: completer.complete);
    return completer.future;
  }

  @override
  Future close() async {
    /*
    // eventually close lose command
    add('\n'.codeUnits);
    if (results.last.line.isEmpty) {
      results.removeLast();
    }
    */
    _isClosed = true;
    await lineController.close();
    await itemController.close();
  }
}

///
/// write rest arguments as lines
/// if history is not null
///
Future record(String executable, List<String> arguments,
    {bool? runInShell,
    bool? recordStdin,

    /// prevent streaming to stderr and stdout in real time
    bool? noStdOutput,
    StringSink? dumpSink,
    History? history,
    Stream<List<int>>? inStream,
    bool? noStderr}) async {
  noStdOutput ??= false;
  noStderr ??= false;

  final stdinStream = inStream ?? stdin;
  // by default record if there is an incoming stream
  recordStdin ??= inStream != null;

  // Run the command
  final cmd = ProcessCmd(executable, arguments, runInShell: runInShell);

  final stopwatch = Stopwatch();

  final outSink = HistorySink(noStdOutput ? null : stdout, stopwatch);
  outSink.stream.listen((HistoryItem item) {
    // Output
    dumpSink?.writeln(item.getOutput(outPrefix));
    history?.outItems.add(item);
  });
  HistorySink? errSink;
  if (!noStderr) {
    errSink = HistorySink(noStdOutput ? null : stderr, stopwatch);
    errSink.stream.listen((HistoryItem item) {
      // Output
      dumpSink?.writeln(item.getOutput(errPrefix));
      history?.errItems.add(item);
    });
  }

  final stdinController = StreamController<List<int>>(sync: true);
  final stdinRecordController = StreamController<List<int>>(sync: true);

  if (recordStdin) {
    stdinStream.listen((List<int> data) {
      stdinController.add(data);
      stdinRecordController.add(data);
    })
      ..onError((Object e, StackTrace st) {
        stdinController.addError(e, st);
        stdinRecordController.addError(e, st);
      })
      ..onDone(() {
        stdinController.close();
        stdinRecordController.close();
      });

    stdinRecordController.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((String line) {
      var item = HistoryItem()
        ..time = stopwatch.elapsedMicroseconds
        ..line = line;
      // Output
      dumpSink?.writeln(item.getOutput(inPrefix));
      history?.inItems.add(item);
    });
  }

  history?.date = DateTime.now();
  history?.executable = executable;
  history?.arguments = arguments;

  stopwatch.start();
  final result = await runCmd(cmd,
      stdout: outSink,
      stderr: errSink,
      stdin: recordStdin ? stdinController.stream : null);

  await outSink.close();
  await errSink?.close();
  history?.result = result;
  history?.duration = stopwatch.elapsed;
}

class _Parser {
  int? index = 0;
  final List<HistoryItem> list;
  final String prefix;

  _Parser(this.prefix, this.list);

  HistoryItem? get current {
    if (index == null) {
      return null;
    } else if (index! >= (list.length)) {
      index = null;
      return null;
    }
    return list[index!];
  }

  void next() {
    index = index! + 1;
  }
}

void dump(History history) {
  final inParser = _Parser(r'$', history.inItems);
  var parsers = [inParser];
  stdout.writeln('date ${history.date}\nduration ${history.duration}');
  stdout.writeln(
      '\$ ${executableArgumentsToString(history.executable!, history.arguments)}\n');

  var done = false;
  while (!done) {
    _Parser? minParser;
    int? minTime;
    for (final parser in parsers) {
      final item = parser.current;
      if (item != null) {
        if ((minTime == null) || (item.time! < minTime)) {
          minParser = parser;
          minTime = item.time;
        }
      }
    }

    if (minParser != null) {
      print(minParser.current!.getOutput(inParser.prefix));

      /*
    }
      for (_Parser parser in parsers) {
        if (identical(parser, minParser)) {
      }
      */
      minParser.next();
    } else {
      done = true;
    }
  }
}
