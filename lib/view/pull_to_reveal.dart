import 'package:flutter/material.dart';

class PullToRevealController extends ChangeNotifier {
  PullToRevealController({
    this.onReveal,
    this.onHide,
  });

  final VoidCallback? onReveal;
  final VoidCallback? onHide;
  AnimationController? _animationController;

  void attach(AnimationController animationController) {
    _animationController = animationController;
  }

  void detach() {
    _animationController = null;
  }

  @override
  void dispose() {
    detach();

    super.dispose();
  }

  Future<void> show() async {
    final controller = _animationController;
    if (controller == null || controller.isDismissed) return;

    onReveal?.call();
    await controller.forward();
  }

  Future<void> hide() async {
    final controller = _animationController;
    if (controller == null || controller.isDismissed) return;

    onHide?.call();
    await controller.reverse();
  }
}

class PullToReveal extends StatefulWidget {
  const PullToReveal({
    super.key,
    required this.revealableChild,
    required this.child,
    this.controller,
  });

  final Widget revealableChild;
  final Widget child;
  final PullToRevealController? controller;

  @override
  State<PullToReveal> createState() => _PullToRevealState();
}

class _PullToRevealState extends State<PullToReveal>
    with SingleTickerProviderStateMixin {
  final GlobalKey _revealableChildKey = GlobalKey();
  late AnimationController _animationController;

  late Animation<Offset> _revealAnimation;
  late Animation<Color?> _barrierColorAnimation;
  bool _barrierVisible = false;

  DragStartDetails? _dragStartDetails;

  late PullToRevealController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? PullToRevealController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _revealAnimation = _animationController
        .drive(
          CurveTween(curve: Curves.fastOutSlowIn),
        )
        .drive(
          Tween(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ),
        );
    _barrierColorAnimation = _animationController.drive(
      ColorTween(
        begin: Colors.transparent,
        end: Colors.black,
      ),
    );

    _controller.attach(_animationController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (details) {
        _dragStartDetails = details;
        setState(() {
          _barrierVisible = true;
        });
      },
      onVerticalDragUpdate: (details) {
        final delta =
            details.globalPosition.dy - _dragStartDetails!.globalPosition.dy;
        final height = _revealableChildKey.currentContext?.size?.height;

        if (height == null) return;

        _animationController.value = delta / height;
      },
      onVerticalDragEnd: (details) async {
        if (_animationController.value > 0.4) {
          await _controller.show();
        } else {
          await _controller.hide();
          setState(() {
            _barrierVisible = false;
          });
        }
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_barrierVisible)
            AnimatedModalBarrier(
              color: _barrierColorAnimation,
              onDismiss: () async {
                await _controller.hide();
                setState(() {
                  _barrierVisible = false;
                });
              },
            ),
          SlideTransition(
            key: _revealableChildKey,
            position: _revealAnimation,
            child: widget.revealableChild,
          ),
        ],
      ),
    );
  }
}
