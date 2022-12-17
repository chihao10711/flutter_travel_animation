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

  Size get screenSize => MediaQuery.of(context).size;
  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get floatingActionSize => 75;

  final List<String> _event = [];

  @override
  void initState() {
    super.initState();
    draggableController = StreamController<DraggableInfo>.broadcast();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    defaultX = (screenSize.width - 50) / 2;
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
                  streamController: draggableController,
                  onTargetAccept: () {
                    _event.add("Event ${_event.length + 1}");
                    setState(() {});
                  },
                )
              : ListView.separated(
                  itemCount: _event.length,
                  itemBuilder: (context, index) {
                    return DragTargetWidget(
                      streamController: draggableController,
                      onTargetAccept: () {
                        _event.add("Event ${_event.length + 1}");
                        setState(() {});
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return DragTargetWidget(
                      streamController: draggableController,
                      smallTarget: true,
                      onTargetAccept: () {
                        _event.add("Event ${_event.length + 1}");
                        setState(() {});
                      },
                    );
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
                child: Container(
                  width: floatingActionSize,
                  height: floatingActionSize,
                  color: Colors.blue,
                  child: const Icon(Icons.add),
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
  final bool smallTarget;
  const DragTargetWidget(
      {super.key,
      required this.streamController,
      this.targetEmpty = false,
      required this.onTargetAccept,
      this.smallTarget = false});

  @override
  State<DragTargetWidget> createState() => _DragTargetWidgetState();
}

class _DragTargetWidgetState extends State<DragTargetWidget> {
  late StreamController<DraggableInfo> _streamController;
  late String _targetId;
  final ValueNotifier<Alignment> _alignment = ValueNotifier(Alignment.center);

  Size get screenSize => MediaQuery.of(context).size;

  late Size targetSize;

  @override
  void initState() {
    super.initState();
    _streamController = widget.streamController;
    _targetId = const Uuid().v4();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    targetSize = Size(screenSize.width * 0.75, widget.smallTarget ? 10 : 75);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DraggableInfo>(
      initialData: DraggableInfo(false, _targetId),
      stream: _streamController.stream,
      builder: (context, snapshot) {
        bool isOnTarget = snapshot.data?.isOnTarget ?? false;
        return Align(
          child: Builder(
            builder: (context) {
              AnimationController? animationController;
              return DragTarget<String>(
                builder: (context, list, list2) {
                  return isOnTarget && snapshot.data?.draggableId == _targetId
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: widget.smallTarget ? 5 : 0),
                          child: CreateButtonWidget(
                            alignmentNotify: _alignment,
                            animationController: (AnimationController value) {
                              animationController = value;
                            },
                          ),
                        )
                      : (widget.targetEmpty
                          ? Container(
                              height: targetSize.height,
                              width: targetSize.width,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('TARGET EMPTY'),
                              ),
                            )
                          : Container(
                              height: targetSize.height,
                              width: targetSize.width,
                              margin: EdgeInsets.symmetric(
                                  vertical: widget.smallTarget ? 5 : 0),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(widget.smallTarget ? '' : 'TARGET'),
                              ),
                            ));
                },
                onAccept: (item) async {
                  await showDialog(
                      context: context,
                      builder: (_) => const AlertDialog(
                            title: Text('Dialog Title'),
                            content: Text('This is my content'),
                          ));
                  widget.onTargetAccept.call();
                  _streamController.sink.add(DraggableInfo(false, _targetId));
                },
                onWillAccept: (item) {
                  debugPrint('draggable is on the target');
                  _streamController.sink.add(DraggableInfo(true, _targetId));
                  return true;
                },
                onMove: (DragTargetDetails<String> details) {
                  RenderBox renderBox =
                      (context.findRenderObject() as RenderBox);
                  Offset localTouchPosition =
                      renderBox.globalToLocal(details.offset);
                  double width = renderBox.size.width;
                  double height = renderBox.size.height;
                  var alignmentX =
                      (localTouchPosition.dx - width / 2) / (width / 2);
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
          ),
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 200),
        vsync: this);
    widget.animationController.call(_controller);
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
            scale: Tween(begin: 0.25, end: 1.0).animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutBack,
            )),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 75,
              width: MediaQuery.of(context).size.width * 0.75,
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
