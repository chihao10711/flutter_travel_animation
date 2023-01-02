import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travel_animation/travel_item_model.dart';

import '../bloc/bloc.dart';

class EventWidget extends StatefulWidget {
  final TravelModelItem? nextEventItem;
  const EventWidget({super.key, this.nextEventItem});

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  ListEventBloc get _listEventBloc => context.read<ListEventBloc>();

  double globalPositionPress = 0;
  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelModelItem>(
      builder: (context, value, child) {
        return Column(
          children: [
            _customDivider(value.startTime, value),
            Row(
              children: [
                const Spacer(),
                Draggable<String>(
                  data: value.id,
                  onDragStarted: () {
                    _listEventBloc.add(TravelItemMove(value.id));
                  },
                  onDraggableCanceled: (velocity, offset) {
                    _listEventBloc.add(TravelItemMove(""));
                  },
                  feedback: Material(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: value.itemSize?.height,
                      width: value.itemSize?.width,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(value.name ?? "")),
                    ),
                  ),
                  childWhenDragging: Container(
                    height: value.itemSize?.height,
                    width: value.itemSize?.width,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Container(
                    height: value.itemSize?.height,
                    width: value.itemSize?.width,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(value.name ?? "")),
                  ),
                )
              ],
            ),
            _customDivider(
              value.endTime,
              value,
              true,
            )
          ],
        );
      },
    );
  }

  Widget _customDivider(DateTime? dateTime, TravelModelItem item,
      [bool canGesture = false]) {
    return IgnorePointer(
      ignoring: !canGesture,
      child: GestureDetector(
        onLongPressStart: (details) {
          globalPositionPress = details.globalPosition.dy;
          setState(() => isLongPress = true);
        },
        onLongPressEnd: (_) => setState(
          () => isLongPress = false,
        ),
        onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
          item.changeItemSize(
            details.globalPosition.dy > globalPositionPress,
            onChangeSize: () {
              widget.nextEventItem?.changeNextItem(
                  details.globalPosition.dy > globalPositionPress);
            },
          );
          globalPositionPress = details.globalPosition.dy;
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: (isLongPress && canGesture)
                    ? Colors.blue
                    : Colors.transparent,
                child: Center(
                  child: Text(
                    "${dateTime?.hour} : ${dateTime?.minute}",
                  ),
                ),
              ),
            ),
            SizedBox(
              width: item.itemSize?.width,
              child: Column(
                children: [
                  const Icon(Icons.keyboard_arrow_up, size: 10),
                  Container(
                    color: Theme.of(context).dividerColor,
                    height: 1,
                    width: double.infinity,
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
