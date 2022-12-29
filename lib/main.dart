import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import 'travel_item_model.dart';

TravelModelItem travelItemOnMove = TravelModelItem("");

List<TravelModelItem> _event = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Draggable Widget',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamController<TravelModelItem> draggableController;

  double x = 0;
  double y = 0;
  bool isDrag = false;

  double defaultX = 0;
  double defaultY = 0;

  Size get screenSize => MediaQuery.of(context).size;
  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get floatingActionSize => 50;

  @override
  void initState() {
    super.initState();
    draggableController = StreamController<TravelModelItem>.broadcast();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    defaultX = (screenSize.width - floatingActionSize) / 2;
    defaultY = screenSize.height - floatingActionSize - viewPadding.bottom;
    x = defaultX;
    y = defaultY;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.loose,
        children: [
          const SizedBox.expand(),
          _event.isEmpty
              ? DragTargetWidget(
                  indexItem: 0,
                  streamController: draggableController,
                  targetEmpty: true,
                  onTargetAccept: () {
                    _event.add(TravelModelItem(const Uuid().v4()));
                    setState(() {});
                  },
                  targetId: const Uuid().v4(),
                )
              : ListView.separated(
                  itemCount: _event.length,
                  itemBuilder: (context, index) {
                    return DragTargetWidget(
                      title: _event[index].id,
                      indexItem: index,
                      isLast: index == _event.length - 1,
                      isFirst: index == 0,
                      streamController: draggableController,
                      onTargetAccept: () {
                        _event.insert(
                            index + 1, TravelModelItem(const Uuid().v4()));
                        setState(() {});
                      },
                      onMoveIndex: (value) {
                        if (value.isNotEmpty) {
                          travelItemOnMove =
                              _event.firstWhere((e) => e.id == value);
                        } else {
                          travelItemOnMove = TravelModelItem("");
                        }
                        setState(() {});
                      },
                      onChangeIndex: (value) {
                        try {
                          if (value.id.isNotEmpty) {
                            int index1 =
                                _event.indexWhere((e) => e.id == value.id);
                            int index2 = _event
                                .indexWhere((e) => e.id == travelItemOnMove.id);
                            _event.removeAt(index2);
                            _event.insert(min(_event.length, index1 + 1),
                                travelItemOnMove);
                          }
                        } catch (e) {
                          print("onChangeIndex error $e");
                        } finally {
                          travelItemOnMove = TravelModelItem("");
                          setState(() {});
                        }
                      },
                      targetId: _event[index].id,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox();
                  },
                ),
          StatefulBuilder(builder: (context, setState2) {
            return AnimatedPositioned(
              left: x,
              top: y,
              curve: Curves.elasticOut,
              duration: const Duration(milliseconds: 700),
              child: Draggable(
                data: "addNewDraggable",
                onDragUpdate: (details) {
                  x = x + details.delta.dx;
                  y = y + details.delta.dy;
                  setState2(() {});
                },
                onDragEnd: (details) {
                  x = defaultX;
                  y = defaultY;
                  setState2(() {});
                },
                feedback: StreamBuilder<TravelModelItem>(
                  initialData: TravelModelItem(""),
                  stream: draggableController.stream,
                  builder: (context, snapshot) {
                    bool isOnTarget = snapshot.data?.isOnTarget ?? false;
                    return AnimatedContainer(
                      height: isOnTarget ? 0 : floatingActionSize,
                      width: isOnTarget ? 0 : floatingActionSize,
                      color: Colors.blue,
                      curve: Curves.bounceInOut,
                      duration: const Duration(milliseconds: 100),
                      child:
                          isOnTarget ? const SizedBox() : const Icon(Icons.add),
                    );
                  },
                ),
                childWhenDragging: const SizedBox(),
                child: DragTarget<String>(
                  onAccept: (data) {
                    _event.removeWhere((e) => e.id == travelItemOnMove.id);
                    for (var element in _event) {
                      print(element.itemSize);
                    }
                    travelItemOnMove = TravelModelItem("");
                    setState(() {});
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: floatingActionSize,
                      height: floatingActionSize,
                      color: Colors.blue,
                      child: Icon(travelItemOnMove.id.isNotEmpty
                          ? Icons.delete
                          : Icons.add),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DragTargetWidget extends StatefulWidget {
  final StreamController<TravelModelItem> streamController;
  final VoidCallback onTargetAccept;
  final bool targetEmpty;
  final String? title;
  final bool? isLast;
  final bool? isFirst;
  final int indexItem;
  final ValueChanged<TravelModelItem>? onChangeIndex;
  final ValueChanged<String>? onMoveIndex;
  final String targetId;

  const DragTargetWidget({
    super.key,
    required this.streamController,
    this.targetEmpty = false,
    required this.onTargetAccept,
    this.title,
    this.isLast,
    this.isFirst,
    required this.indexItem,
    this.onChangeIndex,
    required this.targetId,
    this.onMoveIndex,
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
    _targetId = widget.targetId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    targetSize = Size(screenSize.width * 0.75, 75);
  }

  @override
  void didUpdateWidget(covariant DragTargetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _streamController = widget.streamController;
    _targetId = widget.targetId;

    targetSize = _event.firstWhereOrNull((e) => e.id == _targetId)?.itemSize ??
        Size(screenSize.width * 0.75, 75);

    setState(() {});
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
                        widget.onMoveIndex?.call(widget.targetId);
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
                                "${widget.title ?? _targetId} $targetSize"),
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
                          child:
                              Text("${widget.title ?? _targetId} $targetSize"),
                        ),
                      ),
                    ),
              Visibility(
                visible: !widget.targetEmpty,
                child: _child(isOnTarget, draggableId),
              ),
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

        int indexCurrentItem = _event.indexWhere((e) => e.id == _targetId);
        _event[indexCurrentItem] =
            _event[indexCurrentItem].copyWith(itemSize: targetSize);
      },
      child: child,
    );
  }

  Widget _dragTarget(bool isOnTarget, String? draggableId, Widget child,
      {bool checkTargetAccept = true}) {
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
            int indexTargetMove =
                _event.indexWhere((e) => e.id == travelItemOnMove.id);
            int indexCurrentTarGet =
                _event.indexWhere((e) => e.id == _targetId);
            if (travelItemOnMove.id == _targetId) return false;
            if (indexTargetMove == (indexCurrentTarGet + 1)) return false;
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

class CreateButtonWidget extends StatefulWidget {
  final ValueNotifier<Alignment> alignmentNotify;
  final ValueChanged<AnimationController> animationController;
  const CreateButtonWidget(
      {super.key,
      required this.alignmentNotify,
      required this.animationController});

  @override
  State<CreateButtonWidget> createState() => _CreateButtonWidgetState();
}

class _CreateButtonWidgetState extends State<CreateButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 200),
        vsync: this);
    widget.animationController.call(_controller);
    _animation = Tween(begin: 0.25, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Alignment>(
        valueListenable: widget.alignmentNotify,
        builder: (context, value, _) {
          return ScaleTransition(
            alignment: value,
            scale: _animation,
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 75,
                width: (MediaQuery.of(context).size.width * 0.75),
              ),
            ),
          );
        });
  }
}
