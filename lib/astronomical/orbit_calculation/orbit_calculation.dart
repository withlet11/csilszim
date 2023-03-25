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

class OrbitCalculationWithPerihelionPassage {
  final double t;

  const OrbitCalculationWithPerihelionPassage._internal(this.t);

  factory OrbitCalculationWithPerihelionPassage(TimeModel timeModel) {
    final t = timeModel.jd;
    return OrbitCalculationWithPerihelionPassage._internal(t);
  }

  Offset3D calculatePosition(OrbitalElementWithPerihelionPassage object) {
    final e = object.e(t);
    // if (e < 1) {
    const mu = 1.32712440018e20; // μ, gravitationParameter
    final a = object.a(t); // semi-major axis
    final aInM = a * auInKm * 1000;
    final period = sqrt(4 * pi * pi / mu * aInM * aInM * aInM) / 86400;
    final tp = object.tp(t);
    final ma = (t - tp) / period * fullTurn;
    final ea = calculateEccentricAnomaly(ma: ma, e: e);
    return calculatePositionFromEa(object, ea);
    /*
    } else if (e > 1) {
    // in case of hyperbolic trajectory
    // from Wikipedia
    const mu = 1.32712440018e20; // μ, gravitationParameter
    final a = object.a(t); // semi-major axis
    final e = object.e(t); // eccentricity
    final tp = object.tp(t); // perihelion passage
    // Barker's equation
    // t - τ = 1 / 2 * sqrt(l / GM) * (D + 1 / 3 * D ^ 3)
    // D = tan(ν / 2)
    // D ^ 3 + 3 * D + 2 * (τ - t) / 3 / sqrt(a * (e ^ 2 - 1) / µ) = 0
    //
    // Cardano's formula
    // x ^ 3 + p x + q = 0
    // x = (-q / 2 + sqrt((q / 2) ^ 2 + (p / 3) ^ 3)) ^ (1 / 3)
    //     + (-q / 2 - sqrt(q / 2) ^ 2 + (p / 3) ^ 3)) ^ (1 / 3)
    //
    // p = 3
    // q = 2 * (τ - t) / 3 / sqrt(a * (e ^ 2 - 1) / µ)

    const p = 3;
    final q =
        2 * (t - tp) / 3 / sqrt(a * auInKm * 1000 * (e * e - 1) / mu) / 86400;
    final q2 = q / 2;
    const p3 = p / 3;
    final d = pow(-q2 + sqrt(q2 * q2 + p3 * p3), 1 / 3) +
        pow(-q2 - sqrt(q2 * q2 + p3 * p3), 1 / 3);
    final ta = atan(d) * 2; // true anomaly

      // final ma = ((t - object.tp(t)) * object.n(t) * 86400 % 360) * degInRad;
      //
    }
     */
  }

  Offset3D calculatePositionFromEa(
      OrbitalElementWithPerihelionPassage object, double ea) {
    final e = object.e(t);
    final i = object.i(t) * degInRad;
    final a = object.a(t);
    final p = object.argPeri(t) * degInRad;
    final longNode = object.longNode(t) * degInRad;
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
