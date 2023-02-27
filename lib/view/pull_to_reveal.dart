import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PullDirection {
  down,
  up,
}

enum RevealState {
  topRevealed,
  bottomRevealed,
  revealing,
  idle,
}

class PullToRevealController extends ChangeNotifier {
  PullToRevealController();

  RevealState _state = RevealState.idle;
  PullDirection? _direction;

  RevealState get state => _state;
  set state(RevealState value) {
    if (value == _state) return;

    _state = value;
    if (_state != RevealState.revealing) _direction = null;

    notifyListeners();
  }

  PullDirection? get direction => _direction;
  set direction(PullDirection? value) {
    if (value == _direction) return;

    _direction = value;
    notifyListeners();
  }

  void show(PullDirection direction) {
    state = direction == PullDirection.down
        ? RevealState.topRevealed
        : RevealState.bottomRevealed;
  }

  void hide() {
    state = RevealState.idle;
  }
}

typedef RevealingCallback = bool Function(PullDirection direction);

class PullToReveal extends StatefulWidget {
  static const defaultRevealDragDistanceThreshold = 0.4;
  static const defaultRevealDragVelocityThreshold = 700.0;

  const PullToReveal({
    super.key,
    this.topChild,
    this.bottomChild,
    required this.child,
    this.onReveal,
    this.onHide,
    this.onRevealing,
    this.controller,
    this.revealDragDistanceThreshold = defaultRevealDragDistanceThreshold,
    this.revealDragVelocityThreshold = defaultRevealDragVelocityThreshold,
  }) : assert(topChild != null || bottomChild != null);

  final Widget? topChild;
  final Widget? bottomChild;
  final Widget child;
  final PullToRevealController? controller;
  final VoidCallback? onReveal;
  final VoidCallback? onHide;
  final RevealingCallback? onRevealing;
  final double revealDragDistanceThreshold;
  final double revealDragVelocityThreshold;

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
      switch (_controller.state) {
        case RevealState.topRevealed:
        case RevealState.bottomRevealed:
          widget.onReveal?.call();
          await _animationController.forward();
          break;
        case RevealState.idle:
          widget.onHide?.call();
          await _animationController.reverse();
          break;
        case RevealState.revealing:
          break;
      }

      setState(() {
        _barrierVisible = _controller.state != RevealState.idle;
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
          onVerticalDragCancel: _handleDragCancel,
          child: widget.child,
        ),
        if (_barrierVisible)
          AnimatedModalBarrier(
            color: _barrierColorAnimation,
            onDismiss: () => _controller.state = RevealState.idle,
          ),
        if (_shouldShowTopChild)
          SlideTransition(
            key: _topChildKey,
            position: _pullDownAnimation,
            child: widget.topChild,
          ),
        if (_shouldShowBottomChild)
          SlideTransition(
            key: _bottomChildKey,
            position: _pullUpAnimation,
            child: GestureDetector(
              child: widget.bottomChild,
              onVerticalDragEnd: (details) {
                // FIXME: A TEMPORARY WAY TO CLOSE THIS SHEEEEEET
                final velocity = details.primaryVelocity;
                if (velocity != null && velocity > 400) {
                  _controller.state = RevealState.idle;
                }
              },
            ),
          )
      ],
    );
  }

  bool get _shouldShowTopChild {
    if (widget.topChild == null) return false;

    if (_controller.state == RevealState.topRevealed) return true;

    return _controller.state == RevealState.revealing &&
        _controller.direction == PullDirection.down;
  }

  bool get _shouldShowBottomChild {
    if (widget.bottomChild == null) return false;

    if (_controller.state == RevealState.bottomRevealed) return true;

    return _controller.state == RevealState.revealing &&
        _controller.direction == PullDirection.up;
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartDetails = details;

    if (_controller.state == RevealState.idle) HapticFeedback.lightImpact();

    _controller.state = RevealState.revealing;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final start = _dragStartDetails;
    if (start == null) return;

    var delta = (details.globalPosition - start.globalPosition).dy;
    var direction = _controller.direction;
    direction ??= delta > 0 ? PullDirection.down : PullDirection.up;

    if (widget.onRevealing?.call(direction) == false) {
      _controller.state = RevealState.idle;
      _dragStartDetails = null; // TODO find a way to cancel drag itself
      return;
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

    _controller.direction = direction;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragStartDetails == null) return;
    _dragStartDetails = null;

    final direction = _controller.direction;
    if (_controller.state != RevealState.revealing || direction == null) return;

    final velocity = details.primaryVelocity;

    if (_animationController.value < widget.revealDragDistanceThreshold &&
        (velocity != null &&
            velocity.abs() < widget.revealDragVelocityThreshold)) {
      _controller.state = RevealState.idle;
      return;
    }

    _controller.state = direction == PullDirection.down
        ? RevealState.topRevealed
        : RevealState.bottomRevealed;

    HapticFeedback.heavyImpact();
  }

  void _handleDragCancel() {
    if (_dragStartDetails == null) return;
    _dragStartDetails = null;

    _controller.state = RevealState.idle;
  }
}
