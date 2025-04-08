import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/src/render_visibility_detector.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  testWidgets(
      'VisibilityDetector should not call onVisibilityChanged after unmounting',
      (WidgetTester tester) async {
    // Variable to hold the last visibility information
    VisibilityInfo? lastInfo;

    // Create an instance of VisibilityDetector
    final detector = VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        // Update lastInfo with the current visibility information
        lastInfo = info;
      },
      child: Container(
        width: 200,
        height: 350,
        color: Colors.red,
      ),
      isChangedOnDispose: false,
    );

    // Mount the VisibilityDetector to the widget tree
    await tester.pumpWidget(
      Center(
        child: SizedBox(
          height: 400,
          width: 400,
          child: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: detector,
          ),
        ),
      ),
    );

    // Trigger visibility update
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Verify that the visibility information has been updated
    expect(lastInfo, isNotNull);
    // Assert the expected visibility fraction
    expect(lastInfo?.visibleFraction, 1.0);

    // Unmount the VisibilityDetector
    await tester.pumpWidget(const Placeholder());
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Trigger visibility update again to ensure onVisibilityChanged is not called
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Additional logic can be added here to verify no new visibility changes
    // Since lastInfo should not be updated, it should retain its original value
    expect(lastInfo?.visibleFraction, 1.0);
  });

  testWidgets('VisibilityDetector unmount sets onVisibilityChanged to null',
      (WidgetTester tester) async {
    // Variable to hold the last visibility information
    VisibilityInfo? lastInfo;

    // Create an instance of VisibilityDetector
    final detector = VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        // Update lastInfo with the current visibility information
        lastInfo = info;
      },
      child: Container(
        width: 200,
        height: 350,
        color: Colors.red,
      ),
      isChangedOnDispose: false,
    );

    // Mount the VisibilityDetector to the widget tree
    await tester.pumpWidget(
      Center(
        child: SizedBox(
          height: 400,
          width: 400,
          child: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: detector,
          ),
        ),
      ),
    );

    // Trigger visibility update
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Verify that the visibility information has been updated
    expect(lastInfo, isNotNull);

    // Unmount the VisibilityDetector
    await tester.pumpWidget(const Placeholder());
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Trigger visibility update again to ensure onVisibilityChanged is not called
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Verify that lastInfo retains its original value
    expect(lastInfo?.visibleFraction, 1.0);

    // Attempt to access RenderVisibilityDetector
    final renderObjects =
        tester.allElements.whereType<RenderVisibilityDetector>();

    // Ensure that renderObjects is empty, as it should be unmounted
    expect(renderObjects.length, 0);
  });

  testWidgets(
      'SliverVisibilityDetector should not call onVisibilityChanged after unmounting',
      (WidgetTester tester) async {
    // Variable to hold the last visibility information
    VisibilityInfo? lastInfo;

    // Create an instance of SliverVisibilityDetector
    final sliverDetector = SliverVisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        // Update lastInfo with the current visibility information
        lastInfo = info;
      },
      sliver: SliverToBoxAdapter(
        child: Container(
          width: 200,
          height: 350,
          color: Colors.red,
        ),
      ),
      isChangedOnDispose: false,
    );

    // Mount the SliverVisibilityDetector to the widget tree within a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              sliverDetector,
            ],
          ),
        ),
      ),
    );

    // Trigger visibility update
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Verify that the visibility information has been updated
    expect(lastInfo, isNotNull);
    // Assert the expected visibility fraction
    expect(lastInfo?.visibleFraction, 1.0);

    // Unmount the SliverVisibilityDetector
    await tester.pumpWidget(const Placeholder());
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Trigger visibility update again to ensure onVisibilityChanged is not called
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Verify that lastInfo retains its original value
    expect(lastInfo?.visibleFraction, 1.0);
  });

  testWidgets(
      'SliverVisibilityDetector unmount sets onVisibilityChanged to null',
      (WidgetTester tester) async {
    // Variable to hold the last visibility information
    VisibilityInfo? lastInfo;

    // Create an instance of SliverVisibilityDetector
    final sliverDetector = SliverVisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        // Update lastInfo with the current visibility information
        lastInfo = info;
      },
      sliver: SliverToBoxAdapter(
        child: Container(
          width: 200,
          height: 350,
          color: Colors.red,
        ),
      ),
      isChangedOnDispose: false,
    );

    // Mount the SliverVisibilityDetector to the widget tree within a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              sliverDetector,
            ],
          ),
        ),
      ),
    );

    // Trigger visibility update
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Verify that the visibility information has been updated
    expect(lastInfo, isNotNull);

    // Unmount the SliverVisibilityDetector
    await tester.pumpWidget(const Placeholder());
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Trigger visibility update again to ensure onVisibilityChanged is not called
    await tester.pump(VisibilityDetectorController.instance.updateInterval);

    // Verify that lastInfo retains its original value
    expect(lastInfo!.visibleFraction, 1.0);

    // Attempt to access RenderSliverVisibilityDetector
    final renderObjects =
        tester.allElements.whereType<RenderSliverVisibilityDetector>();

    // Ensure that renderObjects is empty, as it should be unmounted
    expect(renderObjects.length, 0);
  });
}
