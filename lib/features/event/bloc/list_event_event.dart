import 'package:equatable/equatable.dart';

abstract class ListEventEvent extends Equatable {}

class AddNewEvent extends ListEventEvent {
  final int currentTargetIndex;

  AddNewEvent(this.currentTargetIndex);
  @override
  List<Object?> get props => [currentTargetIndex];
}

class ChangePositionEvent extends ListEventEvent {
  final String eventIdAccept;

  ChangePositionEvent(this.eventIdAccept);
  @override
  List<Object?> get props => [];
}

class TravelItemMove extends ListEventEvent {
  final String eventId;

  TravelItemMove(this.eventId);

  @override
  List<Object?> get props => [];
}

class RemoveEvent extends ListEventEvent {
  final String? eventId;

  RemoveEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class ChangeSizeEvent extends ListEventEvent {
  final bool isIncrease;
  final String eventId;

  ChangeSizeEvent(this.isIncrease, this.eventId);

  @override
  List<Object?> get props => [];
}
