import 'package:flutter/material.dart';

mixin OffsetToAlignmentMixin {
  final ValueNotifier<Alignment> alignment = ValueNotifier(Alignment.center);

  void offsetToAlignmentMixin(BuildContext context, Offset offsetWidget) {
    RenderBox renderBox = (context.findRenderObject() as RenderBox);
    Offset localTouchPosition = renderBox.globalToLocal(offsetWidget);
    double width = renderBox.size.width;
    double height = renderBox.size.height;
    var alignmentX = (localTouchPosition.dx - width / 2) / (width / 2);
    var alignmentY = (localTouchPosition.dy - height / 2) / (height / 2);
    alignment.value = Alignment(alignmentX, alignmentY);
  }
}
