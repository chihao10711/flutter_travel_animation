import 'package:travel_animation/travel_item_model.dart';

class ListEventState {
  final List<TravelModelItem> listEvent;
  final TravelModelItem? travelItemOnMove;

  const ListEventState({this.listEvent = const [], this.travelItemOnMove});

  ListEventState copyWith({
    List<TravelModelItem>? listEvent,
    TravelModelItem? travelItemOnMove,
  }) {
    return ListEventState(
      listEvent: listEvent ?? this.listEvent,
      travelItemOnMove: travelItemOnMove,
    );
  }
}
