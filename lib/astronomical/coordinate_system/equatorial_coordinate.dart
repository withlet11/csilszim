/*
 * equatorial_coordinate.dart
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

/// A position in the equatorial coordinate system.
class Equatorial {
  /// [dec] & [ra] are provided declination and right ascension in radians.
  final double dec, ra;

  const Equatorial(
      {decSign = int,
      decDeg = int,
      decMin = int,
      decSec = double,
      raHour = int,
      raMin = int,
      raSec = double})
      : dec = (decSign * 2 - 1) *
            (decDeg + decMin / 60 + decSec / 3600) *
            degInRad,
        ra = (raHour + raMin / 60 + raSec / 3600) * hourInRad;

  const Equatorial.fromDegreesAndHours({dec = double, ra = double})
      : dec = dec * degInRad,
        ra = ra * hourInRad;

  const Equatorial.fromRadians({required this.dec, required this.ra});

  double decInDegrees() => dec / degInRad;

  double raInHours() => ra / hourInRad;
}
