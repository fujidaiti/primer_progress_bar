import 'package:flutter/material.dart';

@immutable
class Segment {
  const Segment({
    required this.value,
    required this.color,
    this.label,
    Text? formattedValue,
  }) : _valueLabel = formattedValue;

  final Color color;
  final int value;
  final Text? label;
  final Text? _valueLabel;

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
