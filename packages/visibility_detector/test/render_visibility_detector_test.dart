// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/src/render_visibility_detector.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  testWidgets('RVS (box) unregisters its callback on paint',
      (WidgetTester tester) async {
    final RenderVisibilityDetector detector = RenderVisibilityDetector(
      key: Key('test'),
      onVisibilityChanged: (_) {},
    );

    final ContainerLayer layer = ContainerLayer();
    final PaintingContext context = PaintingContext(layer, Rect.largest);
    expect(layer.subtreeHasCompositionCallbacks, false);

    detector.layout(BoxConstraints.tight(const Size(200, 200)));
    detector.paint(context, Offset.zero);
    detector.paint(context, Offset.zero);

    context.stopRecordingIfNeeded(); // ignore: invalid_use_of_protected_member

    expect(layer.subtreeHasCompositionCallbacks, true);

    expect(detector.debugScheduleUpdateCount, 0);
    layer.buildScene(SceneBuilder()).dispose();

    expect(detector.debugScheduleUpdateCount, 1);
  });

  testWidgets('RVS (sliver) unregisters its callback on paint',
      (WidgetTester tester) async {
    final RenderSliverVisibilityDetector detector =
        RenderSliverVisibilityDetector(
      key: Key('test'),
      onVisibilityChanged: (_) {},
      sliver: RenderSliverToBoxAdapter(child: RenderLimitedBox()),
    );

    final ContainerLayer layer = ContainerLayer();
    final PaintingContext context = PaintingContext(layer, Rect.largest);
    expect(layer.subtreeHasCompositionCallbacks, false);

    detector.layout(SliverConstraints(
      axisDirection: AxisDirection.down,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.forward,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: 0,
      crossAxisExtent: 0,
      crossAxisDirection: AxisDirection.left,
      viewportMainAxisExtent: 0,
      remainingCacheExtent: 0,
      cacheOrigin: 0,
    ));

    final owner = PipelineOwner();
    detector.attach(owner);
    owner.flushCompositingBits();

    detector.paint(context, Offset.zero);
    detector.paint(context, Offset.zero);
    expect(layer.subtreeHasCompositionCallbacks, true);

    expect(detector.debugScheduleUpdateCount, 0);
    context.stopRecordingIfNeeded(); // ignore: invalid_use_of_protected_member
    layer.buildScene(SceneBuilder()).dispose();

    expect(detector.debugScheduleUpdateCount, 1);
  });

  testWidgets('RVS unregisters its callback on dispose',
      (WidgetTester tester) async {
    final RenderVisibilityDetector detector = RenderVisibilityDetector(
      key: Key('test'),
      onVisibilityChanged: (_) {},
    );

    final ContainerLayer layer = ContainerLayer();
    final PaintingContext context = PaintingContext(layer, Rect.largest);
    expect(layer.subtreeHasCompositionCallbacks, false);

    detector.layout(BoxConstraints.tight(const Size(200, 200)));

    detector.paint(context, Offset.zero);
    expect(layer.subtreeHasCompositionCallbacks, true);

    detector.dispose();
    expect(layer.subtreeHasCompositionCallbacks, false);

    expect(detector.debugScheduleUpdateCount, 0);
    context.stopRecordingIfNeeded(); // ignore: invalid_use_of_protected_member
    layer.buildScene(SceneBuilder()).dispose();

    expect(detector.debugScheduleUpdateCount, 0);
  });

  testWidgets('RVS unregisters its callback when callback changes',
      (WidgetTester tester) async {
    final RenderVisibilityDetector detector = RenderVisibilityDetector(
      key: Key('test'),
      onVisibilityChanged: (_) {},
    );

    final ContainerLayer layer = ContainerLayer();
    final PaintingContext context = PaintingContext(layer, Rect.largest);
    expect(layer.subtreeHasCompositionCallbacks, false);

    detector.layout(BoxConstraints.tight(const Size(200, 200)));

    detector.paint(context, Offset.zero);
    expect(layer.subtreeHasCompositionCallbacks, true);

    detector.onVisibilityChanged = null;

    expect(layer.subtreeHasCompositionCallbacks, false);

    expect(detector.debugScheduleUpdateCount, 0);
    context.stopRecordingIfNeeded(); // ignore: invalid_use_of_protected_member
    layer.buildScene(SceneBuilder()).dispose();

    expect(detector.debugScheduleUpdateCount, 0);
  });
}
