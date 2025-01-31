// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'package:analysis_server/protocol/protocol_generated.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/integration_tests.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ListPostfixCompletionTemplatesTest);
  });
}

@reflectiveTest
class ListPostfixCompletionTemplatesTest
    extends AbstractAnalysisServerIntegrationTest {
  Future<void> test_list_postfix_completion_templates() async {
    var pathname = sourcePath('test.dart');
    var text = r'''
void bar() {
  foo();.tryon
}
void foo() { }
''';
    text = text.replaceAll('.tryon', '');
    writeFile(pathname, text);
    standardAnalysisSetup();

    await analysisFinished;

    // expect a postfix template list result
    var result = await sendEditListPostfixCompletionTemplates();
    expect(result.templates, isNotNull);
    expect(result.templates.length, greaterThan(15));
    expect(result.templates[0].runtimeType, PostfixTemplateDescriptor);
  }
}
