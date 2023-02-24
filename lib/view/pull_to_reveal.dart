import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    required this.revealableChild,
    required this.child,
    this.onReveal,
    this.onHide,
    this.controller,
  });

  final Widget revealableChild;
  final Widget child;
  final PullToRevealController? controller;
  final VoidCallback? onReveal;
  final VoidCallback? onHide;

  @override
  State<PullToReveal> createState() => _PullToRevealState();
}

class _PullToRevealState extends State<PullToReveal>
    with SingleTickerProviderStateMixin {
  final GlobalKey _revealableChildKey = GlobalKey();
  late PullToRevealController _controller;
  late AnimationController _animationController;

  late Animation<Offset> _revealAnimation;
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
    _revealAnimation = _animationController
        .drive(CurveTween(curve: Curves.fastOutSlowIn))
        .drive(Tween(begin: const Offset(0, -1), end: const Offset(0, 0)));
    _barrierColorAnimation = _animationController.drive(
      ColorTween(
        begin: Colors.transparent,
        end: Colors.black,
      ),
    );

    _controller.addListener(() {
      switch (_controller.value) {
        case RevealState.revealed:
          widget.onReveal?.call();
          _animationController.forward();
          break;
        case RevealState.hidden:
          widget.onHide?.call();
          _animationController.reverse();
          break;
        default:
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (details) => _handleDragStart(details),
      onVerticalDragUpdate: (details) => _handleDragUpdate(details),
      onVerticalDragEnd: (details) => _handleDragEnd(details),
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_barrierVisible)
            AnimatedModalBarrier(
              color: _barrierColorAnimation,
              onDismiss: () => _controller.value = RevealState.hidden,
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

  void _handleDragStart(DragStartDetails details) {
    _dragStartDetails = details;

    if (_controller.value == RevealState.hidden) HapticFeedback.lightImpact();

    _controller.value = RevealState.revealing;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta =
        details.globalPosition.dy - _dragStartDetails!.globalPosition.dy;
    final height = _revealableChildKey.currentContext?.size?.height;

    if (height == null) return;

    _animationController.value = delta / height;
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
