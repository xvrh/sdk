// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'bazel_changes_test.dart' as bazel_changes_test;
import 'get_version_test.dart' as get_version_test;
import 'set_subscriptions_invalid_service_test.dart'
    as set_subscriptions_invalid_service_test;
import 'set_subscriptions_test.dart' as set_subscriptions_test;
import 'shutdown_test.dart' as shutdown_test;
import 'status_test.dart' as status_test;

void main() {
  defineReflectiveSuite(() {
    bazel_changes_test.main();
    get_version_test.main();
    set_subscriptions_test.main();
    set_subscriptions_invalid_service_test.main();
    shutdown_test.main();
    status_test.main();
  }, name: 'server');
}
