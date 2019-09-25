import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets/src/responsive_ui/responsive_ui.dart';

void main() {
  group('portrait', () {
    group('handset', () {
      testWidgets('300 x 400', (tester) async {
        await runTest(tester,
            size: Size(300.0, 400.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.small,
            expectedWindowSize: MobileWindowSize.xsmall,
            expectedColumns: 4,
            expectedGutter: 16.0);
      });

      testWidgets('380 x 420', (tester) async {
        await runTest(tester,
            size: Size(380.0, 420.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.medium,
            expectedWindowSize: MobileWindowSize.xsmall,
            expectedColumns: 4,
            expectedGutter: 16.0);
      });

      testWidgets('450 x 600', (tester) async {
        await runTest(tester,
            size: Size(450.0, 600.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.xsmall,
            expectedColumns: 4,
            expectedGutter: 16.0);
      });

      testWidgets('500 x 700', (tester) async {
        await runTest(tester,
            size: Size(500.0, 700.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.xsmall,
            expectedColumns: 4,
            expectedGutter: 16.0);
      });
    });

    group('tablet', () {
      testWidgets('640 x 800', (tester) async {
        await runTest(tester,
            size: Size(640.0, 800.0),
            expectedDeviceType: MobileDeviceType.tablet,
            expectedDeviceSize: MobileDeviceSize.small,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 8,
            expectedGutter: 24.0);
      });

      testWidgets('800 x 1020', (tester) async {
        await runTest(tester,
            size: Size(800.0, 1020.0),
            expectedDeviceType: MobileDeviceType.tablet,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 8,
            expectedGutter: 24.0);
      });
    });
  });

  group('landscape', () {
    group('handset', () {
      testWidgets('500 x 300', (tester) async {
        await runTest(tester,
            size: Size(500.0, 300.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.small,
            expectedWindowSize: MobileWindowSize.xsmall,
            expectedColumns: 4,
            expectedGutter: 16.0);
      });

      testWidgets('700 x 480', (tester) async {
        await runTest(tester,
            size: Size(700.0, 480.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.medium,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 8,
            expectedGutter: 16.0);
      });

      testWidgets('700 x 640', (tester) async {
        await runTest(tester,
            size: Size(700.0, 640.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.medium,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 8,
            expectedGutter: 24.0);
      });

      testWidgets('800 x 480', (tester) async {
        await runTest(tester,
            size: Size(800.0, 480.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 8,
            expectedGutter: 16.0);
      });

      testWidgets('800 x 640', (tester) async {
        await runTest(tester,
            size: Size(800.0, 640.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 8,
            expectedGutter: 24.0);
      });

      testWidgets('900 x 480', (tester) async {
        await runTest(tester,
            size: Size(900.0, 480.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 12,
            expectedGutter: 16.0);
      });

      testWidgets('900 x 640', (tester) async {
        await runTest(tester,
            size: Size(900.0, 640.0),
            expectedDeviceType: MobileDeviceType.handset,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 12,
            expectedGutter: 24.0);
      });
    });

    group('tablet', () {
      testWidgets('1000 x 800', (tester) async {
        await runTest(tester,
            size: Size(1000.0, 800.0),
            expectedDeviceType: MobileDeviceType.tablet,
            expectedDeviceSize: MobileDeviceSize.small,
            expectedWindowSize: MobileWindowSize.small,
            expectedColumns: 12,
            expectedGutter: 24.0);
      });

      testWidgets('1280 x 1024', (tester) async {
        await runTest(tester,
            size: Size(1280.0, 1024.0),
            expectedDeviceType: MobileDeviceType.tablet,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.medium,
            expectedColumns: 12,
            expectedGutter: 24.0);
      });

      testWidgets('1500 x 1280', (tester) async {
        await runTest(tester,
            size: Size(1500.0, 1280.0),
            expectedDeviceType: MobileDeviceType.tablet,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.large,
            expectedColumns: 12,
            expectedGutter: 24.0);
      });

      testWidgets('2000 x 1500', (tester) async {
        await runTest(tester,
            size: Size(2000.0, 1500.0),
            expectedDeviceType: MobileDeviceType.tablet,
            expectedDeviceSize: MobileDeviceSize.large,
            expectedWindowSize: MobileWindowSize.xlarge,
            expectedColumns: 12,
            expectedGutter: 24.0);
      });
    });
  });
}

Future<Null> runTest(WidgetTester tester,
    {Size size,
    MobileDeviceType expectedDeviceType,
    MobileDeviceSize expectedDeviceSize,
    MobileWindowSize expectedWindowSize,
    int expectedColumns,
    double expectedGutter}) async {
  final recorder = ResponsiveUiRecorder(
      expectedDeviceType: expectedDeviceType,
      expectedDeviceSize: expectedDeviceSize,
      expectedWindowSize: expectedWindowSize,
      expectedColumns: expectedColumns,
      expectedGutter: expectedGutter);
  await tester.pumpWidget(
      SizedContainer(size: size, child: ResponsiveUiWidget(recorder)));
  recorder.testResponsiveData();
}

class ResponsiveUiRecorder {
  static const _tolerance = .01;

  final MobileDeviceType expectedDeviceType;
  final MobileDeviceSize expectedDeviceSize;
  final MobileWindowSize expectedWindowSize;
  final int expectedColumns;
  final double expectedGutter;
  MaterialResponsiveUiData data;

  ResponsiveUiRecorder(
      {this.expectedDeviceType,
      this.expectedDeviceSize,
      this.expectedWindowSize,
      this.expectedColumns,
      this.expectedGutter});

  void testResponsiveData() {
    expect(data.deviceInfo.deviceType, expectedDeviceType);
    expect(data.deviceInfo.deviceSize, expectedDeviceSize);
    expect(data.windowSize, expectedWindowSize);
    expect(data.columns, expectedColumns);
    expect(data.gutter, closeTo(expectedGutter, _tolerance));
  }
}

class ResponsiveUiWidget extends StatelessWidget {
  final ResponsiveUiRecorder recorder;

  ResponsiveUiWidget(this.recorder);

  @override
  Widget build(BuildContext context) {
    recorder.data = MaterialResponsiveUiData.of(context);
    return Container();
  }
}

class SizedContainer extends StatelessWidget {
  final Widget child;
  final Size size;

  SizedContainer({this.child, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }
}
