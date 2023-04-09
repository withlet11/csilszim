/*
 * horizontal_coordinate.dart
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

import '../../constants.dart';

/// A position in the horizontal coordinate system.
class Horizontal {
  /// [alt] & [az] are provided altitude and azimuth in radians. [az] is
  /// measured from the north.
  final double alt, az;

  const Horizontal.fromDegrees({required double alt, required double az})
      : alt = alt * degInRad,
        az = az * degInRad;

  const Horizontal.fromRadians({required this.alt, required this.az});

  double altInDegrees() => alt * radInDeg;

  double azInDegrees() => az * radInDeg;

  Horizontal operator -(Horizontal other) {
    var tempAlt = alt - other.alt;
    var tempAz = az - other.az;

    if (tempAlt > quarterTurn || tempAlt < -quarterTurn) {
      return this;
    }

    if (tempAz > fullTurn) {
      tempAz -= fullTurn;
    } else if (tempAz.isNegative) {
      tempAz += fullTurn;
    }
    return Horizontal.fromRadians(alt: tempAlt, az: tempAz);
  }
}
