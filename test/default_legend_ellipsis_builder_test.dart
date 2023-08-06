import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

void main() {
  group("DefaultLegendEllipsisBuilder", () {
    test("should create a correct ellipsis", () {
      final builder = DefaultLegendEllipsisBuilder(
        segments: const [
          Segment(value: 10, color: Colors.red),
          Segment(value: 5, color: Colors.blue),
          Segment(value: 2, color: Colors.green),
        ],
        color: Colors.grey,
        label: const Text("Other"),
        valueLabelBuilder: (value) => Text("$value%"),
      );

      const overflowedItems = 2;
      final ellipsis = builder.call(overflowedItems);

      expect(ellipsis.segment.value, 7);
      expect(ellipsis.segment.color, Colors.grey);
      expect(ellipsis.segment.label?.data, "Other");
      expect(ellipsis.segment.valueLabel.data, "7%");
    });
  });
}
