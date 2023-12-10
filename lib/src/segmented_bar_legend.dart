import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:primer_progress_bar/src/legend_item.dart';
import 'package:primer_progress_bar/src/render_legend_simulation.dart';
import 'package:primer_progress_bar/src/segmented_bar.dart';
import 'package:primer_progress_bar/src/utils/padding_wrap.dart';

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
    final Widget result;
    if (style.maxLines != null && children.isNotEmpty) {
      result = LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: style.spacing,
            runSpacing: style.runSpacing,
            children: ellipsizeItems(context, constraints),
          );
        },
      );
    } else {
      result = Wrap(
        spacing: style.spacing,
        runSpacing: style.runSpacing,
        children: children,
      );
    }

    return style.padding.wrap(result);
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

    final result = RenderLegendSimulation(
      context: context,
      renderExtent: constraints.maxWidth,
      spacing: style.spacing,
      maxLines: style.maxLines,
      items: children,
      ellipsisBuilder: ellipsisBuilder!,
      textScaler:
          MediaQuery.maybeOf(context)?.textScaler ?? const TextScaler.linear(1),
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    ).alignItems();

    if (result.alignedItemCount < children.length) {
      return [
        ...children.take(result.alignedItemCount),
        ellipsisBuilder!(children.length - result.alignedItemCount),
      ];
    } else {
      return children;
    }
  }
}

/// An immutable style that can be applied to [SegmentedBarLegend]s.
@immutable
class SegmentedBarLegendStyle {
  /// Creates a style for [SegmentedBarLegend]s.
  const SegmentedBarLegendStyle({
    this.maxLines,
    this.spacing = 4,
    this.runSpacing = 4,
    this.padding = const EdgeInsets.symmetric(
      vertical: 4,
      horizontal: 8,
    ),
  })  : assert(maxLines == null || maxLines > 0),
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
  int get hashCode => Object.hash(
        runtimeType,
        maxLines,
        spacing,
        runSpacing,
        padding,
      );
}
