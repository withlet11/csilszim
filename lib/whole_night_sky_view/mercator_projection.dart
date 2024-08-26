/*
 * mercator_projection.dart
 *
 * Copyright 2023-2024 Yasuhiro Yamakawa <withlet11@gmail.com>
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

import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../constants.dart';
import 'configs.dart';

class MercatorProjection {
  Equatorial centerEquatorial;
  double scale = initialScale;
  bool isSouthUp = false;

  MercatorProjection(this.centerEquatorial, this.isSouthUp);

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

  Offset convertToOffset(
      Equatorial equatorial, Offset centerOffset, double unitLength) {
    final scale2 = (isSouthUp ? -scale : scale) * unitLength;
    final viewCenter = Offset(-centerEquatorial.ra,
            -log(tan((quarterTurn + centerEquatorial.dec) / 2))) *
        scale2;
    return Offset(
                -equatorial.ra, -log(tan((quarterTurn + equatorial.dec) / 2))) *
            scale2 -
        viewCenter +
        centerOffset;
  }

  Equatorial convertToEquatorial(Offset offset) {
    final scale2 = isSouthUp ? -scale : scale;
    final centerOffset = Offset(-centerEquatorial.ra,
        -log(tan((quarterTurn + centerEquatorial.dec) / 2)));
    final dec =
        atan(exp(-offset.dy / scale2 - centerOffset.dy)) * 2 - quarterTurn;
    final ra = -offset.dx / scale2 - centerOffset.dx;
    return Equatorial.fromRadians(dec: dec, ra: ra);
  }

  double lengthOfFullTurn(double unitLength) => fullTurn * scale * unitLength;

  /// Returns a list of points on a circle.
  ///
  /// [angle] is the radius of the circle on the celestial sphere.
  /// The rotate angle is slight less than 2π. The start angle is [min] * 2π,
  /// if the declination of the view center is positive. If not, it is
  /// π + [min] * 2π. In the case that the view center is near the celestial
  /// pole, the circle is open.
  List<Offset> pointsOnCircle(Offset center, double unitLength, double angle) {
    final centerDec = centerEquatorial.dec;
    final centerRa = centerEquatorial.ra;

    final sinAngle = sin(angle);
    final cosAngle = cos(angle);
    final sinCenterDec = sin(centerDec);
    final cosCenterDec = cos(centerDec);
    final cosCenterDecCosAngle = cosCenterDec * cosAngle;
    final sinCenterDecSinAngle = sinCenterDec * sinAngle;
    final sinCenterDecCosAngle = sinCenterDec * cosAngle;
    final cosCenterDecSinAngle = cosCenterDec * sinAngle;

    final startPosition = centerDec.isNegative ? halfTurn : 0.0;
    const repetition = 90;
    const size = repetition + 1;
    var points = List.filled(size, Offset.zero);
    const min = 1.0e-10; // enough small
    const max = 1.0 - min;
    for (var i = 0; i < size; ++i) {
      final direction =
          (min + i / repetition * (max - min)) * fullTurn + startPosition;
      final Equatorial equatorial;
      final cosDirection = cos(direction);
      final ra = atan2(sinAngle * sin(direction),
              cosCenterDecCosAngle - sinCenterDecSinAngle * cosDirection) +
          centerRa;
      final dec =
          asin(sinCenterDecCosAngle + cosCenterDecSinAngle * cosDirection);
      equatorial = Equatorial.fromRadians(dec: dec, ra: ra);
      points[i] = convertToOffset(equatorial, center, unitLength);
    }
    return points;
  }
}
