// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'dart:async';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/integration_tests.dart';

void main() {
  // Skip on Windows.
  if (Platform.isWindows) {
    return;
  }

  defineReflectiveSuite(() {
    defineReflectiveTests(BazelChangesTest);
  });
}

@reflectiveTest
class BazelChangesTest extends AbstractAnalysisServerIntegrationTest {
  var processedNotification = Completer<void>();

  /// Path to the `command.log` file.
  ///
  /// Writing to it should trigger our change detection to run.
  String commandLogPath;

  String bazelRoot;
  String tmpPath;
  String workspacePath;
  String bazelOutPath;
  String bazelBinPath;
  String bazelGenfilesPath;
  Directory oldSourceDirectory;

  String inTmpDir(String relative) =>
      path.join(tmpPath, relative.replaceAll('/', path.separator));

  String inWorkspace(String relative) =>
      path.join(workspacePath, relative.replaceAll('/', path.separator));

  @override
  Future setUp() async {
    await super.setUp();
    oldSourceDirectory = sourceDirectory;

    tmpPath = Directory(Directory.systemTemp
            .createTempSync('analysisServer')
            .resolveSymbolicLinksSync())
        .path;
    workspacePath = inTmpDir('workspace_root');
    writeFile(inWorkspace('WORKSPACE'), '');

    sourceDirectory = Directory(inWorkspace('third_party/dart/project'));
    sourceDirectory.createSync(recursive: true);

    bazelRoot = inTmpDir('bazel_root');
    Directory(bazelRoot).createSync(recursive: true);

    bazelOutPath = '$bazelRoot/execroot/bazel_workspace/bazel-out';
    bazelBinPath = '$bazelRoot/execroot/bazel_workspace/bazel-out/bin';
    bazelGenfilesPath =
        '$bazelRoot/execroot/bazel_workspace/bazel-out/genfiles';

    Directory(inTmpDir(bazelOutPath)).createSync(recursive: true);
    Directory(inTmpDir(bazelBinPath)).createSync(recursive: true);
    Directory(inTmpDir(bazelGenfilesPath)).createSync(recursive: true);

    Link(inWorkspace('bazel-out')).createSync(bazelOutPath);
    Link(inWorkspace('bazel-bin')).createSync(bazelBinPath);
    Link(inWorkspace('bazel-genfiles')).createSync(bazelGenfilesPath);

    commandLogPath = inTmpDir('$bazelRoot/command.log');
  }

  @override
  Future tearDown() async {
    Directory(tmpPath).deleteSync(recursive: true);
    sourceDirectory = oldSourceDirectory;
    await super.tearDown();
  }

  // Add a bit more time -- the isolate take a while to start when the test is
  // not run from a snapshot.
  @TestTimeout(Timeout.factor(2))
  Future<void> test_bazelChanges() async {
    var testFile = inWorkspace('${sourceDirectory.path}/lib/test.dart');

    var errors = <AnalysisError>[];
    onAnalysisErrors.listen((event) {
      if (event.file == testFile) {
        errors.addAll(event.errors);
        processedNotification.complete();
      }
    });
    var resetCompleterAndErrors = () async {
      // This is necessary because our polling uses modification timestamps
      // whose resolution seems to be too small for a test like this (i.e., we
      // write to the `command.log` file, but if the modification timestamp
      // doesn't change, we won't detect the change).
      await Future.delayed(Duration(seconds: 1));
      errors.clear();
      processedNotification = Completer();
    };

    writeFile(testFile, r'''
import 'generated.dart';
void main() { my_fun(); }
''');
    standardAnalysisSetup();

    await processedNotification.future;
    expect(errors, isNotEmpty);
    expect(errors[0].message, contains('generated.dart'));

    // This seems to be necessary (at least when running the test from source),
    // because it takes a while for the watcher isolate to start.
    await Future.delayed(Duration(seconds: 10));

    await resetCompleterAndErrors();
    var generatedFilePath = inWorkspace(
        '$bazelGenfilesPath/third_party/dart/project/lib/generated.dart');
    writeFile(generatedFilePath, 'my_fun() {}');
    writeFile(commandLogPath, 'Build completed successfully');

    await processedNotification.future;
    expect(errors, isEmpty);

    // Now let's write a file that does not define `my_fun` -- we should get an
    // error again.
    await resetCompleterAndErrors();
    writeFile(generatedFilePath, 'different_fun() {}');
    writeFile(commandLogPath, 'Build completed');

    await processedNotification.future;
    expect(errors, isNotEmpty);

    // Now delete the file completely.
    await resetCompleterAndErrors();
    File(generatedFilePath).deleteSync();
    writeFile(commandLogPath, 'Build did NOT complete successfully');

    await processedNotification.future;
    expect(errors, isNotEmpty);

    // And finally re-add the correct file -- errors should go away once again.
    await resetCompleterAndErrors();
    writeFile(generatedFilePath, 'my_fun() {}');
    writeFile(commandLogPath, 'Build completed successfully');

    await processedNotification.future;
    expect(errors, isEmpty);
  }
}
