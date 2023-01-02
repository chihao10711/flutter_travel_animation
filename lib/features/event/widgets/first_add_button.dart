import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/shared.dart';
import '../bloc/bloc.dart';
import '../event.dart';

class FirstAddButton extends StatefulWidget {
  final int? currentTargetIndex;
  const FirstAddButton({
    super.key,
    this.currentTargetIndex,
  });

  @override
  State<FirstAddButton> createState() => _FirstAddButtonState();
}

class _FirstAddButtonState extends State<FirstAddButton>
    with OffsetToAlignmentMixin {
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
        _listEventBloc.add(AddNewEvent(widget.currentTargetIndex ?? -1));
        setState(() {
          isOnTarget = false;
        });
        changeOnTarget(isOnTarget);
      },
      onWillAccept: (value) {
        if (value != floatAddKey) return false;
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
    return Builder(builder: (context) {
      return Container(
        height: 75,
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text("Let's do something"),
        ),
      );
    });
  }

  void changeOnTarget(bool value) {
    if (mounted) {
      context.read<FloatAddButtonNotifier>().changeOnTarget(value);
    }
  }
}
