// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/integration_tests.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(GetDiagnosticsTest);
  });
}

@reflectiveTest
class GetDiagnosticsTest extends AbstractAnalysisServerIntegrationTest {
  Future<void> test_getDiagnostics() async {
    standardAnalysisSetup();

    var result = await sendDiagnosticGetDiagnostics();

    // Do some lightweight validation of the returned data.
    expect(result.contexts, hasLength(1));
    var context = result.contexts.first;
    expect(context.name, isNotEmpty);
  }
}
