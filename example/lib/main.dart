import 'dart:math';

import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

void main() {
  runApp(const MyApp());
}

final themeMode = ValueNotifier(Brightness.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget home;
    if (kIsWeb) {
      home = DeviceFrame(
        device: Devices.ios.iPhone13,
        screen: const Home(),
      );
    } else {
      home = const Home();
    }

    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, brightness, _) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            brightness: brightness,
          ),
          home: home,
        );
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final segments = const [
    Segment(
      color: Colors.green,
      value: 24,
      label: Text("Dart"),
      valueLabel: Text("24%"),
    ),
    Segment(
      color: Colors.lime,
      value: 11,
      label: Text("CSS"),
      valueLabel: Text("11%"),
    ),
    Segment(
      color: Colors.purple,
      value: 9,
      label: Text("HTML"),
      valueLabel: Text("9%"),
    ),
    Segment(
      color: Colors.lightBlue,
      value: 6,
      label: Text("Typescript"),
      valueLabel: Text("6%"),
    ),
    Segment(
      color: Colors.orange,
      value: 4,
      label: Text("Javascript"),
      valueLabel: Text("4%"),
    ),
    Segment(
      color: Colors.grey,
      value: 4,
      label: Text("Shell"),
      valueLabel: Text("4%"),
    ),
    Segment(
      color: Colors.indigo,
      value: 4,
      label: Text("Java"),
      valueLabel: Text("4%"),
    ),
    Segment(
      color: Colors.red,
      value: 4,
      label: Text("Objective-C"),
      valueLabel: Text("4%"),
    ),
    Segment(
      color: Colors.teal,
      value: 2,
      label: Text("Rust"),
      valueLabel: Text("2%"),
    ),
    Segment(
      color: Colors.brown,
      value: 2,
      label: Text("Swift"),
      valueLabel: Text("2%"),
    ),
  ];

  late final maxTotalValue = segments.fold(0, (acc, seg) => acc + seg.value);

  late int displaySegmentCount = segments.length ~/ 2;
  late double sliderValue = segments.length / 2;
  bool alwaysFillBar = false;
  bool limitLegendLines = false;

  @override
  Widget build(BuildContext context) {
    final progressBar = PrimerProgressBar(
      segments: segments.take(displaySegmentCount).toList(),
      maxTotalValue: alwaysFillBar ? null : maxTotalValue,
      legendStyle: limitLegendLines
          ? const SegmentedBarLegendStyle(maxLines: 2)
          : const SegmentedBarLegendStyle(maxLines: null),
      legendEllipsisBuilder: (truncatedItemCount) {
        final value = segments
            .skip(displaySegmentCount - truncatedItemCount)
            .take(truncatedItemCount)
            .fold(0, (accValue, segment) => accValue + segment.value);
        return LegendItem(
          segment: Segment(
            value: value,
            color: Colors.grey,
            label: const Text("Other"),
            valueLabel: Text("$value%"),
          ),
        );
      },
    );

    final options = [
      SwitchListTile(
        title: const Text("Dark Theme"),
        value: themeMode.value == Brightness.dark,
        onChanged: (turnedOn) {
          setState(() {
            themeMode.value = turnedOn ? Brightness.dark : Brightness.light;
          });
        },
      ),
      SwitchListTile(
        title: const Text("Always fill the entier bar"),
        value: alwaysFillBar,
        onChanged: (turnedOn) {
          setState(() => alwaysFillBar = turnedOn);
        },
      ),
      SwitchListTile(
        title: const Text("Limit the legend lines"),
        value: limitLegendLines,
        onChanged: (turnedOn) {
          setState(() => limitLegendLines = turnedOn);
        },
      ),
    ];

    final slider = SizedBox(
      height: 56,
      child: Slider(
        value: sliderValue,
        min: 0,
        max: segments.length.toDouble(),
        divisions: segments.length,
        label: "$displaySegmentCount segment(s)",
        onChanged: (value) {
          setState(() {
            sliderValue = value;
            displaySegmentCount = value.round();
          });
        },
      ),
    );

    final body = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: progressBar,
            ),
          ),
          ...options,
        ],
      ),
    );

    const minBodyHeight = 400.0;
    final bodyContainer = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minBodyHeight,
              maxHeight: max(
                constraints.maxHeight,
                minBodyHeight,
              ),
            ),
            child: body,
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: bodyContainer,
      ),
      bottomNavigationBar: BottomAppBar(
        child: slider,
      ),
    );
  }
}
