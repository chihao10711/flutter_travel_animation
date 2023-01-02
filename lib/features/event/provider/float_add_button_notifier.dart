import 'package:flutter/material.dart';

class FloatAddButtonNotifier extends ChangeNotifier {
  double defaultPositionX = 0;
  double defaultPositionY = 0;
  double floatingActionSize = 50;

  double positionX;
  double positionY;
  bool isOnTarget;

  FloatAddButtonNotifier({
    this.positionX = 0,
    this.positionY = 0,
    this.isOnTarget = false,
  });

  void init(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
    defaultPositionX = (screenSize.width - floatingActionSize) / 2;
    defaultPositionY =
        screenSize.height - floatingActionSize - viewPadding.bottom;
    positionX = defaultPositionX;
    positionY = defaultPositionY;
  }

  void changeOnTarget(bool value) {
    isOnTarget = value;
    notifyListeners();
  }

  void onDragUpdate(DragUpdateDetails details) {
    positionX = positionX + details.delta.dx;
    positionY = positionY + details.delta.dy;
    notifyListeners();
  }

  void onDragEnd() {
    positionX = defaultPositionX;
    positionY = defaultPositionY;
    notifyListeners();
  }
}
