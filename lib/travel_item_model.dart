import 'package:flutter/material.dart';

class TravelModelItem {
  final String id;
  final Size? itemSize;
  final bool isOnTarget;

  TravelModelItem(
    this.id, {
    this.isOnTarget = false,
    this.itemSize,
  });

  TravelModelItem copyWith({
    String? id,
    Size? itemSize,
    bool? isOnTarget,
  }) {
    return TravelModelItem(
      id ?? this.id,
      itemSize: itemSize ?? this.itemSize,
      isOnTarget: isOnTarget ?? this.isOnTarget,
    );
  }
}
