import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  late StreamController<DraggableInfo> draggableController;

  double x = 0;
  double y = 0;
  bool isDrag = false;

  double defaultX = 0;
  double defaultY = 0;
  String targetMove = "";

  Size get screenSize => MediaQuery.of(context).size;
  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get floatingActionSize => 50;

  final List<String> _event = [];

  @override
  void initState() {
    super.initState();
    draggableController = StreamController<DraggableInfo>.broadcast();
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
                    _event.add(Uuid().v4());
                    setState(() {});
                  },
                  targetId: Uuid().v4(),
                )
              : ListView.separated(
                  itemCount: _event.length,
                  itemBuilder: (context, index) {
                    return DragTargetWidget(
                      title: _event[index],
                      indexItem: index,
                      isLast: index == _event.length - 1,
                      isFirst: index == 0,
                      streamController: draggableController,
                      onTargetAccept: () {
                        _event.insert(index + 1, Uuid().v4());
                        setState(() {});
                      },
                      onMoveIndex: (value) {
                        targetMove = value;
                        print("onMoveIndex: $targetMove");
                        setState(() {});
                      },
                      onChangeIndex: (value) {
                        int index1 = _event.indexOf(value);
                        int index2 = _event.indexOf(targetMove);
                        _event[index1] = targetMove;
                        _event[index2] = value;

                        targetMove = "";
                        setState(() {});
                      },
                      targetId: _event[index],
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
                data: "hi",
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
                feedback: StreamBuilder<DraggableInfo>(
                  initialData: DraggableInfo(false, ''),
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
                  onAccept: (data) {},
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: floatingActionSize,
                      height: floatingActionSize,
                      color: Colors.blue,
                      child:
                          Icon(targetMove.isEmpty ? Icons.delete : Icons.add),
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
  final StreamController<DraggableInfo> streamController;
  final VoidCallback onTargetAccept;
  final bool targetEmpty;
  final String? title;
  final bool? isLast;
  final bool? isFirst;
  final int indexItem;
  final ValueChanged<String>? onChangeIndex;
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
  late StreamController<DraggableInfo> _streamController;
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
    _targetId = widget.targetId; //const Uuid().v4();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    targetSize = Size(screenSize.width * 0.75, 75);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DraggableInfo>(
      initialData: DraggableInfo(false, _targetId),
      stream: _streamController.stream,
      builder: (context, snapshot) {
        bool isOnTarget = snapshot.data?.isOnTarget ?? false;
        String? draggableId = snapshot.data?.draggableId;
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
                      feedback: Material(
                        child: Container(
                          height: targetSize.height,
                          width: targetSize.width,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(widget.title ?? _targetId),
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
                          child: Text(widget.title ?? _targetId),
                        ),
                      ),
                    ),
              Visibility(
                visible: !widget.targetEmpty,
                child: GestureDetector(
                    onLongPressStart: (details) {
                      globalPositionPress = details.globalPosition.dy;
                      setState(() => onLongPress = true);
                    },
                    onLongPressEnd: (_) => setState(() {
                          onLongPress = false;
                        }),
                    onLongPressMoveUpdate:
                        (LongPressMoveUpdateDetails details) {
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
                    },
                    child: _child(isOnTarget, draggableId)),
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
          Container(
            height: 5,
            width: targetSize.width,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: onLongPress ? Colors.red : Colors.blueGrey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          checkTargetAccept: true);
    } else {
      return Column(
        children: [
          Container(
            height: 5,
            width: targetSize.width,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: onLongPress ? Colors.red : Colors.blueGrey,
              borderRadius: BorderRadius.circular(8),
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
              color: onLongPress ? Colors.red : Colors.blueGrey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      );
    }
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
            if (checkTargetAccept) widget.onTargetAccept.call();
            if (widget.onChangeIndex != null && !checkTargetAccept) {
              widget.onChangeIndex?.call(widget.targetId);
            }
            _streamController.sink.add(DraggableInfo(false, _targetId));
          },
          onWillAccept: (item) {
            debugPrint('draggable is on the target id $_targetId');
            _streamController.sink.add(DraggableInfo(true, _targetId));
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
            debugPrint('draggable has left the target');
            await animationController?.reverse();
            _streamController.sink.add(DraggableInfo(false, _targetId));
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

class DraggableInfo {
  bool isOnTarget;
  final String draggableId;
  DraggableInfo(this.isOnTarget, this.draggableId);
}
