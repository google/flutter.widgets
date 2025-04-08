import 'package:flutter/widgets.dart';

import 'render_visibility_detector.dart';
import 'visibility_detector.dart';

/// An [Element] that manages the lifecycle of the associated [RenderVisibilityDetector].
///
/// This element is responsible for:
/// - Attaching/detaching the [RenderVisibilityDetector] to the render tree
/// - Clearing visibility callback references during unmounting to prevent memory leaks
/// - Coordinating visibility updates with [VisibilityDetectorController]
///
/// When this element is unmounted from the widget tree, it will:
/// 1. Nullify the [RenderVisibilityDetector.onVisibilityChanged] callback
/// 2. Trigger disposal of the associated [RenderVisibilityDetector]
/// 3. Release subscriptions to visibility tracking mechanisms
///
/// {@template visibility_detector_element_ownership}
/// This element is automatically created and managed by the framework when using
/// a [VisibilityDetector] widget. Developers should never need to instantiate this
/// class directly.
/// {@endtemplate}
///
/// See also:
/// - [VisibilityDetector], the widget that creates this element
/// - [RenderVisibilityDetector], the render object managed by this element
class VisibilityDetectorElement extends SingleChildRenderObjectElement {
  VisibilityDetectorElement(VisibilityDetector widget) : super(widget);

  @override
  void unmount() {
    final renderObject = this.renderObject;
    if (renderObject is RenderVisibilityDetector) {
      renderObject.onVisibilityChanged = null;
    }
    super.unmount();
  }
}

/// An [Element] that manages the lifecycle of the associated [RenderSliverVisibilityDetector].
///
/// This element is responsible for:
/// - Attaching/detaching the [RenderSliverVisibilityDetector] to the render tree
/// - Clearing visibility callback references during unmounting to prevent memory leaks
/// - Coordinating visibility updates with [VisibilityDetectorController]
///
/// When this element is unmounted from the widget tree, it will:
/// 1. Nullify the [RenderSliverVisibilityDetector.onVisibilityChanged] callback
/// 2. Trigger disposal of the associated [RenderSliverVisibilityDetector]
/// 3. Release subscriptions to visibility tracking mechanisms
///
/// {@template sliver_visibility_detector_element_ownership}
/// This element is automatically created and managed by the framework when using
/// a [SliverVisibilityDetector] widget. Developers should never need to instantiate this
/// class directly.
/// {@endtemplate}
///
/// See also:
/// - [SliverVisibilityDetector], the widget that creates this element
/// - [RenderSliverVisibilityDetector], the render object managed by this element
class SliverVisibilityDetectorElement extends SingleChildRenderObjectElement {
  SliverVisibilityDetectorElement(SliverVisibilityDetector widget)
      : super(widget);

  @override
  void unmount() {
    final renderObject = this.renderObject;
    if (renderObject is RenderSliverVisibilityDetector) {
      renderObject.onVisibilityChanged = null;
    }
    super.unmount();
  }
}
