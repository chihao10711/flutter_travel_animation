// ignore_for_file: no_logic_in_create_state, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
  late DraggableController<String> draggableController;

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
    draggableController = DraggableController<String>();
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<DraggableInfo<String>>(
                  initialData: DraggableInfo<String>(false, 'hi'),
                  stream: draggableController._isOnTarget,
                  builder: (context, snapshot) {
                    bool isOnTarget = snapshot.data?.isOnTarget ?? false;
                    return DragTarget<String>(
                      builder: (context, list, list2) {
                        return Center(
                          child: isOnTarget
                              ? const CreateButton()
                              : Container(
                                  height: 50,
                                  width: screenSize.width / 2,
                                  color: Colors.blueGrey,
                                  child: const Center(
                                    child: Text('TARGET'),
                                  ),
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
                            .add(DraggableInfo(false, null));
                      },
                      onWillAccept: (item) {
                        debugPrint('draggable is on the target');
                        draggableController._isOnTarget
                            .add(DraggableInfo(true, null));
                        return true;
                      },
                      onLeave: (item) {
                        debugPrint('draggable has left the target');
                        draggableController._isOnTarget
                            .add(DraggableInfo(false, null));
                      },
                    );
                  }),
            ],
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
                  feedback: StreamBuilder<DraggableInfo<String>>(
                    initialData: DraggableInfo<String>(false, 'hi'),
                    stream: draggableController._isOnTarget,
                    builder: (context, snapshot) {
                      bool isOnTarget = snapshot.data?.isOnTarget ?? false;
                      return AnimatedContainer(
                        height: isOnTarget ? 0 : floatingActionSize,
                        width: isOnTarget ? 0 : floatingActionSize,
                        color: Colors.green,
                        curve: Curves.bounceOut,
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
  const CreateButton({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateButton();
}

class _CreateButton extends State<CreateButton> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
      child: Container(
        color: Colors.green,
        height: 50,
        width: MediaQuery.of(context).size.width / 2,
      ),
    );
  }
}

class DraggableInfo<T> {
  bool isOnTarget;
  T? data;
  DraggableInfo(this.isOnTarget, this.data);
}

class DraggableController<T> {
  late BehaviorSubject<DraggableInfo<T>> _isOnTarget;

  DraggableController() {
    _isOnTarget = BehaviorSubject<DraggableInfo<T>>();
  }

  void onTarget(bool onTarget, T data) {
    _isOnTarget.add(DraggableInfo(onTarget, data));
  }
}
