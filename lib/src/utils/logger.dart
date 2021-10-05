import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

// import 'package:cli_util/cli_logging.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:io/ansi.dart' as ansi;
// ignore_for_file: avoid

// TODO - for some reason when we try to colorize the strings using ansi color libraries like tint and others here
// it will only result in orange color . WHYYYYYYYYYYYYYYYY?

/// Sets default logger mode
Logger logger = Logger.standard();
final _ansiPen = AnsiPen();

/// Logger for fantom
class Log {
  /// Prints sucess message
  static void fine(String message) {
    print(ansi.green.wrap(message));
    consoleController.stdout.add(utf8.encode(message));
  }

  /// Prints [message] with warning formatting
  static void warning(String message) {
    print(ansi.yellow.wrap(message));
    consoleController.stderr.add(utf8.encode(message));
  }

  /// Prints [message] with info formatting
  static void info(String message) {
    print('\x1b[38;5;39m$message\x1b[0m');
    consoleController.stdout.add(utf8.encode(message));
  }

  static void debug(String message) {
    _ansiPen
      ..rgb(r: 0, g: 1, b: 1, bg: true)
      ..black();
    print(_ansiPen(message));
    consoleController.stdout.add(utf8.encode(message));
  }

  /// Prints [message] with error formatting
  static void error(String message) {
    print(ansi.red.wrap(message));
    consoleController.stderr.add(utf8.encode(message));
  }

  /// Prints a line space
  static void spacer() {
    print('');
    consoleController.stdout.add(utf8.encode(''));
  }

  /// shows a progress in
  static Progress progress(String message) {
    var stylized = ansi.styleItalic.wrap(message)!;
    stylized = ansi.yellow.wrap(stylized)!;
    return logger.progress(stylized);
  }

  /// Prints a divider
  static void divider() {
    const line = '___________________________________________________\n';

    print(line);
    consoleController.stdout.add(utf8.encode(line));
  }
}

/// Console controller instance
final consoleController = ConsoleController();

/// Console Controller
class ConsoleController {
  /// stdout stream
  final stdout = StreamController<List<int>>.broadcast();

  /// sderr stream
  final stderr = StreamController<List<int>>.broadcast();

  /// Is running on CLI
  static bool isCli = true;

  /// Checks if its running on terminal
  static bool get isTerminal => isCli && io.stdin.hasTerminal;

  /// stdout stream sink
  StreamSink<List<int>> get stdoutSink {
    return isCli ? io.stdout.nonBlocking : stdout.sink;
  }

  /// stderr stream sink
  StreamSink<List<int>> get stderrSink {
    return isCli ? io.stderr.nonBlocking : stderr.sink;
  }
}
