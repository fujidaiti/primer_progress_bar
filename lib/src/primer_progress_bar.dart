import 'dart:math';

import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

typedef LegendItemBuilder = LegendItem Function(Segment segment);

LegendItem _defaultLegendItemBuilder(Segment segment) {
  return LegendItem(segment: segment);
}

class PrimerProgressBar extends StatelessWidget {
  const PrimerProgressBar({
    super.key,
    required this.segments,
    this.maxTotalValue,
    this.legendEllipsisBuilder,
    this.barStyle = const SegmentedBarStyle(),
    this.legendStyle = const SegmentedBarLegendStyle(),
    this.legendItemBuilder = _defaultLegendItemBuilder,
  });

  final List<Segment> segments;
  final int? maxTotalValue;

  /// {@macro primer_progress_bar.SegmentedBarLegend.ellipsisBuilder}
  final EllipsisBuilder? legendEllipsisBuilder;

  final SegmentedBarStyle barStyle;
  final SegmentedBarLegendStyle legendStyle;
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
