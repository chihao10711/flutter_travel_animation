import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travel_animation/travel_item_model.dart';

import '../bloc/bloc.dart';
import '../event.dart';

String floatAddKey = "addNewDraggable";

class EventHomeScreen extends StatefulWidget {
  const EventHomeScreen({super.key});

  @override
  State<EventHomeScreen> createState() => _EventHomeScreenState();
}

class _EventHomeScreenState extends State<EventHomeScreen> {
  late StreamController<TravelModelItem> draggableController;

  Size get screenSize => MediaQuery.of(context).size;
  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get floatingActionSize => 50;
  ListEventBloc get _listEventBloc => context.read<ListEventBloc>();

  @override
  void initState() {
    super.initState();
    draggableController = StreamController<TravelModelItem>.broadcast();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<FloatAddButtonNotifier>().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.loose,
        children: [
          const SizedBox.expand(),
          BlocBuilder<ListEventBloc, ListEventState>(
            builder: (context, state) {
              return state.listEvent.isEmpty
                  ? const Center(
                      child: FirstAddButton(),
                    )
                  : ListView.separated(
                      itemCount: state.listEvent.length + 1,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: index == state.listEvent.length
                              ? Row(
                                  children: [
                                    const Spacer(),
                                    FirstAddButton(
                                      currentTargetIndex: index - 1,
                                    ),
                                  ],
                                )
                              : ChangeNotifierProvider.value(
                                  value: state.listEvent[index],
                                  child: EventWidget(
                                    nextEventItem:
                                        index == state.listEvent.length - 1
                                            ? null
                                            : state.listEvent[index + 1],
                                  ),
                                ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Visibility(
                          visible: index != state.listEvent.length - 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Spacer(),
                                WalkWidget(
                                  data: state.listEvent[index],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            },
          ),
          Consumer<FloatAddButtonNotifier>(
            builder: (context, value, child) {
              return AnimatedPositioned(
                left: value.positionX,
                top: value.positionY,
                curve: Curves.elasticOut,
                duration: const Duration(milliseconds: 700),
                child: Draggable(
                  data: floatAddKey,
                  onDragUpdate: value.onDragUpdate,
                  onDragEnd: (_) => value.onDragEnd(),
                  feedback: _FloatAddButtonFeedBack(value: value),
                  childWhenDragging: const SizedBox(),
                  child: BlocBuilder<ListEventBloc, ListEventState>(
                    builder: (context, state) {
                      return DragTarget<String>(
                        onAccept: (data) => _listEventBloc
                            .add(RemoveEvent(state.travelItemOnMove?.id)),
                        builder: (context, _, __) => Container(
                          width: value.floatingActionSize,
                          height: value.floatingActionSize,
                          color: Colors.blue,
                          child: Icon(
                            state.travelItemOnMove?.id.isNotEmpty ?? false
                                ? Icons.delete
                                : Icons.add,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _FloatAddButtonFeedBack extends StatelessWidget {
  final FloatAddButtonNotifier value;
  const _FloatAddButtonFeedBack({Key? key, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: value,
      child: Consumer<FloatAddButtonNotifier>(builder: (context, value, child) {
        bool isOnTarget = value.isOnTarget;
        return AnimatedContainer(
          height: isOnTarget ? 0 : value.floatingActionSize,
          width: isOnTarget ? 0 : value.floatingActionSize,
          color: Colors.blue,
          curve: Curves.bounceInOut,
          duration: const Duration(milliseconds: 100),
          child: isOnTarget ? const SizedBox() : const Icon(Icons.add),
        );
      }),
    );
  }
}
