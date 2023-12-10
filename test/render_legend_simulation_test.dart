import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:primer_progress_bar/src/render_legend_simulation.dart';

@GenerateNiceMocks([MockSpec<BuildContext>()])
import 'render_legend_simulation_test.mocks.dart';

const _testRenderExtent = 300.0;
const _testCharWidth = 10.0;
const _testEllipsisLength = 50;

void main() {
  group("alignItem", () {
    test("should align items properly", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 2,
        items: [
          _stringOfLength(200),
          _stringOfLength(100),
          _stringOfLength(150),
        ],
      );
      var context = const RenderSimulationResult();

      context = sim.alignItem(sim.items[0], context);
      expect(
        context,
        _resultMatcher(
          const RenderSimulationResult(
            offset: 200,
            prevLineOffset: 0,
            currentLine: 1,
            alignedItemCount: 1,
          ),
        ),
      );

      context = sim.alignItem(sim.items[1], context);
      expect(
        context,
        _resultMatcher(
          const RenderSimulationResult(
            offset: 300,
            prevLineOffset: 0,
            currentLine: 1,
            alignedItemCount: 2,
          ),
        ),
      );

      context = sim.alignItem(sim.items[2], context);
      expect(
        context,
        _resultMatcher(
          const RenderSimulationResult(
            offset: 150,
            prevLineOffset: 300,
            currentLine: 2,
            alignedItemCount: 3,
          ),
        ),
      );
    });
  });

  group("areAllItemsAligned", () {
    test("should return true after all items are aligned", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 1,
        items: [_stringOfLength(50), _stringOfLength(100)],
      );
      var context = const RenderSimulationResult();

      context = sim.alignItem(sim.items[0], context);
      expect(sim.areAllItemsAligned(context), false);

      context = sim.alignItem(sim.items[1], context);
      expect(sim.areAllItemsAligned(context), true);
    });
  });

  group("isOverflowed", () {
    test("should return false if no items are aligned", () {
      final sim = _TestRenderLegendSimulation(maxLines: 1, items: []);
      expect(sim.isOverflowed(const RenderSimulationResult()), false);
    });

    test("should return true if some items are overflowed", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 1,
        items: [_stringOfLength(250), _stringOfLength(100)],
      );
      var context = const RenderSimulationResult();
      context = sim.alignItem(sim.items[0], context);
      expect(sim.isOverflowed(context), false);
      context = sim.alignItem(sim.items[1], context);
      expect(sim.isOverflowed(context), true);
    });
  });

  group("truncateLastAlignedItem", () {
    test("should properly remove the last aligned item", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 2,
        items: [_stringOfLength(200), _stringOfLength(100)],
      );
      var context = const RenderSimulationResult();

      context = sim.alignItem(sim.items[0], context);
      context = sim.alignItem(sim.items[1], context);
      context = sim.truncateLastAlignedItem(context);

      expect(
        context,
        _resultMatcher(const RenderSimulationResult(
          offset: 200,
          prevLineOffset: 0,
          currentLine: 1,
          alignedItemCount: 1,
        )),
      );
    });

    test("should remove the line that is no longer needed", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 2,
        items: [
          _stringOfLength(200),
          _stringOfLength(100),
          _stringOfLength(100),
        ],
      );
      var context = const RenderSimulationResult();

      context = sim.alignItem(sim.items[0], context);
      context = sim.alignItem(sim.items[1], context);
      context = sim.alignItem(sim.items[2], context);
      context = sim.truncateLastAlignedItem(context);

      expect(
        context,
        _resultMatcher(const RenderSimulationResult(
          offset: 300,
          prevLineOffset: 0,
          currentLine: 1,
          alignedItemCount: 2,
        )),
      );
    });
  });

  group("alignItemsUntilOverflow", () {
    test("should align all items if there is enough space to place them", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 1,
        items: [
          _stringOfLength(200),
          _stringOfLength(90),
        ],
      );

      expect(
        sim.alignItemsUntilOverflow(),
        _resultMatcher(const RenderSimulationResult(
          offset: 290,
          prevLineOffset: 0,
          currentLine: 1,
          alignedItemCount: 2,
        )),
      );
    });

    test("should align items sequentially until one of the items overflows",
        () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 1,
        items: [
          _stringOfLength(200),
          _stringOfLength(90),
          _stringOfLength(100),
          _stringOfLength(100),
        ],
      );

      expect(
        sim.alignItemsUntilOverflow(),
        _resultMatcher(const RenderSimulationResult(
          offset: 100,
          prevLineOffset: 290,
          currentLine: 2,
          alignedItemCount: 3,
        )),
      );
    });
  });

  group("canPlaceEllipsis", () {
    test("should return true if there is enough space to place an ellipsis",
        () {
      final sim = _TestRenderLegendSimulation(
          maxLines: 1, items: [_stringOfLength(200)]);

      var context = const RenderSimulationResult();
      context = sim.alignItem(sim.items[0], context);

      expect(sim.canPlaceEllipsis(context), true);
    });

    test("should return false if there is no space to place an ellipsis", () {
      final sim = _TestRenderLegendSimulation(
          maxLines: 1, items: [_stringOfLength(290)]);

      var context = const RenderSimulationResult();
      context = sim.alignItem(sim.items[0], context);

      expect(sim.canPlaceEllipsis(context), false);
    });
  });

  group("ellipsize", () {
    test("should do nothing if the items are not overflowed", () {
      final sim = _TestRenderLegendSimulation(
          maxLines: 1, items: [_stringOfLength(100)]);

      final before =
          sim.alignItem(sim.items[0], const RenderSimulationResult());
      final after = sim.ellipsize(before);

      expect(after, _resultMatcher(before));
    });

    test("should remove overflowed items so that an ellipsis can be placed",
        () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 2,
        items: [
          _stringOfLength(290),
          _stringOfLength(250),
          _stringOfLength(50),
          _stringOfLength(100),
        ],
      );

      var context = const RenderSimulationResult();
      context = sim.alignItem(sim.items[0], context);
      context = sim.alignItem(sim.items[1], context);
      context = sim.alignItem(sim.items[2], context);
      context = sim.alignItem(sim.items[3], context);

      expect(
        context,
        _resultMatcher(const RenderSimulationResult(
          offset: 100,
          prevLineOffset: 300,
          currentLine: 3,
          alignedItemCount: 4,
        )),
      );

      context = sim.ellipsize(context);

      expect(
        context,
        _resultMatcher(const RenderSimulationResult(
          offset: 250,
          prevLineOffset: 0,
          currentLine: 2,
          alignedItemCount: 2,
        )),
      );
    });
  });

  group("alignItems", () {
    test("should align all items if there are enough space to place them", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 2,
        items: [
          _stringOfLength(290),
          _stringOfLength(100),
          _stringOfLength(100),
        ],
      );

      expect(
        sim.alignItems(),
        _resultMatcher(const RenderSimulationResult(
          offset: 200,
          prevLineOffset: 290,
          currentLine: 2,
          alignedItemCount: 3,
        )),
      );
    });

    test(
        "should align some items with an ellipsis "
        "if there are no enough space to place them all", () {
      final sim = _TestRenderLegendSimulation(
        maxLines: 2,
        items: [
          _stringOfLength(290),
          _stringOfLength(100),
          _stringOfLength(100),
          _stringOfLength(200),
        ],
      );

      final result = sim.alignItems();
      expect(
        result,
        _resultMatcher(const RenderSimulationResult(
          offset: 200,
          prevLineOffset: 0,
          currentLine: 2,
          alignedItemCount: 3,
        )),
      );

      final availableSpaceForEllipsis = _testRenderExtent - result.offset;
      expect(availableSpaceForEllipsis >= _testEllipsisLength, true);
    });
  });
}

TypeMatcher<RenderSimulationResult> _resultMatcher(
  RenderSimulationResult result,
) {
  return isA<RenderSimulationResult>()
      .having((r) => r.offset, "offset", result.offset)
      .having((r) => r.prevLineOffset, "prevLineOffset", result.prevLineOffset)
      .having((r) => r.currentLine, "currentLine", result.currentLine)
      .having((r) => r.alignedItemCount, "alignedItemCount",
          result.alignedItemCount);
}

double _textWidth(String text) => text.length * _testCharWidth;

String _stringOfLength(int length) {
  assert(length % _testCharWidth == 0);
  return "a" * (length ~/ _testCharWidth);
}

class _TestRenderLegendSimulation extends RenderLegendSimulation {
  _TestRenderLegendSimulation({
    required int maxLines,
    required List<String> items,
  }) : super(
          context: MockBuildContext(),
          textDirection: TextDirection.ltr,
          renderExtent: _testRenderExtent,
          spacing: 0.0,
          textScaler: const TextScaler.linear(1.0),
          maxLines: maxLines,
          ellipsisBuilder: (_) => LegendItem(
            segment: Segment(
              value: 1,
              color: Colors.grey,
              label: Text(_stringOfLength(_testEllipsisLength)),
              valueLabel: const Text(""),
            ),
          ),
          items: [
            for (final text in items)
              LegendItem(
                segment: Segment(
                  value: 1,
                  color: Colors.grey,
                  label: Text(text),
                  valueLabel: const Text(""),
                ),
              ),
          ],
        );

  @override
  double getItemExtent(LegendItem item) {
    final label = item.segment.label?.data ?? "";
    return _textWidth(label);
  }
}
