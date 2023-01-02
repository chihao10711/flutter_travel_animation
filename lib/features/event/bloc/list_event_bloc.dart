import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_animation/travel_item_model.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/config.dart';
import 'bloc.dart';

class ListEventBloc extends Bloc<ListEventEvent, ListEventState> {
  ListEventBloc(this.context) : super(const ListEventState()) {
    on<AddNewEvent>(_addNewEvent);
    on<RemoveEvent>(_removeEvent);
    on<TravelItemMove>(_onTravelItemMove);
    on<ChangePositionEvent>(_changePositionEvent);
    on<ChangeSizeEvent>(_changeSizeEvent);
  }

  final BuildContext context;

  Size get travelItemSizeDefault =>
      Size(MediaQuery.of(context).size.width * 0.75, defaultEventHeight);

  void _addNewEvent(AddNewEvent event, Emitter<ListEventState> emit) {
    List<TravelModelItem> data = List.from(state.listEvent);
    int indexInsert = event.currentTargetIndex + 1;
    DateTime? aboveTime = data.isEmpty
        ? null
        : _eventItemById(data[min(indexInsert - 1, data.length)].id)?.endTime;
    DateTime startTime =
        aboveTime?.add(const Duration(minutes: defaultWalkTime)) ??
            DateTime.now();
    DateTime endTime = startTime.add(
        Duration(minutes: fromHeightToMinute(travelItemSizeDefault.height)));
    data.insert(
      indexInsert,
      TravelModelItem(
        const Uuid().v4(),
        name: "Event ${data.length + 1}",
        itemSize: travelItemSizeDefault,
        startTime: startTime,
        endTime: endTime,
      ),
    );
    emit(state.copyWith(listEvent: data));
  }

  void _onTravelItemMove(TravelItemMove event, Emitter<ListEventState> emit) {
    TravelModelItem? travelItemOnMove = _eventItemById(event.eventId);
    emit(state.copyWith(
      travelItemOnMove: travelItemOnMove,
    ));
  }

  void _removeEvent(RemoveEvent event, Emitter<ListEventState> emit) {
    List<TravelModelItem> data = List.from(state.listEvent);
    data.removeAt(_indexEventById(event.eventId));
    emit(
      state.copyWith(
        listEvent: data,
        travelItemOnMove: null,
      ),
    );
  }

  void _changePositionEvent(
      ChangePositionEvent event, Emitter<ListEventState> emit) {
    if (state.travelItemOnMove == null) return;
    List<TravelModelItem> data = List.from(state.listEvent);
    int indexMoveItem = _indexEventById(state.travelItemOnMove?.id);
    data.removeAt(indexMoveItem);
    int indexAccept = _indexEventById(event.eventIdAccept, data);
    data.insert(min(data.length, indexAccept + 1), state.travelItemOnMove!);

    emit(
      state.copyWith(
        listEvent: data,
        travelItemOnMove: null,
      ),
    );
  }

  void _changeSizeEvent(ChangeSizeEvent event, Emitter<ListEventState> emit) {
    TravelModelItem? item = _eventItemById(event.eventId);
    List<TravelModelItem> data =
        List.from(state.listEvent.slice(_indexEventById(event.eventId) + 1));
    TravelModelItem? nextItem = data.isNotEmpty ? data.first : null;
    item?.changeItemSize(event.isIncrease);
    if ((item?.itemSize?.height ?? 0) < maxEventHeight ||
        (item?.itemSize?.height ?? 0) > minEventHeight) {
      nextItem?.changeNextItemSize(event.isIncrease, item?.endTime);
      data.forEachIndexed((index, element) {
        if (element.id != nextItem?.id) {
          element.changeItemTime(data[index - 1].endTime);
        }
      });
    }
  }

  int _indexEventById(String? eventId, [List<TravelModelItem>? otherList]) {
    return (otherList ?? state.listEvent).indexWhere((e) => e.id == eventId);
  }

  TravelModelItem? _eventItemById(String eventId) {
    return state.listEvent.firstWhereOrNull((e) => e.id == eventId);
  }
}

int fromHeightToMinute(double height) {
  return ((height * defaultEventTime) / defaultEventHeight).round();
}
