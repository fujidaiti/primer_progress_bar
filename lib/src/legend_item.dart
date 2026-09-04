import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:primer_progress_bar/src/segment.dart';
import 'package:primer_progress_bar/src/segmented_bar_legend.dart';
import 'package:primer_progress_bar/src/utils/padding_wrap.dart';

const _horizontalLayoutMinimumWidth = 32.0;
const _valueLabelMaximumWidth = 120.0;

/// An item aligned in a [SegmentedBarLegend].
class LegendItem extends StatelessWidget {
  /// Create a legend item from a [Segment].
  const LegendItem({super.key, required this.segment, this.style});

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
        decoration: style.handleDecoration.copyWith(color: segment.color),
      ),
    );

    final Widget? label;
    if (style.behavior != LegendItemBehavior.onlyValue &&
        segment.label != null) {
      label = DefaultTextStyle.merge(
        style: style.labelStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: segment.label!,
      );
    } else {
      label = null;
    }

    final Widget? valueLabel;
    if (style.behavior != LegendItemBehavior.onlyLabel) {
      valueLabel = DefaultTextStyle.merge(
        style: style.valueLabelStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: _ShrinkableValueText(segment.valueLabel),
      );
    } else {
      valueLabel = null;
    }

    return style.padding.wrap(
      LayoutBuilder(
        builder: (context, constraints) {
          final handleWidth = style.handleSize + style.handlePadding.horizontal;
          if (constraints.hasBoundedWidth &&
              constraints.maxWidth <
                  max(_horizontalLayoutMinimumWidth, handleWidth)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (label != null) style.labelPadding.wrap(label),
                if (valueLabel != null)
                  style.valueLabelPadding.wrap(valueLabel),
              ],
            );
          }

          final availableForValue = constraints.hasBoundedWidth
              ? max(0.0, constraints.maxWidth - handleWidth)
              : _valueLabelMaximumWidth;
          final valueMaximumWidth = min(
            _valueLabelMaximumWidth,
            availableForValue,
          );

          return Row(
            mainAxisSize: constraints.hasBoundedWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              style.handlePadding.wrap(handle),
              if (label != null)
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: style.labelPadding.wrap(
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: style.maxLabelSize),
                        child: label,
                      ),
                    ),
                  ),
                ),
              if (valueLabel != null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: valueMaximumWidth),
                  child: style.valueLabelPadding.wrap(valueLabel),
                ),
            ],
          );
        },
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
            : labelStyle?.copyWith(color: labelStyle.color?.withOpacity(0.6)));

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

class _ShrinkableValueText extends StatelessWidget {
  const _ShrinkableValueText(this.text);

  final Text text;

  @override
  Widget build(BuildContext context) {
    final value = text.data;
    if (value == null) return text;

    final separatorIndex = value.lastIndexOf(' ');
    if (separatorIndex < 0) {
      return _copyText(text, value, overflow: TextOverflow.ellipsis);
    }

    final leadingText = value.substring(0, separatorIndex);
    final trailingText = value.substring(separatorIndex);
    return LayoutBuilder(
      builder: (context, constraints) {
        final defaultStyle = DefaultTextStyle.of(context).style;
        final effectiveStyle =
            text.style == null ? defaultStyle : defaultStyle.merge(text.style);
        final painter = TextPainter(
          text: TextSpan(text: trailingText, style: effectiveStyle),
          maxLines: 1,
          textScaler: text.textScaler ??
              MediaQuery.maybeOf(context)?.textScaler ??
              const TextScaler.linear(1),
          textDirection: text.textDirection ??
              Directionality.maybeOf(context) ??
              TextDirection.ltr,
          locale: text.locale,
        )..layout();

        if (constraints.maxWidth <= painter.width + 1) {
          return _copyText(text, value, overflow: TextOverflow.ellipsis);
        }

        Widget result = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _copyText(
                text,
                leadingText,
                overflow: TextOverflow.ellipsis,
                preserveKey: false,
              ),
            ),
            _copyText(text, trailingText, preserveKey: false),
          ],
        );
        if (text.semanticsLabel != null) {
          result = Semantics(
            label: text.semanticsLabel,
            excludeSemantics: true,
            child: result,
          );
        }
        if (text.key != null) {
          result = KeyedSubtree(key: text.key, child: result);
        }
        return result;
      },
    );
  }
}

Text _copyText(
  Text source,
  String data, {
  TextOverflow? overflow,
  bool preserveKey = true,
}) {
  return Text(
    data,
    key: preserveKey ? source.key : null,
    style: source.style,
    strutStyle: source.strutStyle,
    textAlign: source.textAlign,
    textDirection: source.textDirection,
    locale: source.locale,
    softWrap: source.softWrap,
    overflow: overflow,
    textScaler: source.textScaler,
    maxLines: 1,
    semanticsLabel: null,
    textWidthBasis: source.textWidthBasis,
    textHeightBehavior: source.textHeightBehavior,
    selectionColor: source.selectionColor,
  );
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
