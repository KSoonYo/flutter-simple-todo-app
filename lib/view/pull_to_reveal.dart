import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PullDirection {
  down,
  up,
}

enum RevealState {
  revealed,
  revealing,
  hidden,
}

class PullToRevealController extends ValueNotifier<RevealState> {
  PullToRevealController() : super(RevealState.hidden);

  void hide() {
    value = RevealState.hidden;
  }
}

class PullToReveal extends StatefulWidget {
  const PullToReveal({
    super.key,
    this.topChild,
    this.bottomChild,
    required this.child,
    this.onReveal,
    this.onHide,
    this.controller,
  }) : assert(topChild != null || bottomChild != null);

  final Widget? topChild;
  final Widget? bottomChild;
  final Widget child;
  final PullToRevealController? controller;
  final VoidCallback? onReveal;
  final VoidCallback? onHide;

  @override
  State<PullToReveal> createState() => _PullToRevealState();
}

class _PullToRevealState extends State<PullToReveal>
    with TickerProviderStateMixin {
  final GlobalKey _topChildKey = GlobalKey();
  final GlobalKey _bottomChildKey = GlobalKey();
  late PullToRevealController _controller;
  late AnimationController _animationController;

  late Animation<Offset> _pullDownAnimation;
  late Animation<Offset> _pullUpAnimation;
  late Animation<Color?> _barrierColorAnimation;

  DragStartDetails? _dragStartDetails;
  var _barrierVisible = false;
  PullDirection? _direction;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? PullToRevealController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final pullAnimation =
        _animationController.drive(CurveTween(curve: Curves.fastOutSlowIn));
    _pullDownAnimation = pullAnimation
        .drive(Tween(begin: const Offset(0, -1), end: const Offset(0, 0)));
    _pullUpAnimation = pullAnimation
        .drive(Tween(begin: const Offset(0, 1), end: const Offset(0, 0)));
    _barrierColorAnimation = _animationController.drive(
      ColorTween(
        begin: Colors.transparent,
        end: Colors.black,
      ),
    );

    _controller.addListener(() async {
      switch (_controller.value) {
        case RevealState.revealed:
          widget.onReveal?.call();
          await _animationController.forward();
          break;
        case RevealState.hidden:
          widget.onHide?.call();
          await _animationController.reverse();

          setState(() {
            _direction = null;
          });
          break;
        case RevealState.revealing:
          break;
      }

      setState(() {
        _barrierVisible = _controller.value != RevealState.hidden;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: _handleDragStart,
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: widget.child,
        ),
        if (_barrierVisible)
          AnimatedModalBarrier(
            color: _barrierColorAnimation,
            onDismiss: () => _controller.value = RevealState.hidden,
          ),
        if (widget.topChild != null && _direction == PullDirection.down)
          SlideTransition(
            key: _topChildKey,
            position: _pullDownAnimation,
            child: widget.topChild,
          ),
        if (widget.bottomChild != null && _direction == PullDirection.up)
          SlideTransition(
            key: _bottomChildKey,
            position: _pullUpAnimation,
            child: GestureDetector(
              child: widget.bottomChild,
              onVerticalDragEnd: (details) {
                // FIXME: A TEMPORARY WAY TO CLOSE THIS SHEEEEEET
                final velocity = details.primaryVelocity;
                if (velocity != null && velocity > 400) {
                  _controller.value = RevealState.hidden;
                }
              },
            ),
          )
      ],
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartDetails = details;

    if (_controller.value == RevealState.hidden) HapticFeedback.lightImpact();

    _controller.value = RevealState.revealing;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    var delta = (details.globalPosition - _dragStartDetails!.globalPosition).dy;
    var direction = _direction;

    if (_direction == null) {
      direction = delta > 0 ? PullDirection.down : PullDirection.up;
    }

    switch (direction) {
      case PullDirection.down:
        delta = max(0, delta); // lower bound
        break;
      case PullDirection.up:
        delta = min(0, delta); // upper bound
        break;
      default:
        break;
    }

    final height =
        (direction == PullDirection.down ? _topChildKey : _bottomChildKey)
            .currentContext
            ?.size
            ?.height;

    if (height != null) {
      _animationController.value = delta.abs() / height;
    }

    setState(() {
      _direction = direction;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.value != RevealState.revealing) return;

    _controller.value = _animationController.value >= 0.4
        ? RevealState.revealed
        : RevealState.hidden;

    if (_controller.value == RevealState.revealed) {
      HapticFeedback.heavyImpact();
    }
  }
}
