import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_animation/shared/shared.dart';
import 'package:travel_animation/travel_item_model.dart';

import '../bloc/bloc.dart';
import '../provider/float_add_button_notifier.dart';
import 'create_button_widget.dart';

class WalkWidget extends StatefulWidget {
  final TravelModelItem data;
  const WalkWidget({super.key, required this.data});

  @override
  State<WalkWidget> createState() => _WalkWidgetState();
}

class _WalkWidgetState extends State<WalkWidget> with OffsetToAlignmentMixin {
  bool isOnTarget = false;
  ListEventBloc get _listEventBloc => context.read<ListEventBloc>();
  @override
  Widget build(BuildContext context) {
    AnimationController? animationController;
    return DragTarget<String>(
      builder: (context, list, list2) {
        return isOnTarget
            ? CreateButtonWidget(
                alignmentNotify: alignment,
                animationController: (AnimationController value) {
                  animationController = value;
                },
              )
            : _child();
      },
      onAccept: (_) async {
        await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Dialog Title'),
            content: Text('This is my content'),
          ),
        );
        _listEventBloc.add(ChangePositionEvent(widget.data.id));
        setState(() {
          isOnTarget = false;
        });
        changeOnTarget(isOnTarget);
      },
      onWillAccept: (_) {
        List<TravelModelItem> listEvent = _listEventBloc.state.listEvent;
        TravelModelItem? travelItemOnMove =
            _listEventBloc.state.travelItemOnMove;
        int indexTargetMove =
            listEvent.indexWhere((e) => e.id == travelItemOnMove?.id);
        int indexCurrentTarGet = _listEventBloc.state.listEvent
            .indexWhere((e) => e.id == widget.data.id);
        if (travelItemOnMove?.id == widget.data.id) return false;
        if (indexTargetMove == (indexCurrentTarGet + 1)) return false;
        setState(() {
          isOnTarget = true;
        });
        changeOnTarget(isOnTarget);
        return true;
      },
      onMove: (DragTargetDetails<String> details) {
        offsetToAlignmentMixin(context, details.offset);
      },
      onLeave: (_) async {
        await animationController?.reverse();
        setState(() {
          isOnTarget = false;
        });
        changeOnTarget(isOnTarget);
      },
    );
  }

  Widget _child() {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text("Walk")),
    );
  }

  void changeOnTarget(bool value) {
    if (mounted) {
      context.read<FloatAddButtonNotifier>().changeOnTarget(value);
    }
  }
}
