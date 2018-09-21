// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'dart:async';

// Flutter driver for loading all the widgets.
// TODO: Test loading in the latency tests of each widget
// instead of here.

void main() {
  group('Successfully loads the', () {
    FlutterDriver driver;

    // Each test name matches against a tile in the top level of `gallery.dart`.
    // This is necessary because we can't import gallery.dart here.
    const taggedText = 'Tagged Text';

    /// Factory for test methods against widget loading times.
    ///
    /// Assumes as a precondition the app is at the entry point.
    Future<void> Function() buildWidgetLoadingTest(String widgetName) {
      return () async {
        var tile = find.text(widgetName);
        await driver.waitFor(tile, timeout: const Duration(seconds: 5));
        await driver.scrollIntoView(tile);
        await driver.tap(tile);
        var back = find.byTooltip('Back');
        // Check that no errors display when this page loads.
        await driver.waitForAbsent(find.byType('ErrorWidget'),
            timeout: const Duration(seconds: 5));
        await driver.tap(back);
      };
    }

    setUpAll(() async {
      // Connects to the app.
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      // Closes the connection
      await driver?.close();
    });

    // In a driver test group, all tests run one after the other in a single
    // run of the app.  Make sure to return the app to the entry point after
    // each test.
    test(taggedText, buildWidgetLoadingTest(taggedText));
  });
}
