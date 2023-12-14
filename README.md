[![Pub](https://img.shields.io/pub/v/primer_progress_bar.svg?logo=flutter&color=blue)](https://pub.dev/packages/primer_progress_bar) [![Pub Popularity](https://img.shields.io/pub/popularity/primer_progress_bar)](https://pub.dev/packages/primer_progress_bar) [![Demo](https://img.shields.io/badge/Demo-try%20it%20on%20web-blueviolet)](https://fujidaiti.github.io/primer_progress_bar/#/) [![Docs](https://img.shields.io/badge/-API%20Reference-orange)](https://pub.dev/documentation/primer_progress_bar/latest/)

<br/>

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/7acaac75-89ca-4f1f-aad5-af8c2656a1b0" width="450"/>
<h3 align="center">PrimerProgressBar</h3>
  <p align="center">
    Unoffcial Flutter implementation of the progress bar <br />defined in <a href="https://primer.style/design/components/progress-bar">GitHub Primer Design System</a>.
    <br />
    <br />
    <a href="https://pub.dev/documentation/primer_progress_bar/latest/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://fujidaiti.github.io/primer_progress_bar/#/">View Demo</a>
    ·
    <a href="https://github.com/fujidaiti/primer_progress_bar/issues?q=is%3Aopen+label%3Abug+sort%3Aupdated-desc">Report Bug</a>
    ·
    <a href="https://github.com/fujidaiti/primer_progress_bar/issues?q=is%3Aopen+label%3Aenhancement+sort%3Aupdated-desc">Request Feature</a>
  </p>
</div>

<br/>

<br/>

## Announcement

### Dec 14, 2023

Version `0.4.0` has been released. It requires the Flutter SDK version `3.16.0` or higher. If you are using an older sdk, please use version `0.3.0` or lower.

<br/>

## Installation

Add this package to your `pubspec.yaml`.

```yaml
dependencies:
  primer_progress_bar: ^0.4.0
```

Alternatively, you can use `flutter` command like:

```shell
flutter pub add primer_progress_bar
```

<br/>

## Getting Started

Define segments to be displayed in the progress bar using `Segment`:

```dart
List<Segment> segments = [
  Segment(value: 80, color: Colors.purple, label: Text("Done")),
  Segment(value: 14, color: Colors.deepOrange, label: Text("In progress")),
  Segment(value: 6, color: Colors.green, label: Text("Open")),
];
```

Then, in your `build` method:

```dart
Widget build(BuildContext context) {
  final progressBar = PrimerProgressBar(segments: segments);
  return Scaffold(
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: progressBar,
      ),
    ),
  );
}
```

Finally you will get a nice progress bar :sunglasses:

<p align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/9f4b30d0-f173-4f06-98e4-25195d48aefc" width="450" />
<p />
<br/>

## Usage

### Components

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/e9e831d8-194e-4193-846c-069a06a791cb" width="450"/>
</div>


The [Primer](https://github.com/primer)'s progress bar consists of 3 components: the *segmented bar*, the *legend*, and the *legend item*s. The progress bar can display multiple colored segments in a horizontal bar, and the legend is placed below the bar with the aligned descriptions of each segment.

You can define a segment using [Segment](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/Segment-class.html):

```dart
Segment(color: Colors.lightBlue, value: 24, 
        label: Text("Dart"), valueLabel: Text("24%"));
```

The `value` describes the amount of space the segment occupies in the entier bar (see [Proportion of segments](#proportions-of-segment-sizes) section), and the `label` and `valueLabel` are the texts used in the legend to explain what the segment means.

The [PrimerProgressBar](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/PrimerProgressBar-class.html) integrates these 3 components and provides a simple interface to create a chart like the one above, so it should fit to general usecases. However, since each component is modulated, it is easy to use them individually for your own purposes. See [SegmentedBar](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/SegmentedBar-class.html), [SegmentedBarLegend](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/SegmentedBarLegend-class.html), [LegendItem](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/LegendItem-class.html) for more details usage of each component.

<br/>

### Proportions of segment sizes

The proportion of each segment size to the bar length is determined by dividing the [maxTotalValue](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/PrimerProgressBar/maxTotalValue.html) according to the `value`s of the segments.  For example, if you want to display the percentage of each programming language used in a project,  the `value` could be the percentage for a language and the `maxTotalValue` is 100.

```dart
PrimerProgressBar(segments: segments, maxTotalValue: 100);
```

Then, the size of a segment with a `value` of 24, for example, should be the 24% of the bar length.

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/761edbd1-66ce-453a-bb81-9ee1747c0d17" width="450"/>
</div>


If `maxTotalValue` is not specified, it is implicitly set to the sum of the `value`s of the segments, resulting in the segments always filling the entire bar.

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/0f75a9ce-d85a-44cf-8c80-4d3f167b96fc" width="450" />
</div>
<br/>

### Limit legend lines

By default, the legend tries to align all the items while growing in vertical direction.  This is fine if the legend has a relatively small number of items to display, but if you have a large number of segments, you will end up with a verbose legend.

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/d8ba4d22-232c-4095-b338-57c776d3f97d" width="450" />
</div>


For these cases, the legend provides a way to limit the number of lines in which the items are aligned. The following example limits the number of lines in the legend to 2.

```dart
PrimerProgressBar(
  segments: segments,
  // Limits the number of the lines in the legend to 2.
  legendStyle: const SegmentedBarLegendStyle(maxLines: 2),
  // A builder of a legend item that represent the overflowed items.
  // `truncatedItemCount` is the number of items that is overflowed.
  ellipsisBuilder: (truncatedItemCount) {
    final value = segments
        .skip(segments.length - truncatedItemCount)
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
```

If the legend failed to align some items within the given line limit, the overflowing items are not shown and instead an item that is created by [ellipsisBuilder](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/PrimerProgressBar/legendEllipsisBuilder.html) (called an *ellipsis*) is displayed as the last item in the legend.

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/92a9c0f8-fe7c-4da6-bdd3-953048c07413" width="450" />
</div>

You can use [DefaultLegendEllipsisBuilder](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/DefaultLegendEllipsisBuilder-class.html) as a shorthand for the above example:

```dart
PrimerProgressBar(
  segments: segments,
  legendEllipsisBuilder: DefaultLegendEllipsisBuilder(
    segments: segments,
    color: Colors.grey,
    label: const Text("Other"),
    // [value] is the sum of [Segment.value]s for each legend item that is overflowed
    valueLabelBuilder: (value) => Text("$value%"),
  ),
);
```

<br/>


### Styling

The appearace of the 3 components are configurable with [SegmentedBarStyle](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/SegmentedBarStyle-class.html), [SegmentedBarLegendStyle](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/SegmentedBarLegendStyle-class.html), [LegendItemStyle](https://pub.dev/documentation/primer_progress_bar/latest/primer_progress_bar/LegendItemStyle-class.html), respectively. The documentation will provide detailed descriptions of each class and its properties, while our focus here is on briefly explaining the terminology used in the documentation.

#### Segmented bar

- **Gap** : A space between adjacent segments.
- **Background** : The color of the bar itself.

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/21adb32c-9dd9-4ef2-9f02-c0cbf78b4709" width="450" />
</div>

#### Legend item

- **Handle** : A small shape filled with the segment's color and placed at the start of the item.
- **Label** : A text explaining what the segment means.
- **Value label** : A formatted `value` of the segment.

<div align="center">
<img src="https://github.com/fujidaiti/primer_progress_bar/assets/68946713/421eb480-6b93-48f9-bcdf-15ebb95390c2" width="450" />
</div>

<br/>

## TODO

- [ ] Add tests
- [ ] Support mouse hovering
- [ ] Refactor with Dart3

<br/>

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<br/>

## Thanks

* [Best-README-Template](https://github.com/othneildrew/Best-README-Template/tree/master) by [@othneildrew](https://github.com/othneildrew)
* [Primer Design System](https://github.com/primer) by [@github](https://github.com/github)
