// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

/// Result of value validation.
class OperationResult {
  bool get isSuccess => error == null;
  final String error;

  const OperationResult.success() : error = null;

  const OperationResult.error(this.error);
}
