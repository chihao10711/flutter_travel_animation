// ignore_for_file: no_logic_in_create_state, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
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
  late DraggableController draggableController;

  double x = 200;
  double y = 200;
  bool isDrag = false;

  double defaultX = 0;
  double defaultY = 0;

  Size get screenSize => MediaQuery.of(context).size;
  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get floatingActionSize => 50;

  @override
  void initState() {
    super.initState();
    draggableController = DraggableController();
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
          ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              final String draggableId = const Uuid().v4();
              return StreamBuilder<DraggableInfo>(
                  initialData: DraggableInfo(false, draggableId),
                  stream: draggableController._isOnTarget,
                  builder: (context, snapshot) {
                    bool isOnTarget = snapshot.data?.isOnTarget ?? false;
                    AnimationController? animationController;
                    return Align(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        child: DragTarget<String>(
                          builder: (context, list, list2) {
                            return isOnTarget &&
                                    snapshot.data?.draggableId == draggableId
                                ? CreateButton(
                                    animationController: (value) {
                                      animationController = value;
                                    },
                                  )
                                : Container(
                                    height: 50,
                                    width: screenSize.width / 2,
                                    // color: Colors.blueGrey,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text('TARGET'),
                                    ),
                                  );
                          },
                          onAccept: (item) async {
                            await showDialog(
                                context: context,
                                builder: (_) => const AlertDialog(
                                      title: Text('Dialog Title'),
                                      content: Text('This is my content'),
                                    ));
                            draggableController._isOnTarget
                                .add(DraggableInfo(false, draggableId));
                          },
                          onWillAccept: (item) {
                            debugPrint('draggable is on the target');
                            draggableController._isOnTarget
                                .add(DraggableInfo(true, draggableId));
                            return true;
                          },
                          onMove: (DragTargetDetails<String> details) {
                            debugPrint(
                                'draggable is on move the target ${details.offset}');
                          },
                          onLeave: (item) async {
                            debugPrint('draggable has left the target');
                            if (!(animationController?.isDismissed ?? true)) {
                              await animationController?.reverse(from: 0.95);
                            }
                            draggableController._isOnTarget
                                .add(DraggableInfo(false, draggableId));
                          },
                        ),
                      ),
                    );
                  });
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
                    stream: draggableController._isOnTarget,
                    builder: (context, snapshot) {
                      bool isOnTarget = snapshot.data?.isOnTarget ?? false;
                      return AnimatedContainer(
                        height: isOnTarget ? 0 : floatingActionSize,
                        width: isOnTarget ? 0 : floatingActionSize,
                        color: Colors.green,
                        curve: Curves.bounceInOut,
                        duration: const Duration(milliseconds: 100),
                      );
                    },
                  ),
                  childWhenDragging: const SizedBox(),
                  // onDraggableCanceled: (_, __) {
                  //   draggableController._isOnTarget
                  //       .add(DraggableInfo(false, null));
                  // },
                  child: Container(
                    height: floatingActionSize,
                    width: floatingActionSize,
                    color: Colors.green,
                  ),
                ));
          }),
        ],
      ),
    );
  }
}

class CreateButton extends StatefulWidget {
  final ValueChanged<AnimationController>? animationController;
  const CreateButton({Key? key, this.animationController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateButton();
}

class _CreateButton extends State<CreateButton> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 150),
        vsync: this);
    widget.animationController?.call(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      alignment: Alignment.bottomRight,
      scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.bounceInOut)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 50,
        width: MediaQuery.of(context).size.width / 2,
      ),
    );
  }
}

class DraggableInfo {
  bool isOnTarget;
  final String draggableId;
  DraggableInfo(this.isOnTarget, this.draggableId);
}

class DraggableController {
  late BehaviorSubject<DraggableInfo> _isOnTarget;

  DraggableController() {
    _isOnTarget = BehaviorSubject<DraggableInfo>();
  }

  // void onTarget(bool onTarget) {
  //   _isOnTarget.add(DraggableInfo(onTarget));
  // }
}
