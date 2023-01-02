import 'package:flutter/material.dart';

import 'constants/constants.dart';
import 'features/event/bloc/bloc.dart';

class TravelModelItem extends ChangeNotifier {
  final String id;
  final String? name;
  Size? itemSize;
  final bool isOnTarget;
  DateTime? startTime;
  DateTime? endTime;

  void changeItemSize(bool isIncrease) {
    var newHeight = itemSize?.height ?? 0;

    if (isIncrease) {
      newHeight++;
      if (newHeight > maxEventHeight) {
        newHeight = maxEventHeight;
      }
    } else {
      newHeight--;
      if (newHeight < minEventHeight) {
        newHeight = minEventHeight;
      }
    }
    itemSize = Size(itemSize?.width ?? 0, newHeight);
    endTime = startTime!.add(Duration(minutes: fromHeightToMinute(newHeight)));

    notifyListeners();
  }

  void changeNextItemSize(bool isIncrease, DateTime? aboveTime) {
    if (startTime == null || endTime == null) return;
    var newHeight = itemSize?.height ?? 0;
    startTime = aboveTime?.add(const Duration(minutes: defaultWalkTime));

    if (isIncrease) {
      newHeight--;
      if (newHeight < minEventHeight) {
        newHeight = minEventHeight;
      }
    } else {
      newHeight++;
      if (newHeight > maxEventHeight) {
        newHeight = maxEventHeight;
      }
    }
    endTime = startTime!.add(Duration(minutes: fromHeightToMinute(newHeight)));
    itemSize = Size(itemSize?.width ?? 0, newHeight);
    notifyListeners();
  }

  void changeItemTime(DateTime? aboveTime) {
    startTime = aboveTime?.add(const Duration(minutes: defaultWalkTime));
    endTime = startTime!
        .add(Duration(minutes: fromHeightToMinute(itemSize?.height ?? 0)));
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
