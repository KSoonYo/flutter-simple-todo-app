import 'dart:math';

import 'package:flutter/animation.dart';

class Shake extends Curve {
  @override
  double transformInternal(double t) {
    return sin(4 * 2 * pi * t);
  }
}
