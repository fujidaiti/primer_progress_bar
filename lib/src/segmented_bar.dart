import 'package:flutter/material.dart';
import 'package:primer_progress_bar/src/segment.dart';
import 'package:primer_progress_bar/src/utils/padding_wrap.dart';

const _fallbackBackgroundColor = Color(0xE7EBEFFF);

class SegmentedBar extends StatelessWidget {
  const SegmentedBar({
    super.key,
    this.segments = const [],
    this.style = const SegmentedBarStyle(),
    this.maxTotalValue,
  });

  final List<Segment> segments;
  final SegmentedBarStyle style;
  final int? maxTotalValue;

  @override
  Widget build(BuildContext context) {
    final totalValue =
        this.segments.fold(0, (acc, segment) => acc + segment.value);
    assert(maxTotalValue == null || totalValue <= maxTotalValue!);
    final spaceValue = maxTotalValue != null ? maxTotalValue! - totalValue : 0;

    final segmentData = [
      ...this.segments,
      if (spaceValue > 0)
        Segment(
          color: Colors.transparent,
          value: spaceValue,
        ),
    ];

    final halfGap = style.gap * 0.5;
    List<Widget> segments = [
      for (var index = 0; index < segmentData.length; ++index)
        Flexible(
          flex: segmentData[index].value,
          fit: FlexFit.tight,
          child: EdgeInsets.only(
            left: index == 0 ? 0 : halfGap,
            right: index == segmentData.length - 1 ? 0 : halfGap,
          ).wrap(
            SizedBox(
              height: style.size,
              child: ColoredBox(
                color: segmentData[index].color,
              ),
            ),
          ),
        ),
    ];

    return style.padding.wrap(
      SizedBox(
        height: style.size,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: _resolveBackgroundColor(context),
            shape: style.shape,
          ),
          child: Row(
            children: segments,
          ),
        ),
      ),
    );
  }

  Color _resolveBackgroundColor(BuildContext context) {
    if (style.backgroundColor != null) return style.backgroundColor!;
    final theme = Theme.of(context);
    if (theme.useMaterial3) return theme.colorScheme.surfaceVariant;
    return _fallbackBackgroundColor;
  }
}

class SegmentedBarStyle {
  const SegmentedBarStyle({
    this.backgroundColor,
    this.size = 10,
    this.gap = 3,
    this.shape = const StadiumBorder(),
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 6,
    ),
  })  : assert(size > 0),
        assert(gap > 0);

  final Color? backgroundColor;
  final double size;
  final double gap;
  final EdgeInsets padding;
  final ShapeBorder shape;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SegmentedBarStyle &&
          runtimeType == other.runtimeType &&
          size == other.size &&
          gap == other.gap &&
          backgroundColor == other.backgroundColor &&
          padding == other.padding &&
          shape == other.shape);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        size,
        gap,
        backgroundColor,
        padding,
        shape,
      );
}
