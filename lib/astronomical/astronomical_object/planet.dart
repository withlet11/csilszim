/*
 * planet.dart
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
import '../coordinate_system/equatorial_coordinate.dart';
import '../orbit_calculation/orbital_element.dart';
import '../orbit_calculation/vsop87/jupiter.dart';
import '../orbit_calculation/vsop87/mars.dart';
import '../orbit_calculation/vsop87/mercury.dart';
import '../orbit_calculation/vsop87/neptune.dart';
import '../orbit_calculation/vsop87/saturn.dart';
import '../orbit_calculation/vsop87/uranus.dart';
import '../orbit_calculation/vsop87/venus.dart';
import '../orbit_calculation/vsop87/vsop87.dart';
import 'astronomical_object.dart';

class Planet implements AstronomicalObject {
  final Vsop87? vsop87;
  final OrbitalElementWithMeanLongitude? orbitalElement;
  final double radius;
  final double albedo;
  final double absoluteMagnitude;
  final double Function(Vsop87) phaseIntegral;
  final String name;

  const Planet({
    this.vsop87,
    this.orbitalElement,
    required this.radius,
    required this.albedo,
    required this.absoluteMagnitude,
    required this.phaseIntegral,
    required this.name,
  });

  Planet.mercury(double jd, Offset3D heliocentric)
      : vsop87 = Vsop87Mercury(jd, heliocentric),
        orbitalElement = null,
        radius = 2439.7,
        albedo = 0.142,
        absoluteMagnitude = -0.613,
        phaseIntegral = phaseIntegralOfMercury,
        name = "Mercury";

  Planet.venus(double jd, Offset3D heliocentric)
      : vsop87 = Vsop87Venus(jd, heliocentric),
        orbitalElement = null,
        radius = 6051.8,
        albedo = 0.689,
        absoluteMagnitude = -4.384,
        phaseIntegral = phaseIntegralOfVenus,
        name = "Venus";

  Planet.mars(double jd, Offset3D heliocentric)
      : vsop87 = Vsop87Mars(jd, heliocentric),
        orbitalElement = null,
        radius = 3389.5,
        albedo = 0.17,
        absoluteMagnitude = -1.601,
        phaseIntegral = phaseIntegralOfMars,
        name = "Mars";

  Planet.jupiter(double jd, Offset3D heliocentric)
      : vsop87 = Vsop87Jupiter(jd, heliocentric),
        orbitalElement = null,
        radius = 69911,
        albedo = 0.538,
        absoluteMagnitude = -9.395,
        phaseIntegral = phaseIntegralOfJupiter,
        name = "Jupiter";

  Planet.saturn(double jd, Offset3D heliocentric)
      : vsop87 = Vsop87Saturn(jd, heliocentric),
        orbitalElement = null,
        radius = 58232,
        albedo = 0.499,
        absoluteMagnitude = -8.914,
        phaseIntegral = phaseIntegralOfSaturn,
        name = "Saturn";

  Planet.uranus(double jd, Offset3D heliocentric)
      : vsop87 = Vsop87Uranus(jd, heliocentric),
        orbitalElement = null,
        radius = 25362,
        albedo = 0.488,
        absoluteMagnitude = -7.110,
        phaseIntegral = phaseIntegralOfUranus,
        name = "Uranus";

  Planet.neptune(double jd, Offset3D heliocentric)
      : vsop87 = Vsop87Neptune(jd, heliocentric),
        orbitalElement = null,
        radius = 24622,
        albedo = 0.442,
        absoluteMagnitude = -7,
        phaseIntegral = phaseIntegralOfNeptune,
        name = "Neptune";

  @override
  Equatorial toEquatorial(double jd, Offset3D earthPosition) {
    if (vsop87 != null) {
      vsop87!.update(jd, earthPosition);
      return vsop87!.toEquatorial();
    }
    return const Equatorial.fromRadians(dec: 0, ra: 0);
  }

  @override
  Offset3D? toHeliocentric(double jd) {
    if (vsop87 != null) {
      vsop87!.update(jd, vsop87!.heliocentric - vsop87!.geocentric);
      return vsop87!.heliocentric;
    }
    return null;
  }

  @override
  Offset3D? toGeocentric(double jd, Offset3D earthPosition) {
    if (vsop87 != null) {
      vsop87!.update(jd, earthPosition);
      return vsop87!.geocentric;
    }
    return null;
  }

  double? magnitude() {
    if (vsop87 == null) return null;
    final fromEarth = vsop87!.distanceFromEarth;
    final fromSun = vsop87!.heliocentric.distance();
    return absoluteMagnitude +
        5 * log(fromEarth * fromSun) * log10e +
        phaseIntegral(vsop87!);
  }
}

// See https://en.wikipedia.org/wiki/Absolute_magnitude
double phaseIntegralOfPlanets(Vsop87 vsop87) {
  final phaseAngle = vsop87.phaseAngle;
  return -2.5 *
      log(2 /
          3 *
          ((1 - phaseAngle / 180) * cos(phaseAngle * degInRad) +
              1 / pi * sin(phaseAngle * degInRad))) *
      log10e;
}

double phaseIntegralOfMercury(Vsop87 vsop87) {
  final angle = vsop87.phaseAngle;
  return angle *
      (6.328e-2 +
          angle *
              (-1.6336e-3 +
                  angle *
                      (3.3644e-5 +
                          angle *
                              (-3.4265e-7 +
                                  angle * (1.6893e-9 + angle * -3.0334e-12)))));
}

double phaseIntegralOfVenus(Vsop87 vsop87) {
  final phaseAngle = vsop87.phaseAngle;
  return phaseAngle <= 163.7
      ? phaseAngle *
          (-1.044e-3 +
              phaseAngle *
                  (3.687e-4 + phaseAngle * (-2.814e-6 + phaseAngle * 8.938e-9)))
      : 240.44228 + phaseAngle * (-2.81914 + phaseAngle * 8.39034e-3);
}

double phaseIntegralOfMars(Vsop87 vsop87) {
  final phaseAngle = vsop87.phaseAngle;
  return phaseAngle <= 50
      ? phaseAngle * (2.267e-2 + phaseAngle * -1.302e-4)
      : phaseAngle <= 120
          ? 1.234 + phaseAngle * (-2.573e-2 + phaseAngle * 3.445e-4)
          : phaseIntegralOfPlanets(vsop87);
}

double phaseIntegralOfJupiter(Vsop87 vsop87) {
  final phaseAngle = vsop87.phaseAngle;
  if (phaseAngle <= 12) return phaseAngle * (-3.7e-4 + phaseAngle * 6.16e-4);
  final turn = phaseAngle / 180;
  return -0.033 -
      2.5 *
          log(1 +
              turn *
                  (-1.507 +
                      turn *
                          (-0.363 +
                              turn *
                                  (-0.062 + turn * (2.809 + turn * -1.876))))) *
          log10e;
}

double phaseIntegralOfSaturn(Vsop87 vsop87) {
  final phaseAngle = vsop87.phaseAngle;
  return phaseAngle <= 6
      ? -0.036 + phaseAngle * (-3.7e-4 + phaseAngle * 6.16e-4)
      : phaseAngle < 150
          ? 0.026 +
              phaseAngle *
                  (2.466e-4 +
                      phaseAngle *
                          (2.672e-4 +
                              phaseAngle * (-1.505e-6 + 4.767e-9 * phaseAngle)))
          : phaseIntegralOfPlanets(vsop87);
}

double saturnRingAngle(Offset3D geocentric) {
  final distance = geocentric.distance();
  const northPoleOfSaturn = Offset3D(0.08547883186, 0.4624415234, 0.9407828048);
  final cosAngle = (geocentric.dx * northPoleOfSaturn.dx +
          geocentric.dy * northPoleOfSaturn.dy +
          geocentric.dz * northPoleOfSaturn.dz) /
      distance;
  return 90 - acos(cosAngle) * radInDeg;
}

double phaseIntegralOfUranus(Vsop87 vsop87) {
  final phaseAngle = vsop87.phaseAngle;
  return phaseAngle < 3.1
      ? phaseAngle * (6.587e-3 + phaseAngle * 1.045e-4)
      : phaseIntegralOfPlanets(vsop87);
}

double phaseIntegralOfNeptune(Vsop87 vsop87) {
  final phaseAngle = vsop87.phaseAngle;
  final jd = vsop87.jd;
  return (phaseAngle < 133 && jd > 2451545)
      ? phaseAngle * (7.944e-3 + phaseAngle * 9.617e-5)
      : phaseIntegralOfPlanets(vsop87);
}
