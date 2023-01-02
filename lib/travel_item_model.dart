import 'package:flutter/material.dart';

class TravelModelItem extends ChangeNotifier {
  final String id;
  final String? name;
  Size? itemSize;
  final bool isOnTarget;
  DateTime? startTime;
  DateTime? endTime;

  void changeItemSize(bool isIncrease, {required VoidCallback onChangeSize}) {
    var newHeight = itemSize?.height ?? 0;
    int _time = 0;

    if (isIncrease) {
      newHeight++;
      _time++;
      if (newHeight > 100) {
        newHeight = 100;
        return;
      }
      endTime = endTime?.add(Duration(minutes: _time));
      itemSize = Size(itemSize?.width ?? 0, newHeight);
    } else {
      newHeight--;
      _time--;

      if (newHeight < 50) {
        newHeight = 50;
        return;
      }
      endTime = endTime?.add(Duration(minutes: _time));
      itemSize = Size(itemSize?.width ?? 0, newHeight);
    }
    onChangeSize.call();
    notifyListeners();
  }

  void changeNextItem(bool isIncrease) {
    var newHeight = itemSize?.height ?? 0;
    int _time = 0;
    if (isIncrease) {
      newHeight--;
      _time++;

      if (newHeight < 50) {
        newHeight = 50;
        return;
      }
      itemSize = Size(itemSize?.width ?? 0, newHeight);
      startTime = startTime?.add(Duration(minutes: _time));
    } else {
      newHeight++;
      _time--;
      if (newHeight > 100) {
        newHeight = 100;
        return;
      }
      itemSize = Size(itemSize?.width ?? 0, newHeight);
      startTime = startTime?.add(Duration(minutes: _time));
    }
    notifyListeners();
  }

  TravelModelItem(
    this.id, {
    this.name,
    this.isOnTarget = false,
    this.itemSize,
    this.startTime,
    this.endTime,
  });

  TravelModelItem copyWith({
    String? id,
    String? name,
    Size? itemSize,
    bool? isOnTarget,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return TravelModelItem(
      id ?? this.id,
      name: name ?? this.name,
      itemSize: itemSize ?? this.itemSize,
      isOnTarget: isOnTarget ?? this.isOnTarget,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
