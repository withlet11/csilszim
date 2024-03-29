/*
 * geographic_coordinate.dart
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

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../utilities/sexagesimal_angle.dart';

/// A position in the geographic coordinate system.
@immutable
class Geographic {
  /// [lat] & [long] are provided latitude and longitude in radians.
  final double lat, long, h;

  const Geographic.fromDegrees(
      {required double lat, required double long, this.h = 164.0})
      : lat = lat * degInRad,
        long = long * degInRad;

  const Geographic.fromRadians(
      {required this.lat, required this.long, this.h = 0.0});

  double latInDegrees() => lat / degInRad;

  double longInDegrees() => long / degInRad;

  String latToString() => DmsAngle.fromDegrees(latInDegrees()).toDmsWithNS();

  String longToString() => DmsAngle.fromDegrees(longInDegrees()).toDmsWithEW();
}
