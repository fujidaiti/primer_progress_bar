import 'dart:math';

import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

/// Signature of callbacks that create a [LegendItem] from a [Segment].
typedef LegendItemBuilder = LegendItem Function(Segment segment);

LegendItem _defaultLegendItemBuilder(Segment segment) {
  return LegendItem(segment: segment);
}

/// A simple chart that can be used to show multiple colored segments in a row with a legend.
///
/// This is an implementation of the progress bar defined in
/// [GitHub Primer Design System](https://www.primer.style/design/components/progress-bar).
class PrimerProgressBar extends StatelessWidget {
  /// Create a progress bar with a legend from [Segment]s.
  ///
  /// {@macro primer_progress_bar.SegmentedBar.maxTotalValue.caveat}
  const PrimerProgressBar({
    super.key,
    required this.segments,
    this.maxTotalValue,
    this.legendEllipsisBuilder,
    this.barStyle = const SegmentedBarStyle(),
    this.legendStyle = const SegmentedBarLegendStyle(),
    this.legendItemBuilder = _defaultLegendItemBuilder,
    this.showLegend = true,
  }) : assert(maxTotalValue == null || maxTotalValue > 0);

  /// A list of [Segment] to be displayed in the progress bar.
  final List<Segment> segments;

  /// {@macro primer_progress_bar.SegmentedBar.maxTotalValue}
  final int? maxTotalValue;

  /// {@macro primer_progress_bar.SegmentedBarLegend.ellipsisBuilder}
  final EllipsisBuilder? legendEllipsisBuilder;

  /// The style applied to the progress bar.
  final SegmentedBarStyle barStyle;

  /// The style applied to the legend.
  final SegmentedBarLegendStyle legendStyle;

  /// A builder that creates a [LegendItems] from a [Segment] for the legend.
  final LegendItemBuilder legendItemBuilder;

  /// Whether to display the legend.
  ///
  /// If `true`, the legend will be shown. If `false`, the legend will be hidden.
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final legendItems = segments.map(legendItemBuilder).toList();
    if (legendStyle.maxLines == null) {
      return _build(context, segments, legendItems, showLegend);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final legendMaxWidth =
            constraints.maxWidth - legendStyle.padding.horizontal;
        final ellipsizedLegendItems = SegmentedBarLegend(
          ellipsisBuilder: legendEllipsisBuilder,
          style: legendStyle,
          children: legendItems,
        ).ellipsizeItems(
          context,
          constraints.copyWith(
            maxWidth: max(legendMaxWidth, 0),
          ),
        );
        final segments = [
          for (final item in ellipsizedLegendItems) item.segment
        ];
        return _build(context, segments, ellipsizedLegendItems, showLegend);
      },
    );
  }

  Widget _build(BuildContext context, List<Segment> segments,
      List<LegendItem> legendItems, bool showLegend) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedBar(
          segments: segments,
          style: barStyle,
          maxTotalValue: maxTotalValue,
        ),
        if (showLegend)
          SegmentedBarLegend(
            style: SegmentedBarLegendStyle(
              maxLines: null,
              spacing: legendStyle.spacing,
              runSpacing: legendStyle.runSpacing,
              padding: legendStyle.padding,
            ),
            ellipsisBuilder: legendEllipsisBuilder,
            children: legendItems,
          ),
      ],
    );
  }
}
