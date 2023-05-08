/*
 * moon.dart
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

import 'package:csilszim/astronomical/astronomical_object/astronomical_object.dart';
import 'package:csilszim/astronomical/constants/common.dart';
import 'package:csilszim/astronomical/constants/earth.dart';
import 'package:csilszim/astronomical/orbit_calculation/elp82b2.dart';
import 'package:csilszim/constants.dart';

import '../../utilities/offset_3d.dart';
import '../coordinate_system/equatorial_coordinate.dart';
import '../grs80.dart';
import '../time_model.dart';
import 'sun.dart';

class Moon implements AstronomicalObject {
  Elp82b2 elp82b2;
  Grs80? observationPosition;
  TimeModel? timeModel;
  static const radius = 1737.4;
  static const absoluteMagnitude = 0.28;
  var magnitude = 0.0;
  var phaseAngle = 0.0;
  var tilt = 0.0;
  var apparentRadius = 0.5 * degInRad;

  Moon(this.elp82b2, [this.observationPosition, this.timeModel]);

  @override
  var heliocentric = Offset3D.zero;
  @override
  var geocentric = Offset3D.zero;

  @override
  var equatorial = const Equatorial.fromRadians(dec: 0.0, ra: 0.0);

  void update(TimeModel timeModel, Offset3D earthPosition, Sun sun) {
    this.timeModel = timeModel;
    geocentric = elp82b2.calculate(timeModel.jd);
    heliocentric = geocentric! + earthPosition * auInKm;
    _updateEquatorial();
    _updatePhaseAngleAndTilt(earthPosition, sun);
  }

  void _updateEquatorial() {
    if (timeModel != null) {
      final x = geocentric!.dx;
      final y = geocentric!.dy * cosObliquity - geocentric!.dz * sinObliquity;
      final z = geocentric!.dy * sinObliquity + geocentric!.dz * cosObliquity;
      final geocentricEquatorial = Offset3D(x, y, z);
      final topocentric = observationPosition?.toTopocentric(
              geocentricEquatorial, timeModel!.gmst) ??
          geocentricEquatorial;
      final dec = atan(topocentric.dz /
          sqrt(topocentric.dx * topocentric.dx +
              topocentric.dy * topocentric.dy));
      final ra = atan2(topocentric.dy, topocentric.dx);
      equatorial = Equatorial.fromRadians(dec: dec, ra: ra);
    } else {
      equatorial = const Equatorial.fromRadians(dec: 0.0, ra: 0.0);
    }
  }

  void _updatePhaseAngleAndTilt(Offset3D earthPosition, Sun sun) {
    final distanceFromEarth = geocentric!.distance();
    final distanceFromSun = heliocentric!.distance();
    final betweenSunAndEarth = earthPosition.distance() * auInKm;
    final cosPhaseAngle = (distanceFromEarth * distanceFromEarth +
            distanceFromSun * distanceFromSun -
            betweenSunAndEarth * betweenSunAndEarth) /
        (2 * distanceFromEarth * distanceFromSun);

    final sunDec = sun.equatorial.dec;
    final sunRa = sun.equatorial.ra;
    final moonEquatorial = equatorial;
    final moonDec = moonEquatorial.dec;
    final moonRa = moonEquatorial.ra;

    // E: Elongation between the Sun and the Moon.
    final cosE = sin(moonDec) * sin(sunDec) +
        cos(moonDec) * cos(sunDec) * cos(moonRa - sunRa);
    final sinE = sqrt(1 - cosE * cosE);

    // T: Tilt of the Moon phase
    final sinT = sinE * cos(sunDec) / sin(moonRa - sunRa);

    if ((moonRa - sunRa) % fullTurn < halfTurn) {
      phaseAngle = fullTurn - acos(cosPhaseAngle);
    } else {
      phaseAngle = acos(cosPhaseAngle);
    }
    tilt = asin(sinT);
    apparentRadius = atan(radius / distanceFromEarth);

    // http://astro.if.ufrgs.br/trigesf/position.html#15
    final fv = (phaseAngle > halfTurn ? fullTurn - phaseAngle : phaseAngle) * radInDeg;
    magnitude = absoluteMagnitude +
        5 * log(1.0 * 0.00257) * log10e +
        0.026 * fv +
        4e-9 * pow(fv, 4);
  }
}
