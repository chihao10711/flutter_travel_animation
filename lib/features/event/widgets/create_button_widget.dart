import 'package:flutter/material.dart';

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
