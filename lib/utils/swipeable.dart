// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Curve _kResizeTimeCurve = Interval(0.4, 1.0, curve: Curves.ease);
const double _kSwipeThreshold = 0.3;
const double _kLongSwipeThreshold = 0.5;
const double _kShortSwipeThreshold = 0.2;

// used by onSwiped
typedef SwipeDirectionCallback = void Function(SwipeDirection swipeDirection);

// used by onUpdate
typedef SwipeUpdateCallback = void Function(SwipeUpdateDetails details);

typedef ConfirmSwipeCallback = Future<bool?> Function(
    SwipeDirection direction, SwipeType swipeType);

enum SwipeDirection { left, right, up, down, none }

enum SwipeType { short, long, none }

class Swipeable extends StatefulWidget {
  const Swipeable({
    super.key,
    required this.child,
    this.onUpdate,
    this.onResize,
    this.onSwiped,
    this.confirmSwipe,
    this.background,
    this.icons,
    this.resizeDuration = const Duration(milliseconds: 300),
    this.swipeThresholds = const <SwipeType, double>{},
    this.movementDuration = const Duration(milliseconds: 200),
    this.crossAxisEndOffset = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final SwipeUpdateCallback? onUpdate;
  final VoidCallback? onResize;
  final SwipeDirectionCallback? onSwiped;
  final ConfirmSwipeCallback? confirmSwipe;
  final Duration? resizeDuration;
  final Map<SwipeType, double> swipeThresholds;
  final Duration movementDuration;
  final double crossAxisEndOffset;
  final DragStartBehavior dragStartBehavior;
  final HitTestBehavior behavior;
  final Widget? background;
  final List<TrailingIconButton>? icons;

  @override
  State<Swipeable> createState() => _SwipeableState();
}

class SwipeUpdateDetails {
  SwipeUpdateDetails(
      {required this.direction,
      this.reached = SwipeType.none,
      this.previousReached = SwipeType.none});

  final SwipeDirection direction;
  final SwipeType reached;
  final SwipeType previousReached;
}

class TrailingIconButton {
  TrailingIconButton(
      {required this.icon, this.onPressed, this.isRemained = true});

  final bool isRemained;
  final Icon icon;
  final void Function()? onPressed;
}

class _SwipeableClipper extends CustomClipper<Rect> {
  _SwipeableClipper({
    required this.axis,
    required this.moveAnimation,
  }) : super(reclip: moveAnimation);
  final Axis axis;
  final Animation<Offset> moveAnimation;

  @override
  Rect getClip(Size size) {
    final double offset = moveAnimation.value.dx * size.width;
    if (offset < 0) {
      return Rect.fromLTRB(size.width + offset, 0.0, size.width, size.height);
    }
    return Rect.fromLTRB(0.0, 0.0, offset, size.height);
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_SwipeableClipper oldClipper) {
    return oldClipper.axis != axis ||
        oldClipper.moveAnimation.value != moveAnimation.value;
  }
}

class _SwipeableState extends State<Swipeable>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _moveController =
        AnimationController(duration: widget.movementDuration, vsync: this)
          ..addStatusListener(_handleSwipeStatusChanged)
          ..addListener(_handleSwipeUpdateValueChanged);
    _updateMoveAnimation();
  }

  @override
  void dispose() {
    _moveController!.dispose();
    _resizeController?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive =>
      (_moveController?.isAnimating ?? false) ||
      (_resizeController?.isAnimating ?? false);

  AnimationController? _moveController;
  late Animation<Offset> _moveAnimation;

  AnimationController? _resizeController;
  Animation<double>? _resizeAnimation;

  double _dragExtent = 0.0;
  double _oldDragExtent = 0.0;
  bool _confirming = false;
  bool _dragUnderway = false;
  Size? _sizePriorToCollapse;
  SwipeType _swipeThresholdReached = SwipeType.none;

  SwipeDirection _extendToDirection(double extent) {
    if (extent == 0.0) return SwipeDirection.none;
    return extent > 0 ? SwipeDirection.right : SwipeDirection.left;
  }

  SwipeDirection get _swipeDirection => _extendToDirection(_dragExtent);

  bool get _isActive {
    return _dragUnderway || _moveController!.isAnimating;
  }

  double get _overallDragExtent {
    final Size size = context.size!;
    return size.width;
  }

  void _hanldeDragStart(DragStartDetails details) {
    if (_confirming) return;
    _dragUnderway = true;
    if (_moveController!.isAnimating) {
      _dragExtent =
          _moveController!.value * _overallDragExtent * _dragExtent.sign;
      _moveController!.stop();
    } else if (_oldDragExtent.abs() > 0) {
      _dragExtent = _oldDragExtent;
    } else {
      _dragExtent = 0.0;
      _moveController!.value = 0.0;
    }

    setState(() {
      _updateMoveAnimation();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _moveController!.isAnimating) return;

    final double delta = details.primaryDelta!;
    final double oldDragExtent = _dragExtent;
    _dragExtent += delta;

    if (_swipeDirection == SwipeDirection.none) return;

    if (_swipeDirection != SwipeDirection.right) {
      _moveController!.value = _dragExtent.abs() / _overallDragExtent;
    } else {
      // turn
      _dragExtent = 0;
    }
    setState(() {
      _updateMoveAnimation();
    });

    // if (oldDragExtent.sign != _dragExtent.sign) {
    // }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isActive || _moveController!.isAnimating) return;
    _dragUnderway = false;
    _oldDragExtent = _dragExtent;
    if (_moveController!.isCompleted) {
      _handleMoveCompleted();
      return;
    }

    // TODO: short Swipe threshold, long Swipe threshold 분기 방어 코드 필
    // short에 걸리는 경우 stop(), long에 걸리는 경우 삭제 swipe & reszie animation

    // if (!_moveController!.isDismissed) {
    //   if (_moveController!.value < _kSwipeThreshold) {
    //     _moveController!.reverse();
    //   } else {
    //     _moveController!.forward();
    //   }
    // }

    // TODO: short Swipe threshold, long Swipe threshold 분기 방어 코드 필
    // short에 걸리는 경우 stop(), long에 걸리는 경우 삭제 swipe & reszie animation

    if (_swipeThresholdReached == SwipeType.short) {
      _moveController!.stop();
    } else {
      _moveController!.forward();
    }
    setState(() {
      _updateMoveAnimation();
    });
  }

  Future<void> _handleMoveCompleted() async {
    if ((widget.swipeThresholds[_swipeThresholdReached] ?? _kSwipeThreshold) >=
        1.0) {
      _moveController!.reverse();
      return;
    }
    if (_swipeDirection == SwipeDirection.right) {
      widget.onSwiped?.call(_swipeDirection);
      return;
    }
    final bool result = await _confirmStartResizeAnimation();
    if (mounted) {
      if (result) {
        _startResizeAnimation();
      } else {
        _moveController!.reverse();
      }
    }
  }

  void _handleSwipeUpdateValueChanged() {
    final SwipeType oldSwipeThresholdReached = _swipeThresholdReached;
    SwipeType newSwipeThresholdReached = SwipeType.none;
    // print('now swipeType: $_swipeThresholdReached');
    // if (widget.swipeThresholds[_swipeDirection] == null) {
    //   _swipeThresholdReached = SwipeType.none;
    // } else if (_moveController!.value > _kSwipeThreshold) {
    //   _swipeThresholdReached = SwipeType.long;
    // } else {
    //   _swipeThresholdReached = SwipeType.short;
    // }

    if (_moveController!.value > _kLongSwipeThreshold) {
      newSwipeThresholdReached = SwipeType.long;
    } else {
      newSwipeThresholdReached = SwipeType.short;
    }

    if (widget.onUpdate != null) {
      late final SwipeUpdateDetails details;
      details = SwipeUpdateDetails(
          direction: _swipeDirection,
          reached: _swipeThresholdReached,
          previousReached: oldSwipeThresholdReached);
      widget.onUpdate!(details);
    } else {
      setState(() {
        _swipeThresholdReached = newSwipeThresholdReached;
      });
    }
  }

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign;
    _moveAnimation = _moveController!.drive(Tween<Offset>(
        begin: Offset.zero, end: Offset(end, widget.crossAxisEndOffset)));
  }

  Future<void> _handleSwipeStatusChanged(AnimationStatus status) async {
    if (status == AnimationStatus.completed && !_dragUnderway) {
      await _handleMoveCompleted();
    }
    if (mounted) {
      updateKeepAlive();
    }
  }

  Future<bool> _confirmStartResizeAnimation() async {
    // 삭제 시 리스트 재정렬 이벤트 실행 확인
    // 삭제 행위가 아니라면 이벤트를 발생시키지 않는다.

    _confirming = true;
    final SwipeDirection direction = _swipeDirection;
    final SwipeType swipeType = _swipeThresholdReached;

    try {
      if (widget.confirmSwipe != null) {
        return await widget.confirmSwipe!(direction, swipeType) ?? false;
      }
      if (direction == SwipeDirection.left && swipeType == SwipeType.long) {
        return true;
      }
    } finally {
      _confirming = false;
    }
    return false;
  }

  void _startResizeAnimation() {
    if (widget.resizeDuration == null) {
      if (widget.onSwiped != null) {
        final SwipeDirection direction = _swipeDirection;
        widget.onSwiped!(direction);
      }
    } else {
      _resizeController =
          AnimationController(duration: widget.resizeDuration, vsync: this)
            ..addListener(_handleResizeProgressChanged)
            ..addStatusListener((AnimationStatus status) => updateKeepAlive());
      _resizeController!.forward();
      setState(() {
        _sizePriorToCollapse = context.size;
        _resizeAnimation = _resizeController!
            .drive(
              CurveTween(
                curve: _kResizeTimeCurve,
              ),
            )
            .drive(
              Tween<double>(
                begin: 1.0,
                end: 0.0,
              ),
            );
      });
    }
  }

  void _handleResizeProgressChanged() {
    if (_resizeController!.isCompleted) {
      widget.onSwiped?.call(_swipeDirection);
    } else {
      widget.onResize?.call();
    }
  }

  List? get iconButtons => _getIconButtons();

  List? _getIconButtons() {
    if (widget.icons == null) {
      return null;
    }
    List _lists = [];
    for (int i = 0; i < widget.icons!.length; i++) {
      var iconData = _swipeThresholdReached == SwipeType.long
          ? widget.icons![i]
          : widget.icons!.reversed.toList()[i];

      // TODO: moveController value가 short 초과 long 미만인 상태라면 short 상태 포지셔닝 유지
      _lists.add(Positioned(
        right: _dragExtent.abs() * _moveController!.value * i,
        child: Visibility(
          visible:
              _swipeThresholdReached == SwipeType.short || iconData.isRemained,
          child: IconButton(
            icon: iconData.icon,
            onPressed: iconData.onPressed,
          ),
        ),
      ));
    }
    // for (final iconData in widget.icons!) {
    //   _lists.add(Positioned(
    //     right: _dragExtent.abs() * _moveController!.value,
    //     child: Visibility(
    //       visible:
    //           _swipeThresholdReached == SwipeType.short || iconData.isRemained,
    //       child: IconButton(
    //         icon: iconData.icon,
    //         onPressed: iconData.onPressed,
    //       ),
    //     ),
    //   ));
    // }
    return _lists;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget? background = widget.background;

    // TODO: background container가 있는 경우, 아이콘 처리
    if (widget.icons != null) {
      background ??= Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [
          ...?iconButtons,
        ],
      );
    }

    if (_resizeAnimation != null) {
      return SizeTransition(
        sizeFactor: _resizeAnimation!,
        axis: Axis.vertical,
        child: SizedBox(
          width: _sizePriorToCollapse!.width,
          height: _sizePriorToCollapse!.height,
        ),
      );
    }

    Widget content = SlideTransition(
      position: _moveAnimation,
      child: widget.child,
    );

    if (background != null) {
      content = Stack(
        children: <Widget>[
          Positioned.fill(
              child: ClipRect(
            clipper: _SwipeableClipper(
                axis: Axis.horizontal, moveAnimation: _moveAnimation),
            child: background,
          )),
          content
        ],
      );
    }

    return GestureDetector(
      onHorizontalDragStart: _hanldeDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      behavior: widget.behavior,
      dragStartBehavior: widget.dragStartBehavior,
      child: content,
    );
  }
}
