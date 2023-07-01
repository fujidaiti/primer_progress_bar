import 'package:flutter/material.dart';
import 'package:primer_progress_bar/src/legend_item.dart';
import 'package:primer_progress_bar/src/render_legend_simulation.dart';
import 'package:primer_progress_bar/src/utils/padding_wrap.dart';

class SegmentedBarLegend extends StatelessWidget {
  const SegmentedBarLegend({
    super.key,
    this.children = const [],
    this.style = const SegmentedBarLegendStyle(),
    this.ellipsisBuilder,
  });

  final List<LegendItem> children;
  final SegmentedBarLegendStyle style;

  /// {@template primer_progress_bar.SegmentedBarLegend.ellipsisBuilder}
  /// A builder of a [LegendItem] that represents truncated legend items.
  ///
  /// If the number of lines in the legend is limited, this property must not be null.
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
      textScaleFactor: MediaQuery.maybeOf(context)?.textScaleFactor ?? 1.0,
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

@immutable
class SegmentedBarLegendStyle {
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

  final int? maxLines;
  final double spacing;
  final double runSpacing;
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
