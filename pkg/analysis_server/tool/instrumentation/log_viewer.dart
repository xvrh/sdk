// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'dart:io' as io;

import 'package:args/args.dart';

import 'log/log.dart';
import 'server.dart';

/// Start a web server that will allow an instrumentation log to be viewed.
void main(List<String> args) {
  var driver = Driver();
  driver.start(args);
}

/// The main driver that configures and starts the web server.
class Driver {
  /// The flag used to specify that the user wants to have help text printed but
  /// that no other work should be done.
  static String helpFlag = 'help';

  /// The option used to specify the port on which the server should listen for
  /// requests.
  static String portOption = 'port';

  /// The port that will be used if no port number is provided on the command
  /// line.
  static int defaultPortNumber = 11000;

  /// Initialize a newly created driver.
  Driver();

  /// Create and return the parser used to parse the command-line arguments.
  ArgParser createParser() {
    var parser = ArgParser();
    parser.addFlag(helpFlag, help: 'Print this help text', negatable: false);
    parser.addOption(portOption,
        help: 'The port number on which the server should listen for requests',
        defaultsTo: defaultPortNumber.toString());
    return parser;
  }

  /// Print usage information.
  void printUsage(ArgParser parser,
      {String error, Object exception, StackTrace stackTrace}) {
    if (error != null) {
      print(error);
      print('');
    }
    print('log_viewer [options] logFile');
    print('');
    print('Usage:');
    print('');
    print(
        'The "logFile" is the file containing the content of the log that is being viewed');
    print('');
    print('Options:');
    print(parser.usage);
    if (exception != null) {
      print(exception);
    }
    if (stackTrace != null) {
      print(stackTrace);
    }
  }

  /// Use the given command-line [args] to configure and start the web server.
  void start(List<String> args) {
    var parser = createParser();
    var options = parser.parse(args);
    if (options[helpFlag]) {
      printUsage(parser);
      return;
    }

    var port = defaultPortNumber;
    try {
      port = int.parse(options[portOption]);
    } catch (exception) {
      printUsage(parser, error: 'Invalid port number');
      return;
    }

    var arguments = options.rest;
    if (arguments == null || arguments.length != 1) {
      printUsage(parser, error: 'Missing log file');
      return;
    }
    var fileName = arguments[0];
    var logFile = io.File(fileName);
    List<String> lines;
    try {
      lines = logFile.readAsLinesSync();
    } catch (exception, stackTrace) {
      printUsage(parser,
          error: 'Could not read file "$fileName":',
          exception: exception,
          stackTrace: stackTrace);
      return;
    }
    print('Log file contains ${lines.length} lines');

    var log = InstrumentationLog(<String>[logFile.path], lines);
    var server = WebServer(log);
    server.serveHttp(port);
    print('logViewer is listening on http://localhost:$port/log');
  }
}
