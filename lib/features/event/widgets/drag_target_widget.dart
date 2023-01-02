import 'dart:async';

import 'package:flutter/material.dart';
import 'package:travel_animation/travel_item_model.dart';

import '../event.dart';

class DragTargetWidget extends StatefulWidget {
  final StreamController<TravelModelItem> streamController;
  final VoidCallback onTargetAccept;
  final bool targetEmpty;
  final bool? isLast;
  final bool? isFirst;
  final int indexItem;
  final ValueChanged<TravelModelItem>? onChangeIndex;
  final ValueChanged<String>? onMoveIndex;
  final TravelModelItem data;

  const DragTargetWidget({
    super.key,
    required this.streamController,
    this.targetEmpty = false,
    required this.onTargetAccept,
    this.isLast,
    this.isFirst,
    required this.indexItem,
    this.onChangeIndex,
    this.onMoveIndex,
    required this.data,
  });

  @override
  State<DragTargetWidget> createState() => _DragTargetWidgetState();
}

class _DragTargetWidgetState extends State<DragTargetWidget> {
  late StreamController<TravelModelItem> _streamController;
  late String _targetId;
  final ValueNotifier<Alignment> _alignment = ValueNotifier(Alignment.center);
  bool onLongPress = false;
  double globalPositionPress = 0;

  Size get screenSize => MediaQuery.of(context).size;

  late Size targetSize;

  @override
  void initState() {
    super.initState();
    _streamController = widget.streamController;
    _targetId = widget.data.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    targetSize = widget.data.itemSize ?? Size(screenSize.width * 0.75, 75);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TravelModelItem>(
      initialData: TravelModelItem(_targetId),
      stream: _streamController.stream,
      builder: (context, snapshot) {
        bool isOnTarget = snapshot.data?.isOnTarget ?? false;
        String? draggableId = snapshot.data?.id;
        return Align(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.targetEmpty
                  ? _dragTarget(
                      isOnTarget,
                      draggableId,
                      Container(
                        height: targetSize.height,
                        width: targetSize.width,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('TARGET EMPTY'),
                        ),
                      ))
                  : Draggable<String>(
                      data: "",
                      onDragStarted: () {
                        widget.onMoveIndex?.call(widget.data.id);
                      },
                      onDraggableCanceled: (velocity, offset) {
                        widget.onMoveIndex?.call("");
                      },
                      feedback: Material(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 75,
                          width: targetSize.width,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                                "${widget.data.name ?? _targetId} $targetSize"),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        height: targetSize.height,
                        width: targetSize.width,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Container(
                        height: targetSize.height,
                        width: targetSize.width,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                              "${widget.data.name ?? _targetId} $targetSize"),
                        ),
                      ),
                    ),
              // Visibility(
              //   visible: !widget.targetEmpty,
              //   child: _child(isOnTarget, draggableId),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _child(bool isOnTarget, String? draggableId) {
    if (widget.isLast == null && widget.isFirst == null) {
      return const SizedBox();
    } else if ((widget.isLast ?? false)) {
      return _dragTarget(
        isOnTarget,
        draggableId,
        _longPress(
          child: Container(
            height: 5,
            width: targetSize.width,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: onLongPress ? Colors.red : Colors.blueGrey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        checkTargetAccept: true,
      );
    } else {
      return Column(
        children: [
          _longPress(
            child: Container(
              height: 5,
              width: targetSize.width,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: onLongPress ? Colors.red : Colors.blueGrey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          _dragTarget(
            isOnTarget,
            draggableId,
            Container(
              height: 75,
              width: screenSize.width * 0.75,
              decoration: BoxDecoration(
                color: Colors.redAccent.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text("Walk")),
            ),
            checkTargetAccept: false,
          ),
          Container(
            height: 5,
            width: targetSize.width,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      );
    }
  }

  Widget _longPress({required Widget child}) {
    return GestureDetector(
      onLongPressStart: (details) {
        globalPositionPress = details.globalPosition.dy;
        setState(() => onLongPress = true);
      },
      onLongPressEnd: (_) => setState(() {
        onLongPress = false;
      }),
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        var newHeight = targetSize.height;
        if (details.globalPosition.dy > globalPositionPress) {
          globalPositionPress = details.globalPosition.dy;
          newHeight = newHeight + 1;
        } else {
          globalPositionPress = details.globalPosition.dy;
          newHeight = newHeight - 1;
        }
        if (newHeight > 150) return;
        if (newHeight < 40) return;

        setState(() {
          targetSize = Size(screenSize.width * 0.75, newHeight);
        });

        // int indexCurrentItem = _event.indexWhere((e) => e.id == _targetId);
        // _event[indexCurrentItem] =
        //     _event[indexCurrentItem].copyWith(itemSize: targetSize);
      },
      child: child,
    );
  }

  Widget _dragTarget(
    bool isOnTarget,
    String? draggableId,
    Widget child, {
    bool checkTargetAccept = true,
  }) {
    return Builder(
      builder: (context) {
        AnimationController? animationController;
        return DragTarget<String>(
          builder: (context, list, list2) {
            return isOnTarget && draggableId == _targetId
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CreateButtonWidget(
                      alignmentNotify: _alignment,
                      animationController: (AnimationController value) {
                        animationController = value;
                      },
                    ),
                  )
                : child;
          },
          onAccept: (item) async {
            await showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                      title: Text('Dialog Title'),
                      content: Text('This is my content'),
                    ));
            if (item == "addNewDraggable") {
              widget.onTargetAccept.call();
            } else {
              widget.onChangeIndex?.call(TravelModelItem(_targetId,
                  isOnTarget: false, itemSize: targetSize));
            }

            _streamController.sink
                .add(TravelModelItem(_targetId, isOnTarget: false));
          },
          onWillAccept: (item) {
            // int indexTargetMove =
            //     _event.indexWhere((e) => e.id == travelItemOnMove.id);
            // int indexCurrentTarGet =
            //     _event.indexWhere((e) => e.id == _targetId);
            // if (travelItemOnMove.id == _targetId) return false;
            // if (indexTargetMove == (indexCurrentTarGet + 1)) return false;
            _streamController.sink
                .add(TravelModelItem(_targetId, isOnTarget: true));
            return true;
          },
          onMove: (DragTargetDetails<String> details) {
            RenderBox renderBox = (context.findRenderObject() as RenderBox);
            Offset localTouchPosition = renderBox.globalToLocal(details.offset);
            double width = renderBox.size.width;
            double height = renderBox.size.height;
            var alignmentX = (localTouchPosition.dx - width / 2) / (width / 2);
            var alignmentY =
                (localTouchPosition.dy - height / 2) / (height / 2);
            _alignment.value = Alignment(alignmentX, alignmentY);
          },
          onLeave: (item) async {
            await animationController?.reverse();
            _streamController.sink
                .add(TravelModelItem(_targetId, isOnTarget: false));
          },
        );
      },
    );
  }
}
