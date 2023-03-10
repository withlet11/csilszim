/*
 * mercator_projection.dart
 *
 * Copyright 2023 Yasuhiro Yamakawa <withlet11@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import 'dart:math';
import 'dart:ui';

import 'package:csilszim/constants.dart';

import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import 'configs.dart';

class MercatorProjection {
  Equatorial centerEquatorial;
  double scale = initialScale;

  MercatorProjection(this.centerEquatorial);

  void zoom(double t) {
    scale = max(min(scale * pow(2, t), maxScale), 1);
  }

  void zoomIn([double t = 0.5]) {
    scale *= max(pow(2, t), 1);
    if (scale > maxScale) scale = maxScale;
  }

  void zoomOut([double t = 0.5]) {
    scale /= max(pow(2, t), minScale);
    if (scale < minScale) scale = minScale;
  }

  Offset equatorialToXy(
      Equatorial equatorial, Offset centerOffset, double unitLength) {
    final viewCenter = Offset(-centerEquatorial.ra,
            -log(tan((quarterTurn + centerEquatorial.dec) / 2))) *
        (scale * unitLength);
    return Offset(
                -equatorial.ra, -log(tan((quarterTurn + equatorial.dec) / 2))) *
            (scale * unitLength) -
        viewCenter +
        centerOffset;
  }

  Equatorial xyToEquatorial(Offset offset) {
    final centerOffset = Offset(centerEquatorial.ra,
        -log(tan((quarterTurn + centerEquatorial.dec) / 2)));
    final dec =
        atan(exp(-offset.dy / scale - centerOffset.dy)) * 2 - quarterTurn;
    final ra = -offset.dx / scale - centerOffset.dx;
    return Equatorial.fromRadians(dec: dec, ra: ra);
  }

  double lengthOfFullTurn(unitLength) => fullTurn * scale * unitLength;
}
