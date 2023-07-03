import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

void main() {
  testWidgets('PrimerProgressBar displays legend items for each segment',
      (WidgetTester tester) async {
    /// Create a list of segments
    List<Segment> segments = [
      const Segment(value: 80, color: Colors.purple, label: Text("Done")),
      const Segment(
          value: 14, color: Colors.deepOrange, label: Text("In progress")),
      const Segment(value: 6, color: Colors.green, label: Text("Open")),
    ];
    // Build the widget tree
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PrimerProgressBar(segments: segments)),
    ));

    // Verify that the widget displays the segments
    expect(find.byType(PrimerProgressBar), findsOneWidget);
    expect(find.byType(LegendItem), findsNWidgets(segments.length));
  });
  testWidgets(
      'PrimerProgressBar displays no legend items when segments is empty',
      (WidgetTester tester) async {
    // Create an empty list of segments
    final segments = <Segment>[];

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimerProgressBar(segments: segments),
        ),
      ),
    );

    // Verify that the widget displays no LegendItem widgets
    expect(find.byType(PrimerProgressBar), findsOneWidget);
    expect(find.byType(LegendItem), findsNothing);
  });
  testWidgets(
      'PrimerProgressBar displays correct legend item when one segment has value of 0',
      (WidgetTester tester) async {
    // Create a list with one segment with a value of 0
    final segments = [
      const Segment(value: 0, color: Colors.purple, label: Text("Done")),
    ];

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimerProgressBar(segments: segments),
        ),
      ),
    );

    // Verify that the widget displays the correct LegendItem widget
    expect(find.byType(PrimerProgressBar), findsOneWidget);
    expect(find.byType(LegendItem), findsOneWidget);
    expect(find.text("Done"), findsOneWidget);
  });

  testWidgets(
      'PrimerProgressBar displays legend ellipsis when legend items are longer than the maximum lines',
      (WidgetTester tester) async {
    // Create a list of segments with labels that are longer than the maximum lines.
    final segments = [
      const Segment(value: 80, color: Colors.purple, label: Text("label")),
      const Segment(value: 14, color: Colors.deepOrange, label: Text("label")),
      const Segment(value: 6, color: Colors.green, label: Text("label")),
    ];

    // Build the widget tree with a maxLines value of 2 and an ellipsisBuilder function that creates an other LegendItem for the overflowed items
    final progressBar = PrimerProgressBar(
      segments: segments,
      legendStyle: const SegmentedBarLegendStyle(maxLines: 2),
      legendEllipsisBuilder: (truncatedItemCount) {
        final value = segments
            .skip(segments.length - truncatedItemCount)
            .fold(0, (accValue, segment) => accValue + segment.value);
        return LegendItem(
          segment: Segment(
            value: value,
            color: Colors.grey,
            label: const Text("Other"),
            valueLabel: Text("$value%"),
          ),
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: progressBar,
        ),
      ),
    );

    // Verify that the widget displays an ellipsis LegendItem for the overflowed items
    expect(find.byType(PrimerProgressBar), findsOneWidget);
    expect(find.text("Other"), findsOneWidget);
  });

  testWidgets(
      'PrimerProgressBar displays correct progress bar value label with custom maximum value',
      (WidgetTester tester) async {
    // Create a list of segments with a custom maximum value
    final segments = [
      const Segment(value: 80, color: Colors.purple, label: Text("Done")),
      const Segment(
          value: 14, color: Colors.deepOrange, label: Text("In progress")),
      const Segment(value: 6, color: Colors.green, label: Text("Open")),
    ];

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimerProgressBar(
            segments: segments,
            maxTotalValue: 100,
          ),
        ),
      ),
    );

    // Verify that the widget displays the correct progress bar length and value label
    expect(find.byType(PrimerProgressBar), findsOneWidget);
    expect(find.byType(LegendItem), findsNWidgets(segments.length));
  });
  testWidgets(
      'PrimerProgressBar displays correct progress bar color with custom SegmentedBarStyle',
      (WidgetTester tester) async {
    // Create a list of segments with a custom color
    final segments = [
      const Segment(value: 50, color: Colors.purple, label: Text("Done")),
      const Segment(
          value: 30, color: Colors.deepOrange, label: Text("In progress")),
      const Segment(value: 20, color: Colors.green, label: Text("Open")),
      const Segment(value: 100, color: Colors.grey, label: Text("Max value")),
    ];

    // Build the widget tree with a custom SegmentedBarStyle
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimerProgressBar(
            segments: segments,
            barStyle: SegmentedBarStyle(
                backgroundColor: Colors.grey[300],
                gap: 5,
                padding: const EdgeInsets.all(16),
                shape: const StadiumBorder(
                  side: BorderSide(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
                size: 10),
          ),
        ),
      ),
    );

    // Verify that the widget displays the correct progress bar length and color
    expect(find.byType(PrimerProgressBar), findsOneWidget);
    expect(find.byType(LegendItem), findsNWidgets(segments.length));
    expect(find.byType(PrimerProgressBar), findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is SegmentedBar &&
            widget.style.backgroundColor == Colors.grey[300]),
        findsOneWidget);
    expect(
        find.byWidgetPredicate(
            (widget) => widget is SegmentedBar && widget.style.gap == 5),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is SegmentedBar &&
            widget.style.padding == const EdgeInsets.all(16)),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is SegmentedBar && widget.style.shape is StadiumBorder),
        findsOneWidget);
    expect(
        find.byWidgetPredicate(
            (widget) => widget is SegmentedBar && widget.style.size == 10),
        findsOneWidget);
  });
}
