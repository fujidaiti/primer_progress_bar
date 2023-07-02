import 'package:flutter/material.dart';
import 'package:primer_progress_bar/src/segmented_bar.dart';

/// An object representing a segment of [SegmentedBar].
@immutable
class Segment {
  /// Creates a segment.
  const Segment({
    required this.value,
    required this.color,
    this.label,
    Text? valueLabel,
  }) : _valueLabel = valueLabel;

  /// The color of the segment.
  final Color color;

  /// Describes the amount of space the segment occupies in a [SegmentedBar].
  final int value;

  /// A text explaining what the segment means.
  final Text? label;

  final Text? _valueLabel;

  /// A formatted [value] of the segment.
  Text get valueLabel => _valueLabel ?? Text(value.toString());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Segment &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          value == other.value &&
          label == other.label &&
          _valueLabel == other._valueLabel);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        color,
        value,
        label,
        _valueLabel,
      );
}
