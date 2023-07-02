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
  });

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

  @override
  Widget build(BuildContext context) {
    final legendItems = segments.map(legendItemBuilder).toList();
    if (legendStyle.maxLines == null) {
      return _build(context, segments, legendItems);
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
        return _build(context, segments, ellipsizedLegendItems);
      },
    );
  }

  Widget _build(
    BuildContext context,
    List<Segment> segments,
    List<LegendItem> legendItems,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedBar(
          segments: segments,
          style: barStyle,
          maxTotalValue: maxTotalValue,
        ),
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
