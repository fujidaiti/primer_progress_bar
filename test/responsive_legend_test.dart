import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

const _segments = [
  Segment(
    value: 1,
    color: Colors.red,
    label: Text('Alpha'),
    valueLabel: Text('100 MB'),
  ),
  Segment(
    value: 2,
    color: Colors.orange,
    label: Text('Beta'),
    valueLabel: Text('200 MB'),
  ),
  Segment(
    value: 3,
    color: Colors.yellow,
    label: Text('Gamma'),
    valueLabel: Text('300 MB'),
  ),
  Segment(
    value: 4,
    color: Colors.green,
    label: Text('Delta'),
    valueLabel: Text('400 MB'),
  ),
  Segment(
    value: 5,
    color: Colors.blue,
    label: Text('Epsilon'),
    valueLabel: Text('500 MB'),
  ),
  Segment(
    value: 6,
    color: Colors.purple,
    label: Text('Zeta'),
    valueLabel: Text('600 MB'),
  ),
];

void main() {
  group('responsive legend', () {
    testWidgets('fits at narrow and ultra-narrow widths', (tester) async {
      await _pumpLegend(tester, width: 225);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Zeta'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pumpLegend(
        tester,
        width: 40,
        children: const [
          LegendItem(
            segment: Segment(
              value: 1,
              color: Colors.red,
              label: Text('Alpha'),
              valueLabel: Text('10%'),
            ),
          ),
        ],
      );

      expect(
        tester.getTopLeft(find.text('10%')).dy,
        greaterThan(tester.getTopLeft(find.text('Alpha')).dy),
      );
      expect(_handleWithColor(Colors.red), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('changes from one equal-width column to multiple columns', (
      tester,
    ) async {
      await _pumpLegend(tester, width: 450);

      final alpha = find.text('Alpha');
      final beta = find.text('Beta');
      expect(
        tester.getTopLeft(beta).dy,
        greaterThan(tester.getTopLeft(alpha).dy),
      );

      await _pumpLegend(tester, width: 900);

      expect(tester.getTopLeft(beta).dy, tester.getTopLeft(alpha).dy);
      expect(
        tester.getTopLeft(beta).dx,
        greaterThan(tester.getTopLeft(alpha).dx),
      );
      expect(
        tester.getTopLeft(_handleWithColor(Colors.red)).dx,
        tester.getTopLeft(_handleWithColor(Colors.green)).dx,
      );
      expect(
        tester.getTopLeft(_handleWithColor(Colors.orange)).dx,
        tester.getTopLeft(_handleWithColor(Colors.blue)).dx,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('retains a trailing value unit while the number shrinks', (
      tester,
    ) async {
      await _pumpLegend(
        tester,
        width: 100,
        children: const [
          LegendItem(
            segment: Segment(
              value: 123456789,
              color: Colors.red,
              label: Text('Size'),
              valueLabel: Text('123456789 MB'),
            ),
          ),
        ],
      );

      expect(find.text(' MB'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports rich value text, RTL, and enlarged text', (
      tester,
    ) async {
      await _pumpLegend(
        tester,
        width: 225,
        textDirection: TextDirection.rtl,
        textScaler: const TextScaler.linear(2),
        children: const [
          LegendItem(
            segment: Segment(
              value: 1,
              color: Colors.red,
              label: Text('A long localized label'),
              valueLabel: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '100'),
                    TextSpan(text: ' MB'),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

      expect(find.text('A long localized label'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('preserves every LegendItemBehavior', (tester) async {
      for (final behavior in LegendItemBehavior.values) {
        await _pumpLegend(
          tester,
          width: 225,
          children: [
            LegendItem(
              segment: const Segment(
                value: 1,
                color: Colors.red,
                label: Text('Label'),
                valueLabel: Text('Value'),
              ),
              style: LegendItemStyle(behavior: behavior),
            ),
          ],
        );

        expect(
          find.text('Label'),
          behavior == LegendItemBehavior.onlyValue
              ? findsNothing
              : findsOneWidget,
        );
        expect(
          find.text('Value'),
          behavior == LegendItemBehavior.onlyLabel
              ? findsNothing
              : findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('continues to honor maxLabelSize', (tester) async {
      const label = 'A label that is much wider than thirty pixels';
      await _pumpLegend(
        tester,
        width: 900,
        children: const [
          LegendItem(
            segment: Segment(value: 1, color: Colors.red, label: Text(label)),
            style: LegendItemStyle(maxLabelSize: 30),
          ),
        ],
      );

      expect(tester.getSize(find.text(label)).width, lessThanOrEqualTo(30));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('maxLines ellipsizes by responsive column capacity', (
    tester,
  ) async {
    await _pumpProgressBar(tester, width: 900);

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsNothing);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('hidden:4'), findsOneWidget);

    var bar = tester.widget<SegmentedBar>(find.byType(SegmentedBar));
    expect(bar.segments.map((segment) => segment.value), [1, 2, 18]);
    expect(tester.takeException(), isNull);

    await _pumpProgressBar(tester, width: 450);

    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('hidden:6'), findsOneWidget);
    bar = tester.widget<SegmentedBar>(find.byType(SegmentedBar));
    expect(bar.segments.map((segment) => segment.value), [21]);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpLegend(
  WidgetTester tester, {
  required double width,
  List<LegendItem>? children,
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            body: SegmentedBarLegend(
              children: children ??
                  _segments
                      .map((segment) => LegendItem(segment: segment))
                      .toList(),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpProgressBar(
  WidgetTester tester, {
  required double width,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PrimerProgressBar(
          segments: _segments,
          legendStyle: const SegmentedBarLegendStyle(maxLines: 1),
          legendEllipsisBuilder: (truncatedItemCount) {
            final value = _segments
                .skip(_segments.length - truncatedItemCount)
                .fold(0, (total, segment) => total + segment.value);
            return LegendItem(
              segment: Segment(
                value: value,
                color: Colors.grey,
                label: const Text('Other'),
                valueLabel: Text('hidden:$truncatedItemCount'),
              ),
            );
          },
        ),
      ),
    ),
  );
}

Finder _handleWithColor(Color color) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).color == color,
  );
}
