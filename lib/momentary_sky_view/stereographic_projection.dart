/*
 * stereographic_projection.dart
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

import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../constants.dart';
import 'configs.dart';

class StereographicProjection {
  Horizontal _centerAltAz;
  double scale = initialScale;
  late double _sinCenterAlt;
  late double _cosCenterAlt;

  StereographicProjection(this._centerAltAz) {
    _sinCenterAlt = sin(_centerAltAz.alt);
    _cosCenterAlt = cos(_centerAltAz.alt);
  }

  Horizontal get centerAltAz => _centerAltAz;

  set centerAltAz(Horizontal horizontal) {
    _centerAltAz = horizontal;
    _sinCenterAlt = sin(_centerAltAz.alt);
    _cosCenterAlt = cos(_centerAltAz.alt);
  }

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

  Offset horizontalToXy(
      Horizontal horizontal, Offset center, double unitLength) {
    final sinAlt = sin(horizontal.alt);
    final cosAlt = cos(horizontal.alt);
    final distance = acos(sinAlt * _sinCenterAlt +
        cosAlt * _cosCenterAlt * cos(horizontal.az - _centerAltAz.az));
    final rotate = -atan2(
        sinAlt * _cosCenterAlt -
            cosAlt * _sinCenterAlt * cos(horizontal.az - _centerAltAz.az),
        cosAlt * sin(horizontal.az - _centerAltAz.az));
    return Offset.fromDirection(rotate, tan(distance / 2) * scale) *
            unitLength +
        center;
  }

  Horizontal xyToHorizontal(Offset offset) {
    final distance = atan(offset.distance / scale) * 2;
    final sinDistance = sin(distance);
    final cosDistance = cos(distance);
    final rotate = -offset.direction;
    final sinRotate = sin(rotate);
    final objectAltitude = asin(
        cosDistance * _sinCenterAlt + sinDistance * _cosCenterAlt * sinRotate);
    final objectAzimuth = (atan2(
                sinDistance * cos(rotate),
                cosDistance * _cosCenterAlt -
                    sinDistance * _sinCenterAlt * sinRotate) +
            _centerAltAz.az) %
        fullTurn;
    return Horizontal.fromRadians(alt: objectAltitude, az: objectAzimuth);
  }
}
