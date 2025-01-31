// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'package:analysis_server/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'abstract_search_domain.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TopLevelDeclarationsTest);
  });
}

@reflectiveTest
class TopLevelDeclarationsTest extends AbstractSearchDomainTest {
  void assertHasDeclaration(ElementKind kind, String name) {
    result = findTopLevelResult(kind, name);
    if (result == null) {
      fail('Not found: kind=$kind name="$name"\nin\n' + results.join('\n'));
    }
  }

  void assertNoDeclaration(ElementKind kind, String name) {
    result = findTopLevelResult(kind, name);
    if (result != null) {
      fail('Unexpected: kind=$kind name="$name"\nin\n' + results.join('\n'));
    }
  }

  Future findTopLevelDeclarations(String pattern) async {
    await waitForTasksFinished();
    var request = SearchFindTopLevelDeclarationsParams(pattern).toRequest('0');
    var response = await waitResponse(request);
    if (response.error != null) {
      return response.error;
    }
    searchId = SearchFindTopLevelDeclarationsResult.fromResponse(response).id;
    return waitForSearchResults();
  }

  SearchResult findTopLevelResult(ElementKind kind, String name) {
    for (var result in results) {
      var element = result.path[0];
      if (element.kind == kind && element.name == name) {
        return result;
      }
    }
    return null;
  }

  Future<void> test_extensionDeclaration() async {
    addTestFile('''
extension MyExtension on int {}
''');
    await findTopLevelDeclarations('My*');
    assertHasDeclaration(ElementKind.EXTENSION, 'MyExtension');
  }

  Future<void> test_invalidRegex() async {
    var result = await findTopLevelDeclarations('[A');
    expect(result, const TypeMatcher<RequestError>());
  }

  Future<void> test_startEndPattern() async {
    addTestFile('''
class A {} // A
class B = Object with A;
typedef C();
typedef D();
E() {}
var F = null;
class ABC {}
''');
    await findTopLevelDeclarations('^[A-F]\$');
    assertHasDeclaration(ElementKind.CLASS, 'A');
    assertHasDeclaration(ElementKind.CLASS, 'B');
    assertHasDeclaration(ElementKind.FUNCTION_TYPE_ALIAS, 'C');
    assertHasDeclaration(ElementKind.FUNCTION_TYPE_ALIAS, 'D');
    assertHasDeclaration(ElementKind.FUNCTION, 'E');
    assertHasDeclaration(ElementKind.TOP_LEVEL_VARIABLE, 'F');
    assertNoDeclaration(ElementKind.CLASS, 'ABC');
  }
}
