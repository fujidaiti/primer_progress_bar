import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:primer_progress_bar/src/render_legend_simulation.dart';

@GenerateNiceMocks([MockSpec<BuildContext>()])
import 'render_legend_simulation_test.mocks.dart';

void main() {
  test("Test", () => null);
}

class _TestRenderLegendSimulation extends RenderLegendSimulation {
  _TestRenderLegendSimulation({
    required EllipsisBuilder ellipsisBuilder,
    required List<LegendItem> items,
  }) : super(
          context: MockBuildContext(),
          spacing: 0.0,
          maxLines: 1,
          renderExtent: 100,
          textDirection: TextDirection.ltr,
          textScaleFactor: 1.0,
          items: items,
          ellipsisBuilder: ellipsisBuilder,
        );

  @override
  double getItemExtent(LegendItem item) {
    throw UnimplementedError();
  }
}
