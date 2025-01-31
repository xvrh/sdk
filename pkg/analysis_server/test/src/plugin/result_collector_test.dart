// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'package:analysis_server/src/plugin/result_collector.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ResultCollectorTest);
  });
}

@reflectiveTest
class ResultCollectorTest {
  static const String serverId = 'server';

  ResultCollector<String> collector = ResultCollector<String>(serverId);

  void test_clearResultsForFile() {
    var filePath1 = 'test1.dart';
    var filePath2 = 'test2.dart';
    var value1 = 'r1';
    var value2 = 'r2';
    collector.startCollectingFor(filePath1);
    collector.startCollectingFor(filePath2);
    collector.putResults(filePath1, 'p', value1);
    collector.putResults(filePath2, 'p', value2);
    expect(collector.getResults(filePath1), contains(value1));
    expect(collector.getResults(filePath2), contains(value2));

    collector.clearResultsForFile(filePath2);
    expect(collector.getResults(filePath1), contains(value1));
    expect(collector.getResults(filePath2), isEmpty);
  }

  void test_clearResultsFromPlugin() {
    var filePath = 'test.dart';
    var p1Name = 'p1';
    var p2Name = 'p2';
    var p1Value = 'r1';
    var p2Value = 'r2';

    collector.startCollectingFor(filePath);
    collector.putResults(filePath, p1Name, p1Value);
    collector.putResults(filePath, p2Name, p2Value);
    expect(collector.getResults(filePath), contains(p1Value));
    expect(collector.getResults(filePath), contains(p2Value));

    collector.clearResultsFromPlugin(p1Name);
    expect(collector.getResults(filePath), isNot(contains(p1Value)));
    expect(collector.getResults(filePath), contains(p2Value));
  }

  void test_getResults_emptyCollector() {
    expect(collector.getResults('test.dart'), isEmpty);
  }

  void test_getResults_serverFirst() {
    // This is a flaky test in that it is possible for the test to pass even
    // when the code is broken.
    var filePath = 'test.dart';
    var value1 = 'r1';
    var value2 = 'r2';
    collector.startCollectingFor(filePath);
    collector.putResults(filePath, 'p', value1);
    collector.putResults(filePath, serverId, value2);
    expect(collector.getResults(filePath), <String>[value2, value1]);
  }

  void test_putResults_collecting() {
    var filePath1 = 'test1.dart';
    var filePath2 = 'test2.dart';
    var value1 = 'r1';
    var value2 = 'r2';
    expect(collector.getResults(filePath1), isEmpty);
    expect(collector.getResults(filePath2), isEmpty);

    collector.startCollectingFor(filePath1);
    collector.startCollectingFor(filePath2);
    collector.putResults(filePath1, 'p', value1);
    collector.putResults(filePath2, 'p', value2);
    expect(collector.getResults(filePath1), contains(value1));
    expect(collector.getResults(filePath1), isNot(contains(value2)));
    expect(collector.getResults(filePath2), contains(value2));
    expect(collector.getResults(filePath2), isNot(contains(value1)));
  }

  void test_putResults_notCollecting() {
    var filePath = 'test.dart';
    expect(collector.getResults(filePath), isEmpty);

    collector.putResults(filePath, 'p', 'r');
    expect(collector.getResults(filePath), isEmpty);
  }

  void test_stopCollectingFor() {
    var filePath = 'test.dart';
    var value = 'r';
    collector.startCollectingFor(filePath);
    collector.putResults(filePath, 'p', value);
    expect(collector.getResults(filePath), contains(value));

    collector.stopCollectingFor(filePath);
    expect(collector.getResults(filePath), isEmpty);
    collector.putResults(filePath, 'p', value);
    expect(collector.getResults(filePath), isEmpty);
  }
}
