// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'lint_names_test.dart' as lint_names;

void main() {
  defineReflectiveSuite(() {
    lint_names.main();
  }, name: 'linter');
}
