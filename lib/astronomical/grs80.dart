/*
 * grs80.dart
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

import 'package:csilszim/astronomical/coordinate_system/geographic_coordinate.dart';

import '../constants.dart';
import '../utilities/offset_3d.dart';

const _a = 6378137;
const _f = 1 / 298.257222101;
const _e2 = _f * (2 - _f);

class Grs80 {
  final double n, x, y, z, r;

  Grs80({
    required this.n,
    required this.x,
    required this.y,
    required this.z,
    required this.r,
  });

  factory Grs80.from(Geographic geographic) {
    final sinLat = sin(geographic.lat);
    final cosLat = cos(geographic.lat);
    final sinLong = sin(geographic.long);
    final cosLong = cos(geographic.long);
    final n = _a / sqrt(1 - _e2 * sinLat * sinLat) / 1000.0;
    final x = (n + geographic.h / 1000.0) * cosLat * cosLong;
    final y = (n + geographic.h / 1000.0) * cosLat * sinLong;
    final z = (n * (1 - _e2) + geographic.h / 1000) * sinLat;
    final r = sqrt(x * x + y * y + z * z);
    return Grs80(n: n, x: x, y: y, z: z, r: r);
  }

  Offset3D toTopocentric(Offset3D geocentric, int gmst) {
    final angle = gmst / 86400e6 * fullTurn;
    final cosAngle = cos(angle);
    final sinAngle = sin(angle);
    final equatorialX = cosAngle * x - sinAngle * y;
    final equatorialY = sinAngle * x + cosAngle * y;
    final equatorialZ = z;
    return Offset3D(
      geocentric.dx - equatorialX,
      geocentric.dy - equatorialY,
      geocentric.dz - equatorialZ,
    );
  }
}
