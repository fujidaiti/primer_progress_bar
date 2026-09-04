import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:primer_progress_bar/src/legend_item.dart';
import 'package:primer_progress_bar/src/render_legend_simulation.dart';
import 'package:primer_progress_bar/src/segmented_bar.dart';
import 'package:primer_progress_bar/src/utils/padding_wrap.dart';

const _legendItemMinimumWidth = 220.0;
const _legendItemPreferredWidth = 280.0;
const _legendItemWidthSafetyMargin = 8.0;
const _legendValueMaximumWidth = 120.0;

/// A legend for a [SegmentedBar].
class SegmentedBarLegend extends StatelessWidget {
  /// Creates a legend from [LegendItem]s for a [SegmentedBar].
  const SegmentedBarLegend({
    super.key,
    this.children = const [],
    this.style = const SegmentedBarLegendStyle(),
    this.ellipsisBuilder,
  });

  /// A list of [LegendItem]s to be aligned in the legend.
  final List<LegendItem> children;

  /// The style applied to the legend.
  final SegmentedBarLegendStyle style;

  /// {@template primer_progress_bar.SegmentedBarLegend.ellipsisBuilder}
  /// A builder of an ellipsis [LegendItem].
  ///
  /// If the number of lines in the legend is limited, i.e.,
  /// [style.maxLines] is not null, and if the legend failed to
  /// align some items within the given line limit, the overflowing items
  /// are not shown and instead an item that is created by [ellipsisBuilder]
  /// (called an *ellipsis*) is displayed as the last item in the legend.
  ///
  /// If [style.maxLines] is not null, this property must not also be null.
  ///
  /// Example:
  ///
  /// ```dart
  /// List<Segment> segments;
  ///
  /// SegmentedBarLegend(
  ///   legendStyle: const SegmentedBarLegendStyle(maxLines: 2),
  ///   ellipsisBuilder: (truncatedItemCount) {
  ///     final value = segments
  ///         .skip(segments.length - truncatedItemCount)
  ///         .fold(0, (accValue, segment) => accValue + segment.value);
  ///     return LegendItem(
  ///       segment: Segment(
  ///         value: value,
  ///         color: Colors.grey,
  ///         label: const Text("Other"),
  ///         formattedValue: Text("$value%"),
  ///       ),
  ///     );
  ///   },
  /// );
  ///
  /// ```
  /// {@endtemplate}
  final EllipsisBuilder? ellipsisBuilder;

  @override
  Widget build(BuildContext context) {
    return style.padding.wrap(
      LayoutBuilder(
        builder: (context, constraints) {
          final layout = _resolveLayout(context, constraints);
          final items = style.maxLines == null
              ? children
              : _ellipsizeItems(layout.columnCount);

          return Wrap(
            spacing: style.spacing,
            runSpacing: style.runSpacing,
            children: [
              for (final item in items)
                SizedBox(width: layout.itemWidth, child: item),
            ],
          );
        },
      ),
    );
  }

  @internal
  List<LegendItem> ellipsizeItems(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    assert(
      ellipsisBuilder != null,
      "If the number of lines in the legend is limited, "
      "`ellipsisBuilder` must be specified.",
    );

    return _ellipsizeItems(_resolveLayout(context, constraints).columnCount);
  }

  List<LegendItem> _ellipsizeItems(int columnCount) {
    final maxLines = style.maxLines;
    if (maxLines == null) return children;

    final capacity = columnCount * maxLines;
    if (children.length <= capacity) return children;

    final visibleItemCount = capacity - 1;
    final truncatedItemCount = children.length - visibleItemCount;
    return [
      ...children.take(visibleItemCount),
      ellipsisBuilder!(truncatedItemCount),
    ];
  }

  _LegendLayout _resolveLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final availableWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : _legendItemPreferredWidth;

    var maxNaturalItemWidth = _legendItemMinimumWidth;
    for (final item in children) {
      maxNaturalItemWidth = max(
        maxNaturalItemWidth,
        _measureNaturalItemWidth(context, item),
      );
    }

    final effectiveMinimumWidth =
        maxNaturalItemWidth + _legendItemWidthSafetyMargin;
    final columnCount = max(
      1,
      ((availableWidth + style.spacing) /
              (effectiveMinimumWidth + style.spacing))
          .floor(),
    );
    final distributedItemWidth =
        (availableWidth - style.spacing * (columnCount - 1)) / columnCount;

    return _LegendLayout(
      columnCount: columnCount,
      itemWidth: min(_legendItemPreferredWidth, max(0, distributedItemWidth)),
    );
  }

  double _measureNaturalItemWidth(BuildContext context, LegendItem item) {
    final itemStyle = item.resolveStyle(context);
    var width =
        itemStyle.padding.horizontal +
        itemStyle.handlePadding.horizontal +
        itemStyle.handleSize;

    if (itemStyle.behavior != LegendItemBehavior.onlyValue &&
        item.segment.label != null) {
      width +=
          itemStyle.labelPadding.horizontal +
          _measureTextWidth(
            context,
            item.segment.label!,
            itemStyle.labelStyle,
            itemStyle.maxLabelSize,
          );
    }
    if (itemStyle.behavior != LegendItemBehavior.onlyLabel) {
      width +=
          itemStyle.valueLabelPadding.horizontal +
          _measureTextWidth(
            context,
            item.segment.valueLabel,
            itemStyle.valueLabelStyle,
            _legendValueMaximumWidth,
          );
    }

    return width;
  }

  double _measureTextWidth(
    BuildContext context,
    Text text,
    TextStyle? fallbackStyle,
    double maximumWidth,
  ) {
    final defaultStyle = fallbackStyle ?? DefaultTextStyle.of(context).style;
    final textStyle = text.style == null
        ? defaultStyle
        : defaultStyle.merge(text.style);
    final InlineSpan span;
    if (text.textSpan != null) {
      span = TextSpan(style: textStyle, children: [text.textSpan!]);
    } else {
      span = TextSpan(text: text.data, style: textStyle);
    }

    final painter = TextPainter(
      text: span,
      maxLines: 1,
      ellipsis: '\u2026',
      textScaler:
          text.textScaler ??
          MediaQuery.maybeOf(context)?.textScaler ??
          const TextScaler.linear(1),
      textDirection:
          text.textDirection ??
          Directionality.maybeOf(context) ??
          TextDirection.ltr,
      locale: text.locale,
    )..layout(maxWidth: maximumWidth);
    return painter.width;
  }
}

class _LegendLayout {
  const _LegendLayout({required this.columnCount, required this.itemWidth});

  final int columnCount;
  final double itemWidth;
}

/// An immutable style that can be applied to [SegmentedBarLegend]s.
@immutable
class SegmentedBarLegendStyle {
  /// Creates a style for [SegmentedBarLegend]s.
  const SegmentedBarLegendStyle({
    this.maxLines,
    this.spacing = 4,
    this.runSpacing = 4,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  }) : assert(maxLines == null || maxLines > 0),
       assert(spacing >= 0),
       assert(runSpacing >= 0);

  /// The maximum number of lines in the legend.
  final int? maxLines;

  /// The amount of the horizontal space between adjacent items in the legend.
  final double spacing;

  /// The amount of the vertical space between adjacent lines.
  final double runSpacing;

  /// The padding around the legend.
  final EdgeInsets padding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SegmentedBarLegendStyle &&
          runtimeType == other.runtimeType &&
          maxLines == other.maxLines &&
          spacing == other.spacing &&
          runSpacing == other.runSpacing &&
          padding == other.padding);

  @override
  int get hashCode =>
      Object.hash(runtimeType, maxLines, spacing, runSpacing, padding);
}
