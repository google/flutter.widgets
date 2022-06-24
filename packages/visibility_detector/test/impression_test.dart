import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  testWidgets('Material clip', (tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    final Key listKey = UniqueKey();
    int onFirstVis = 0;
    int onEnterVis = 0;
    int onExitVis = 0;
    bool inView = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SingleChildScrollView(
            child: Column(
              key: listKey,
              children: [
                SizedBox.fromSize(size: Size(200, 1000)),
                VisibilityDetector(
                  key: UniqueKey(),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction > .6) {
                      inView = true;
                      onFirstVis = 1;
                      onEnterVis += 1;
                    } else if (inView && info.visibleFraction < .4) {
                      onExitVis += 1;
                      inView = false;
                    }
                  },
                  child: Container(
                    height: 200,
                    width: 300,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(onFirstVis, 0);
    expect(onEnterVis, 0);
    expect(onExitVis, 0);

    final drags = [-1000.0, 1000.0, -1000.0, 1000.0, -1000.0];
    for (final dragAmount in drags) {
      await tester.drag(
          find.byType(SingleChildScrollView), Offset(0.0, dragAmount));
      await tester.pumpAndSettle();
    }

    expect(onFirstVis, 1);
    expect(onEnterVis, 3);
    expect(onExitVis, 2);
  });

  testWidgets('Material clip with intermediate ROs', (tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    final Key listKey = UniqueKey();
    int onFirstVis = 0;
    int onEnterVis = 0;
    int onExitVis = 0;
    bool inView = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SingleChildScrollView(
            child: Column(
              key: listKey,
              children: [
                SizedBox.fromSize(size: Size(200, 1000)),
                CustomPaint(
                  child: VisibilityDetector(
                    key: UniqueKey(),
                    onVisibilityChanged: (info) {
                      if (info.visibleFraction > .6) {
                        inView = true;
                        onFirstVis = 1;
                        onEnterVis += 1;
                      } else if (inView && info.visibleFraction < .4) {
                        onExitVis += 1;
                        inView = false;
                      }
                    },
                    child: Container(
                      height: 200,
                      width: 300,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(onFirstVis, 0);
    expect(onEnterVis, 0);
    expect(onExitVis, 0);

    final drags = [-1000.0, 1000.0, -1000.0, 1000.0, -1000.0];
    for (final dragAmount in drags) {
      await tester.drag(
          find.byType(SingleChildScrollView), Offset(0.0, dragAmount));
      await tester.pumpAndSettle();
    }

    expect(onFirstVis, 1);
    expect(onEnterVis, 3);
    expect(onExitVis, 2);
  });

  testWidgets('Programmatic visibility change', (WidgetTester tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    final List<VisibilityInfo> infos = <VisibilityInfo>[];
    await tester.pumpWidget(
      VisibilityDetector(
        key: Key('app_widget'),
        onVisibilityChanged: (info) {
          infos.add(info);
        },
        child: Visibility(
          maintainState: true,
          visible: true,
          child: VisibilityDetector(
            key: Key('weatherCard'),
            onVisibilityChanged: (info) {
              infos.add(info);
            },
            child: Placeholder(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      VisibilityDetector(
        key: Key('app_widget'),
        onVisibilityChanged: (info) {
          infos.add(info);
        },
        child: Visibility(
          maintainState: true,
          visible: false,
          child: VisibilityDetector(
            key: Key('weatherCard'),
            onVisibilityChanged: (info) {
              infos.add(info);
            },
            child: Placeholder(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      VisibilityDetector(
        key: Key('app_widget'),
        onVisibilityChanged: (info) {
          infos.add(info);
        },
        child: Visibility(
          maintainState: true,
          visible: true,
          child: VisibilityDetector(
            key: Key('weatherCard'),
            onVisibilityChanged: (info) {
              infos.add(info);
            },
            child: Placeholder(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(Placeholder());
    await tester.pumpAndSettle();

    expect(infos, const <VisibilityInfo>[
      VisibilityInfo(
        key: Key('app_widget'),
        size: Size(800, 600),
        visibleBounds: Rect.fromLTRB(0, 0, 800, 600),
      ),
      VisibilityInfo(
        key: Key('weatherCard'),
        size: Size(800, 600),
        visibleBounds: Rect.fromLTRB(0, 0, 800, 600),
      ),
      VisibilityInfo(
        key: Key('weatherCard'),
        size: Size(800, 600),
      ),
      VisibilityInfo(
        key: Key('weatherCard'),
        size: Size(800, 600),
        visibleBounds: Rect.fromLTRB(0, 0, 800, 600),
      ),
      VisibilityInfo(
        key: Key('app_widget'),
        size: Size(800, 600),
      ),
      VisibilityInfo(
        key: Key('weatherCard'),
        size: Size(800, 600),
      ),
    ]);
  });
}
