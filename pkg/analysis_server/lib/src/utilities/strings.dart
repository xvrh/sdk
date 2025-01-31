// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'dart:math';

import 'package:analyzer_plugin/src/utilities/string_utilities.dart';

/// "$"
const int CHAR_DOLLAR = 0x24;

/// "_"
const int CHAR_UNDERSCORE = 0x5F;

String capitalize(String str) {
  if (isEmpty(str)) {
    return str;
  }
  return str.substring(0, 1).toUpperCase() + str.substring(1);
}

int compareStrings(String a, String b) {
  if (a == b) {
    return 0;
  }
  if (a == null) {
    return 1;
  }
  if (b == null) {
    return -1;
  }
  return a.compareTo(b);
}

/// Return a simple difference between the given [oldStr] and [newStr].
SimpleDiff computeSimpleDiff(String oldStr, String newStr) {
  var prefixLength = findCommonPrefix(oldStr, newStr);
  var suffixLength = findCommonSuffix(oldStr, newStr);
  while (prefixLength >= 0) {
    var oldReplaceLength = oldStr.length - prefixLength - suffixLength;
    var newReplaceLength = newStr.length - prefixLength - suffixLength;
    if (oldReplaceLength >= 0 && newReplaceLength >= 0) {
      return SimpleDiff(prefixLength, oldReplaceLength,
          newStr.substring(prefixLength, newStr.length - suffixLength));
    }
    prefixLength--;
  }
  return SimpleDiff(0, oldStr.length, newStr);
}

int countLeadingWhitespaces(String str) {
  var i = 0;
  for (; i < str.length; i++) {
    var c = str.codeUnitAt(i);
    if (!isWhitespace(c)) {
      break;
    }
  }
  return i;
}

/// Counts how many times [sub] appears in [str].
int countMatches(String str, String sub) {
  if (isEmpty(str) || isEmpty(sub)) {
    return 0;
  }
  var count = 0;
  var idx = 0;
  while ((idx = str.indexOf(sub, idx)) != -1) {
    count++;
    idx += sub.length;
  }
  return count;
}

int countTrailingWhitespaces(String str) {
  var i = 0;
  for (; i < str.length; i++) {
    var c = str.codeUnitAt(str.length - 1 - i);
    if (!isWhitespace(c)) {
      break;
    }
  }
  return i;
}

/// Returns the number of characters common to the start of [a] and [b].
int findCommonPrefix(String a, String b) {
  var n = min(a.length, b.length);
  for (var i = 0; i < n; i++) {
    if (a.codeUnitAt(i) != b.codeUnitAt(i)) {
      return i;
    }
  }
  return n;
}

/// Returns the number of characters common to the end of [a] and [b].
int findCommonSuffix(String a, String b) {
  var a_length = a.length;
  var b_length = b.length;
  var n = min(a_length, b_length);
  for (var i = 1; i <= n; i++) {
    if (a.codeUnitAt(a_length - i) != b.codeUnitAt(b_length - i)) {
      return i - 1;
    }
  }
  return n;
}

/// Checks if [str] is `null`, empty or is whitespace.
bool isBlank(String str) {
  if (str == null) {
    return true;
  }
  if (str.isEmpty) {
    return true;
  }
  return str.codeUnits.every(isSpace);
}

bool isDigit(int c) {
  return c >= 0x30 && c <= 0x39;
}

bool isEOL(int c) {
  return c == 0x0D || c == 0x0A;
}

bool isLetter(int c) {
  return (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
}

bool isLetterOrDigit(int c) {
  return isLetter(c) || isDigit(c);
}

bool isSpace(int c) => c == 0x20 || c == 0x09;

bool isWhitespace(int c) {
  return isSpace(c) || isEOL(c);
}

String removeEnd(String str, String remove) {
  if (isEmpty(str) || isEmpty(remove)) {
    return str;
  }
  if (str.endsWith(remove)) {
    return str.substring(0, str.length - remove.length);
  }
  return str;
}

String repeat(String s, int n) {
  var sb = StringBuffer();
  for (var i = 0; i < n; i++) {
    sb.write(s);
  }
  return sb.toString();
}

/// If the [text] length is above the [limit], replace the middle with `...`.
String shorten(String text, int limit) {
  if (text.length > limit) {
    var headLength = limit ~/ 2 - 1;
    var tailLength = limit - headLength - 3;
    return text.substring(0, headLength) +
        '...' +
        text.substring(text.length - tailLength);
  }
  return text;
}

/// Information about a single replacement that should be made to convert the
/// "old" string to the "new" one.
class SimpleDiff {
  final int offset;
  final int length;
  final String replacement;

  SimpleDiff(this.offset, this.length, this.replacement);
}
