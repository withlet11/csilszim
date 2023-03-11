/*
 * vsop87.dart
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

import '../../../constants.dart';
import '../../../utilities/offset_3d.dart';
import '../../constants/common.dart';
import '../../constants/earth.dart';
import '../../coordinate_system/equatorial_coordinate.dart';

// The VSOP87 values of AU is: 1 AU = 149597870.691 km
// light speed: 299792.458 km/s
// 1 day = 86400 s
const auInKm = 149597870.691;
const lightDayInAu = auInKm / lightSpeed / 86400;

abstract class Vsop87 {
  var jd = 0.0;
  var heliocentric = Offset3D.zero;
  var geocentric = Offset3D.zero;
  var distanceFromEarth = 0.0;
  var phaseAngle = 0.0;

  double distanceInLd() => distanceFromEarth * lightDayInAu;

  void forceUpdate(double jd, Offset3D earthPosition) {
    this.jd = jd;
    heliocentric = calculatePosition(jd - distanceInLd());
    geocentric = heliocentric - earthPosition;
    distanceFromEarth = geocentric.distance();
    final distanceFromSun = heliocentric.distance();
    final betweenSunAndEarth = earthPosition.distance();
    final cosPhaseAngle = (distanceFromEarth * distanceFromEarth +
            distanceFromSun * distanceFromSun -
            betweenSunAndEarth * betweenSunAndEarth) /
        (2 * distanceFromEarth * distanceFromSun);
    phaseAngle = acos(cosPhaseAngle) * radInDeg;
  }

  void update(double jd, Offset3D earthPosition) {
    if ((this.jd - jd).abs() > distanceFromEarth / 86400 * 60) {
      forceUpdate(jd, earthPosition);
    }
  }

  Offset3D calculatePosition(double jd);

  Equatorial toEquatorial() {
    final x = geocentric.dx;
    final y = cosObliquity * geocentric.dy - sinObliquity * geocentric.dz;
    final z = sinObliquity * geocentric.dy + cosObliquity * geocentric.dz;
    final dec = atan2(z, sqrt(x * x + y * y));
    final ra = atan2(y, x);
    return Equatorial.fromRadians(dec: dec, ra: ra);
  }
}

/// Calculates Julian millennia reckoned from J2000
/// (2000-Jan-01-Sat 12:00:00 TT)
double jm2000(double jd) => (jd - 2451545) / 365250;
