import 'package:flutter/material.dart';

class VerticalPullable extends StatelessWidget {
  static const _defaultVelocityThreshold = 400.0;

  const VerticalPullable({
    super.key,
    this.velocityThreshold = _defaultVelocityThreshold,
    this.onPullDown,
    this.onPullUp,
    required this.child,
  });

  final double velocityThreshold;
  final void Function()? onPullDown;
  final void Function()? onPullUp;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: onPullDown != null || onPullUp != null
          ? (details) {
              final velocity = details.primaryVelocity ?? 0;

              if (velocity.abs() < velocityThreshold) return;

              if (velocity > 0) {
                onPullDown?.call();
              } else {
                onPullUp?.call();
              }
            }
          : null,
      child: child,
    );
  }
}
