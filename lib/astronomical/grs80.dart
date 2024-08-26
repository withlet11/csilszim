/*
 * grs80.dart
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

import 'package:csilszim/astronomical/coordinate_system/geographic_coordinate.dart';
import 'package:vector_math/vector_math_64.dart';

import '../constants.dart';

const _a = 6378137;
const _f = 1 / 298.257222101;
const _e2 = _f * (2 - _f);

class Grs80 {
  final double n;
  final Vector3 xyz;

  const Grs80({required this.n, required this.xyz});

  factory Grs80.fromGeographic(Geographic geographic) {
    final sinLat = sin(geographic.lat);
    final cosLat = cos(geographic.lat);
    final sinLong = sin(geographic.long);
    final cosLong = cos(geographic.long);
    final n = _a / sqrt(1 - _e2 * sinLat * sinLat) / 1000.0;
    final xyz = Vector3(
        (n + geographic.h / 1000.0) * cosLat * cosLong,
        (n + geographic.h / 1000.0) * cosLat * sinLong,
        (n * (1 - _e2) + geographic.h / 1000) * sinLat);
    return Grs80(n: n, xyz: xyz);
  }

  Vector3 toTopocentric(Vector3 geocentric, int gmst) {
    final angle = gmst / 86400e6 * fullTurn;
    final matrix = Matrix4.rotationZ(angle);
    final vector = matrix.transformed3(xyz);
    return geocentric - vector;
  }
}
