/*
 * deep_sky_object.dart
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

import '../../utilities/offset_3d.dart';
import '../coordinate_system/equatorial_coordinate.dart';
import 'astronomical_object.dart';

class DeepSkyObject implements AstronomicalObject {
  final int? messierNumber;
  final int? ngcNumber;
  final Equatorial position;
  final String magnitude;
  final double? majorAxisSize;
  final double? minorAxisSize;
  final double? orientationAngle;
  final String type;
  final List<String> name;

  const DeepSkyObject({
    this.messierNumber,
    this.ngcNumber,
    required this.position,
    required this.magnitude,
    this.majorAxisSize,
    this.minorAxisSize,
    this.orientationAngle,
    required this.type,
    this.name = const [],
  });

  @override
  Equatorial get equatorial => position;

  @override
  Offset3D? get heliocentric => null;

  @override
  Offset3D? get geocentric => null;
}
