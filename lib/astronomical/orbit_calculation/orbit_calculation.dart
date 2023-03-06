/*
 * orbit_calculation.dart
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

import 'package:csilszim/constants.dart';

import '../../utilities/offset_3d.dart';
import '../constants/common.dart';
import '../time_model.dart';
import 'orbital_element.dart';

class OrbitCalculationWithMeanLongitude {
  final double t;

  const OrbitCalculationWithMeanLongitude._internal(this.t);

  factory OrbitCalculationWithMeanLongitude(TimeModel timeModel) {
    final t = (timeModel.jd - 2451545) / 36525;
    return OrbitCalculationWithMeanLongitude._internal(t);
  }

  Offset3D calculatePosition(OrbitalElementWithMeanLongitude planet) {
    final e = planet.e(t);
    final l = planet.l(t) * degInRad;
    final longPeri = planet.longPeri(t) * degInRad;
    final ma = (l - longPeri) % fullTurn;
    final ea = calculateEccentricAnomaly(ma: ma, e: e);
    return calculatePositionFromEa(planet, ea);
  }

  Offset3D calculatePositionFromEa(
      OrbitalElementWithMeanLongitude planet, double ea) {
    final e = planet.e(t);
    final i = planet.i(t) * degInRad;
    final a = planet.a(t);
    final longPeri = planet.longPeri(t) * degInRad;
    final longNode = planet.longNode(t) * degInRad;
    final p = longPeri - longNode;
    final b = a * sqrt(1 - e * e);

    final x = a * (cos(ea) - e);
    final y = b * sin(ea);

    return Offset3D(x, y, 0).rotateZ(p).rotateX(i).rotateZ(longNode);
  }
}

class OrbitCalculationWithMeanMotion {
  final double t;

  const OrbitCalculationWithMeanMotion._internal(this.t);

  factory OrbitCalculationWithMeanMotion(TimeModel timeModel) {
    final t = timeModel.jd;
    return OrbitCalculationWithMeanMotion._internal(t);
  }

  Offset3D calculatePosition(OrbitalElementWithMeanMotion planet) {
    final e = planet.e(t);
    final ma = ((t - planet.tp(t)) * planet.n(t) * 86400 % 360) * degInRad;
    final ea = calculateEccentricAnomaly(ma: ma, e: e);
    return calculatePositionFromEa(planet, ea);
  }

  Offset3D calculatePositionFromEa(
      OrbitalElementWithMeanMotion planet, double ea) {
    final e = planet.e(t);
    final i = planet.i(t) * degInRad;
    final a = planet.a(t) / auInKm;
    final p = planet.p(t) * degInRad;
    final longNode = planet.longNode(t) * degInRad;
    final b = a * sqrt(1 - e * e);

    final x = a * (cos(ea) - e);
    final y = b * sin(ea);

    return Offset3D(x, y, 0).rotateZ(p).rotateX(i).rotateZ(longNode);
  }
}

/// Returns eccentric anomaly calculated by Kepler's equation.
///
/// [e] Eccentricity
/// [ma] Mean anomaly
double calculateEccentricAnomaly({required double ma, required double e}) {
  var e1 = 0.0;
  while (true) {
    var e2 = e * sin(e1 + ma);
    if ((e2 - e1).abs() > 1.0e-5) {
      e1 = e2;
    } else {
      return e2 + ma;
    }
  }
}
