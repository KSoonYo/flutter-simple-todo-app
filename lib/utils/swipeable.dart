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

// iconButton pressed callback
typedef EditPressedCallback = void Function();
typedef DeletePressedCallback = void Function();

typedef ConfirmSwipeCallback = Future<bool?> Function(
    SwipeDirection direction, SwipeType swipeType);

typedef BackgroundColor = Color;

enum SwipeDirection { left, right, up, down, none }

enum SwipeType { short, long, none }

class Swipeable extends StatefulWidget {
  const Swipeable(
      {super.key,
      required this.child,
      this.onUpdate,
      this.onResize,
      this.onSwiped,
      this.confirmSwipe,
      this.backgroundColor,
      this.icons,
      this.resizeDuration = const Duration(milliseconds: 300),
      this.swipeThresholds = const <SwipeType, double>{},
      this.movementDuration = const Duration(milliseconds: 200),
      this.crossAxisEndOffset = 0.0,
      this.dragStartBehavior = DragStartBehavior.start,
      this.behavior = HitTestBehavior.opaque,
      this.iconSize = 24,
      this.onEditPressed,
      this.onDeletePressed});

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
  final BackgroundColor? backgroundColor;
  final List<TrailingIconButton>? icons;
  final int iconSize;
  final EditPressedCallback? onEditPressed;
  final DeletePressedCallback? onDeletePressed;

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
      {required this.icon,
      this.onPressed,
      this.isRemained = true,
      this.iconSize = 24});

  final bool isRemained;
  final Icon icon;
  final int iconSize;
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
    //  0 <=  animation.value.dx < 1
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
  bool _isTurned = false;
  Size? _sizePriorToCollapse;
  SwipeType _swipeThresholdReached = SwipeType.none;

  SwipeDirection _extendToDirection(double extent) {
    if (extent == 0.0) return SwipeDirection.none;
    return extent > 0 ? SwipeDirection.right : SwipeDirection.left;
  }

  SwipeDirection get _swipeDirection => _extendToDirection(_dragExtent);
  SwipeDirection get _previousSwipeDirection =>
      _extendToDirection(_oldDragExtent);

  bool get _isActive {
    return _dragUnderway || _moveController!.isAnimating;
  }

  double get _overallDragExtent {
    final Size size = context.size!;
    return size.width;
  }

  int get _iconSize {
    return widget.iconSize;
  }

  List<TrailingIconButton> get _defaultIconButtons {
    return <TrailingIconButton>[
      TrailingIconButton(
          icon: const Icon(Icons.edit),
          iconSize: _iconSize,
          onPressed: () {
            widget.onEditPressed?.call();
            _moveController!.reverse();
          },
          isRemained: false),
      TrailingIconButton(
          icon: const Icon(Icons.delete),
          iconSize: _iconSize,
          onPressed: widget.onDeletePressed),
    ];
  }

  void _handleDragStart(DragStartDetails details) {
    if (_confirming) return;
    _dragUnderway = true;
    _isTurned = false;
    if (_oldDragExtent.abs() > 0 && _moveController!.value.abs() > 0) {
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
    if (!_isActive) return;
    final double delta = details.primaryDelta!;

    _oldDragExtent = _dragExtent;
    _dragExtent += delta;
    if (_swipeDirection != SwipeDirection.none &&
        _previousSwipeDirection != SwipeDirection.none &&
        !_isTurned) {
      _isTurned = _dragExtent.sign != _oldDragExtent.sign;
    }
    if (_swipeDirection == SwipeDirection.none) {
      return;
    }

    if (_swipeDirection == SwipeDirection.right) {
      _moveController!.value = 0;
    } else {
      _moveController!.value = _dragExtent.abs() / _overallDragExtent;
    }

    setState(() {
      _updateMoveAnimation();
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isActive || _moveController!.isAnimating) return;
    _dragUnderway = false;

    _handleMoveCompleted();

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
    double oldMoveControllerValue = _moveController!.value;
    if ((widget.swipeThresholds[_swipeThresholdReached] ?? _kSwipeThreshold) >=
        1.0) {
      _moveController!.reverse();
      return;
    }

    // drag를 long 이하로 한 경우, dragExtent와 moveController 값을 short 혹은 아이콘 박스 크기만큼 이동
    if (_moveController!.value > 0 &&
        _moveController!.value < _kLongSwipeThreshold) {
      _moveController!.value = _kSwipeThreshold;
      _dragExtent = _moveController!.value * _overallDragExtent * -1;
      _oldDragExtent = _dragExtent;
      return;
    }

    if (!_isTurned &&
        oldMoveControllerValue == 0.0 &&
        _swipeDirection == SwipeDirection.right) {
      widget.onSwiped?.call(_swipeDirection);
      return;
    }
    final bool result = await _confirmStartResizeAnimation();
    if (mounted) {
      if (result) {
        _startResizeAnimation();
      }
    }
  }

  void _handleSwipeUpdateValueChanged() {
    final SwipeType oldSwipeThresholdReached = _swipeThresholdReached;
    SwipeType newSwipeThresholdReached = SwipeType.none;

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
        widget.onSwiped?.call(_swipeDirection);
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

  List _getIconButtons(ThemeData theme, double screenSize) {
    List lists = [];
    double alpha = -_iconSize / 2;
    double offset = _moveAnimation.value.dx * screenSize;
    for (int i = 0; i < 2; i++) {
      var iconData = _defaultIconButtons.reversed.toList()[i];
      double left = screenSize + offset;
      double widgetLeftPos =
          screenSize - _iconSize * (i + 1) + alpha * (i * 2 + 2);
      Widget iconWidget = AnimatedPositioned(
        left: _swipeThresholdReached == SwipeType.long || left > widgetLeftPos
            ? left
            : widgetLeftPos,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 150),
        child: Visibility(
          visible:
              _swipeThresholdReached == SwipeType.short || iconData.isRemained,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _swipeThresholdReached == SwipeType.long
                    ? theme.colorScheme.onSurface.withOpacity(0.12)
                    : null),
            child: IconButton(
              icon: iconData.icon,
              iconSize: iconData.iconSize * 1.0,
              onPressed: iconData.onPressed,
            ),
          ),
        ),
      );
      lists.add(iconWidget);
    }

    return lists;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var theme = Theme.of(context);

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
    content = Stack(
      children: <Widget>[
        Positioned.fill(
            child: ClipRect(
          clipper: _SwipeableClipper(
              axis: Axis.horizontal, moveAnimation: _moveAnimation),
          child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.centerEnd,
              children: <Widget>[
                if (widget.backgroundColor != null)
                  Container(color: widget.backgroundColor),
                ..._getIconButtons(theme, MediaQuery.of(context).size.width),
              ]),
        )),
        content
      ],
    );

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      behavior: widget.behavior,
      dragStartBehavior: widget.dragStartBehavior,
      child: content,
    );
  }
}
