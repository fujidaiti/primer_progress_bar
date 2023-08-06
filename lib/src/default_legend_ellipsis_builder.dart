import 'package:flutter/material.dart';
import 'package:primer_progress_bar/src/legend_item.dart';
import 'package:primer_progress_bar/src/segment.dart';
import 'package:primer_progress_bar/src/segmented_bar.dart';
import 'package:primer_progress_bar/src/segmented_bar_legend.dart';

/// Signature of callbacks that create a [Text] from a [value]
/// to be used as a value label for a [LegendItem].
typedef ValueLabelBuilder = Text Function(int value);

/// A convenience object that creates legend ellipsis for [SegmentedBarLegend].
///
/// Example:
///
/// ```dart
/// PrimerProgressBar(
///   segments: segments,
///   legendEllipsisBuilder: DefaultLegendEllipsisBuilder(
///     segments: segments,
///     color: Colors.grey,
///     label: const Text("Other"),
///     valueLabelBuilder: (value) => Text("$value%"),
///   ),
/// );
/// ```
///
class DefaultLegendEllipsisBuilder {
  /// Creates a callable object that can be used as [SegmentedBarLegend.ellipsisBuilder].
  const DefaultLegendEllipsisBuilder({
    required this.segments,
    required this.color,
    this.label,
    this.valueLabelBuilder,
  });

  /// All segments displayed in the [SegmentedBar].
  ///
  /// Used to calculate [Segment.value] for the ellipsis.
  final List<Segment> segments;

  /// Color for the ellipsis.
  final Color color;

  /// [Text] used as the label of the ellipsis.
  final Text? label;

  /// Callback that creates a value label for the ellipsis.
  ///
  /// This will be called with the sum of [Segment.value]s
  /// for each legend item that overflowed.
  final ValueLabelBuilder? valueLabelBuilder;

  /// Creates a [LegendItem] ellipsis from the number of overflowed items.
  LegendItem call(int truncatedItemCount) {
    final value = segments
        .skip(segments.length - truncatedItemCount)
        .fold(0, (accValue, segment) => accValue + segment.value);
    return LegendItem(
      segment: Segment(
        value: value,
        color: color,
        label: label,
        valueLabel: valueLabelBuilder?.call(value),
      ),
    );
  }
}
