import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:primer_progress_bar/src/segment.dart';
import 'package:primer_progress_bar/src/segmented_bar_legend.dart';
import 'package:primer_progress_bar/src/utils/padding_wrap.dart';

/// An item aligned in a [SegmentedBarLegend].
class LegendItem extends StatelessWidget {
  /// Create a legend item from a [Segment].
  const LegendItem({
    super.key,
    required this.segment,
    this.style,
  });

  /// The [Segment] that this legend item represents.
  final Segment segment;

  /// The style applied to this item.
  final LegendItemStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = resolveStyle(context);
    assert(
      !(style.behavior == LegendItemBehavior.onlyLabel &&
          segment.label == null),
    );

    final handle = SizedBox.square(
      dimension: style.handleSize,
      child: DecoratedBox(
        decoration: style.handleDecoration.copyWith(
          color: segment.color,
        ),
      ),
    );

    final Widget? label;
    if (style.behavior != LegendItemBehavior.onlyValue &&
        segment.label != null) {
      label = ConstrainedBox(
        constraints: BoxConstraints.loose(
          Size.fromWidth(style.maxLabelSize),
        ),
        child: style.labelStyle == null
            ? segment.label
            : DefaultTextStyle(
                style: style.labelStyle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: segment.label!,
              ),
      );
    } else {
      label = null;
    }

    final Widget? valueLabel;
    if (style.behavior != LegendItemBehavior.onlyLabel) {
      valueLabel = style.valueLabelStyle == null
          ? segment.valueLabel
          : DefaultTextStyle(
              style: style.valueLabelStyle!,
              maxLines: 1,
              child: segment.valueLabel,
            );
    } else {
      valueLabel = null;
    }

    return style.padding.wrap(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          style.handlePadding.wrap(handle),
          if (label != null) style.labelPadding.wrap(label),
          if (valueLabel != null) style.valueLabelPadding.wrap(valueLabel),
        ],
      ),
    );
  }

  @internal
  LegendItemStyle resolveStyle(BuildContext context) {
    const defaultStyle = LegendItemStyle();

    final behavior = style?.behavior ?? defaultStyle.behavior;
    final labelStyle =
        style?.labelStyle ?? Theme.of(context).textTheme.labelLarge;
    final valueLabelStyle = style?.valueLabelStyle ??
        (behavior == LegendItemBehavior.onlyValue
            ? labelStyle
            : labelStyle?.copyWith(
                color: labelStyle.color?.withOpacity(0.6),
              ));

    return LegendItemStyle(
      handleSize: style?.handleSize ?? defaultStyle.handleSize,
      maxLabelSize: style?.maxLabelSize ?? defaultStyle.maxLabelSize,
      handleDecoration:
          style?.handleDecoration ?? defaultStyle.handleDecoration,
      handlePadding: style?.handlePadding ?? defaultStyle.handlePadding,
      labelPadding: style?.labelPadding ?? defaultStyle.labelPadding,
      valueLabelPadding:
          style?.valueLabelPadding ?? defaultStyle.valueLabelPadding,
      padding: style?.padding ?? defaultStyle.padding,
      behavior: behavior,
      labelStyle: labelStyle,
      valueLabelStyle: valueLabelStyle,
    );
  }
}

/// Describes how a [LegendItem] paints its texts.
enum LegendItemBehavior {
  /// Only paints the [Segment.label].
  onlyLabel,

  /// Only paints the [Segment.valueLabel].
  onlyValue,

  /// Paints both of the [Segment.label] and the [Segment.valueLabel].
  both,
}

/// An immutable style that can be applied to [LegendItem]s.
@immutable
class LegendItemStyle {
  /// Creates a style for [LegendItem]s.
  const LegendItemStyle({
    this.handleSize = 10,
    this.maxLabelSize = 160,
    this.handleDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.handlePadding = const EdgeInsets.symmetric(horizontal: 4),
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 2),
    this.valueLabelPadding = const EdgeInsets.symmetric(horizontal: 2),
    this.padding = const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
    this.behavior = LegendItemBehavior.both,
    this.labelStyle,
    this.valueLabelStyle,
  })  : assert(handleSize > 0),
        assert(maxLabelSize > 0);

  /// The size of the handle.
  final double handleSize;

  /// The maximum width of the label.
  final double maxLabelSize;

  /// The decoration applied to the handle.
  final BoxDecoration handleDecoration;

  /// The padding around the handle.
  final EdgeInsets handlePadding;

  /// The padding around the label.
  final EdgeInsets labelPadding;

  /// The padding around the value label.
  final EdgeInsets valueLabelPadding;

  /// The padding around the [LegendItem].
  final EdgeInsets padding;

  /// Describes how the [LegendItem] paints its text.
  final LegendItemBehavior behavior;

  /// The fallback style for the [Segment.label].
  ///
  /// If the label of [LegendItem.segment] has no [TextStyle],
  /// this style is used instead.
  final TextStyle? labelStyle;

  /// The fallback style for the [Segment.valueLabel].
  ///
  /// If the value label of [LegendItem.segment] has no [TextStyle],
  /// this style is used instead.
  final TextStyle? valueLabelStyle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LegendItemStyle &&
          runtimeType == other.runtimeType &&
          maxLabelSize == other.maxLabelSize &&
          handleSize == other.handleSize &&
          handleDecoration == other.handleDecoration &&
          handlePadding == other.handlePadding &&
          labelPadding == other.labelPadding &&
          valueLabelPadding == other.valueLabelPadding &&
          padding == other.padding &&
          behavior == other.behavior &&
          labelStyle == other.labelStyle &&
          valueLabelStyle == other.valueLabelStyle);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        maxLabelSize,
        handleSize,
        handleDecoration,
        handlePadding,
        labelPadding,
        valueLabelPadding,
        padding,
        behavior,
        labelStyle,
        valueLabelStyle,
      );
}
