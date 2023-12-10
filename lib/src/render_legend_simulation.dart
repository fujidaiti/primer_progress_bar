import 'package:flutter/material.dart';
import 'package:primer_progress_bar/src/legend_item.dart';

const _labelEllipsis = "\u{2026}";

class RenderSimulationResult {
  const RenderSimulationResult({
    this.offset = 0,
    this.prevLineOffset = 0,
    this.currentLine = 1,
    this.alignedItemCount = 0,
  })  : assert(offset >= 0),
        assert(prevLineOffset >= 0),
        assert(currentLine >= 1),
        assert(alignedItemCount >= 0);

  final double offset;
  final double prevLineOffset;
  final int currentLine;
  final int alignedItemCount;

  RenderSimulationResult copyWith({
    double? offset,
    double? prevLineOffset,
    int? currentLine,
    int? alignedItemCount,
  }) =>
      RenderSimulationResult(
        offset: offset ?? this.offset,
        prevLineOffset: prevLineOffset ?? this.prevLineOffset,
        currentLine: currentLine ?? this.currentLine,
        alignedItemCount: alignedItemCount ?? this.alignedItemCount,
      );
}

typedef EllipsisBuilder = LegendItem Function(int truncatedItemCount);

class RenderLegendSimulation {
  RenderLegendSimulation({
    required this.context,
    required this.spacing,
    required this.maxLines,
    required this.renderExtent,
    required this.items,
    required this.textDirection,
    required this.textScaler,
    required this.ellipsisBuilder,
  });

  final BuildContext context;
  final double spacing;
  final int? maxLines;
  final double renderExtent;
  final List<LegendItem> items;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final EllipsisBuilder ellipsisBuilder;

  bool isOverflowed(RenderSimulationResult context) =>
      maxLines != null && context.currentLine > maxLines!;

  bool areAllItemsAligned(RenderSimulationResult context) =>
      context.alignedItemCount == items.length;

  RenderSimulationResult alignItem(
      LegendItem item, RenderSimulationResult context) {
    final itemExtent = getItemExtent(item);
    assert(itemExtent <= renderExtent);

    final newOffset = context.offset == 0
        ? context.offset + itemExtent
        : context.offset + spacing + itemExtent;

    if (newOffset <= renderExtent) {
      return context.copyWith(
        offset: newOffset,
        alignedItemCount: context.alignedItemCount + 1,
      );
    } else {
      return context.copyWith(
        offset: itemExtent,
        prevLineOffset: context.offset,
        currentLine: context.currentLine + 1,
        alignedItemCount: context.alignedItemCount + 1,
      );
    }
  }

  @visibleForTesting
  RenderSimulationResult truncateLastAlignedItem(
      RenderSimulationResult context) {
    assert(0 < context.alignedItemCount &&
        context.alignedItemCount <= items.length);

    final lastItem = items[context.alignedItemCount - 1];
    final itemExtent = getItemExtent(lastItem);
    assert(itemExtent <= context.offset);

    if (context.offset == itemExtent && context.currentLine > 1) {
      return context.copyWith(
        offset: context.prevLineOffset,
        prevLineOffset: 0,
        currentLine: context.currentLine - 1,
        alignedItemCount: context.alignedItemCount - 1,
      );
    } else {
      return context.copyWith(
        offset: context.offset - itemExtent,
        alignedItemCount: context.alignedItemCount - 1,
      );
    }
  }

  @visibleForTesting
  RenderSimulationResult alignItemsUntilOverflow() {
    var result = const RenderSimulationResult();
    while (!isOverflowed(result) && !areAllItemsAligned(result)) {
      assert(result.alignedItemCount < items.length);
      final nextItem = items[result.alignedItemCount];
      result = alignItem(nextItem, result);
    }
    return result;
  }

  @visibleForTesting
  bool canPlaceEllipsis(RenderSimulationResult context) {
    assert(context.alignedItemCount <= items.length);
    final ellipsis = ellipsisBuilder(items.length - context.alignedItemCount);
    final ellipsisExtent = getItemExtent(ellipsis);
    assert(ellipsisExtent <= renderExtent);
    return !isOverflowed(alignItem(ellipsis, context));
  }

  @visibleForTesting
  RenderSimulationResult ellipsize(RenderSimulationResult context) {
    if (!isOverflowed(context)) return context;

    var ctx = context;
    do {
      ctx = truncateLastAlignedItem(ctx);
    } while (!canPlaceEllipsis(ctx));
    return ctx;
  }

  final _cachedItemExtends = <LegendItem, double>{};

  @visibleForTesting
  double getItemExtent(LegendItem item) {
    final cachedExtent = _cachedItemExtends[item];
    if (cachedExtent != null) return cachedExtent;
    final extent = computeItemExtent(item);
    _cachedItemExtends[item] = extent;
    return extent;
  }

  @visibleForTesting
  double computeItemExtent(LegendItem item) {
    final itemStyle = item.resolveStyle(context);
    final labelSize = computeTextExtent(
      item.segment.label?.data,
      item.segment.label?.style ?? itemStyle.labelStyle,
      itemStyle.maxLabelSize,
    );
    final valueLabelSize = computeTextExtent(
      item.segment.valueLabel.data,
      item.segment.valueLabel.style ?? itemStyle.valueLabelStyle,
      itemStyle.maxLabelSize,
    );

    return labelSize +
        valueLabelSize +
        itemStyle.handleSize +
        itemStyle.padding.horizontal +
        itemStyle.handlePadding.horizontal +
        itemStyle.labelPadding.horizontal +
        itemStyle.valueLabelPadding.horizontal;
  }

  @visibleForTesting
  double computeTextExtent(String? text, TextStyle? style, double maxExtent) {
    final result = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      ellipsis: _labelEllipsis,
      textScaler: textScaler,
      textDirection: textDirection,
    )..layout(maxWidth: maxExtent);
    return result.size.width;
  }

  RenderSimulationResult alignItems() => ellipsize(alignItemsUntilOverflow());
}
