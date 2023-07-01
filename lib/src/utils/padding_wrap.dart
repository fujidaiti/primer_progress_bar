import 'package:flutter/material.dart';

extension PaddingWrap on EdgeInsets {
  Widget wrap(Widget child) => this == EdgeInsets.zero
      ? child
      : Padding(
          padding: this,
          child: child,
        );
}
