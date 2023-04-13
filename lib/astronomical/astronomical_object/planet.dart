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

import '../../constants.dart';
import '../../utilities/offset_3d.dart';
import '../coordinate_system/ecliptic_coordinate.dart';
import '../coordinate_system/equatorial_coordinate.dart';
import '../orbit_calculation/orbit_calculation.dart';
import '../orbit_calculation/orbital_element.dart';
import '../orbit_calculation/vsop87/earth.dart';
import '../orbit_calculation/vsop87/jupiter.dart';
import '../orbit_calculation/vsop87/mars.dart';
import '../orbit_calculation/vsop87/mercury.dart';
import '../orbit_calculation/vsop87/neptune.dart';
import '../orbit_calculation/vsop87/saturn.dart';
import '../orbit_calculation/vsop87/uranus.dart';
import '../orbit_calculation/vsop87/venus.dart';
import '../orbit_calculation/vsop87/vsop87.dart';
import 'astronomical_object.dart';
import 'celestial_id.dart';

/*
https://ssd.jpl.nasa.gov/planets/approx_pos.html

Keplerian Elements and Rates
Table 1
Keplerian elements and their rates, with respect to the mean ecliptic and equinox of J2000, valid for the time-interval 1800 AD - 2050 AD.


               a              e               I                L            long.peri.      long.node.
           au, au/Cy     rad, rad/Cy     deg, deg/Cy      deg, deg/Cy      deg, deg/Cy     deg, deg/Cy
-----------------------------------------------------------------------------------------------------------
Mercury   0.38709927      0.20563593      7.00497902      252.25032350     77.45779628     48.33076593
          0.00000037      0.00001906     -0.00594749   149472.67411175      0.16047689     -0.12534081
Venus     0.72333566      0.00677672      3.39467605      181.97909950    131.60246718     76.67984255
          0.00000390     -0.00004107     -0.00078890    58517.81538729      0.00268329     -0.27769418
EM Bary   1.00000261      0.01671123     -0.00001531      100.46457166    102.93768193      0.0
          0.00000562     -0.00004392     -0.01294668    35999.37244981      0.32327364      0.0
Mars      1.52371034      0.09339410      1.84969142       -4.55343205    -23.94362959     49.55953891
          0.00001847      0.00007882     -0.00813131    19140.30268499      0.44441088     -0.29257343
Jupiter   5.20288700      0.04838624      1.30439695       34.39644051     14.72847983    100.47390909
         -0.00011607     -0.00013253     -0.00183714     3034.74612775      0.21252668      0.20469106
Saturn    9.53667594      0.05386179      2.48599187       49.95424423     92.59887831    113.66242448
         -0.00125060     -0.00050991      0.00193609     1222.49362201     -0.41897216     -0.28867794
Uranus   19.18916464      0.04725744      0.77263783      313.23810451    170.95427630     74.01692503
         -0.00196176     -0.00004397     -0.00242939      428.48202785      0.40805281      0.04240589
Neptune  30.06992276      0.00859048      1.77004347      -55.12002969     44.96476227    131.78422574
          0.00026291      0.00005105      0.00035372      218.45945325     -0.32241464     -0.00508664
------------------------------------------------------------------------------------------------------
EM Bary = Earth/Moon Barycenter
 */

abstract class Planet implements AstronomicalObject {
  abstract final String name;
  abstract final CelestialId id;
  var jd = 0.0;
  @override
  var heliocentric = Offset3D.zero;
  @override
  var geocentric = Offset3D.zero;
  var phaseAngle = 0.0;
  abstract final double radius;
  abstract final double albedo;
  abstract final double absoluteMagnitude;
  abstract final Offset3D Function(double jd) calculateWithVsop87;
  abstract final OrbitalElementWithMeanLongitude orbitalElement;

  void update(double jd, Offset3D earthPosition) {
    this.jd = jd;
    final orbitCalculation =
        OrbitCalculationWithMeanLongitude.fromJd(jd - distanceInLd());
    heliocentric = orbitCalculation.calculatePosition(orbitalElement);
    geocentric = heliocentric! - earthPosition;
    updatePhaseAngle(earthPosition);
  }

  void forceUpdateWithVsop87(double jd, Offset3D earthPosition) {
    this.jd = jd;
    heliocentric = calculateWithVsop87(jd - distanceInLd());
    geocentric = heliocentric! - earthPosition;
    updatePhaseAngle(earthPosition);
  }

  void updateWithVsop87(double jd, Offset3D earthPosition) {
    final distanceFromEarth = geocentric!.distance();
    if ((this.jd - jd).abs() > distanceFromEarth / 86400 * 60) {
      forceUpdateWithVsop87(jd, earthPosition);
    }
  }

  void updatePhaseAngle(Offset3D earthPosition) {
    final distanceFromEarth = geocentric!.distance();
    final distanceFromSun = heliocentric!.distance();
    final betweenSunAndEarth = earthPosition.distance();
    final cosPhaseAngle = (distanceFromEarth * distanceFromEarth +
            distanceFromSun * distanceFromSun -
            betweenSunAndEarth * betweenSunAndEarth) /
        (2 * distanceFromEarth * distanceFromSun);
    phaseAngle = acos(cosPhaseAngle) * radInDeg;
  }

  double phaseIntegral() {
    return -2.5 *
        log(2 /
            3 *
            ((1 - phaseAngle / 180) * cos(phaseAngle * degInRad) +
                1 / pi * sin(phaseAngle * degInRad))) *
        log10e;
  }

  @override
  Equatorial get equatorial {
    final ecliptic = Ecliptic.fromXyz(geocentric!);
    return ecliptic.toEquatorial();
  }

  double? magnitude() {
    final fromSun = heliocentric!.distance();
    final fromEarth = geocentric!.distance();
    return absoluteMagnitude +
        5 * log(fromEarth * fromSun) * log10e +
        phaseIntegral();
  }

  double distanceInLd() => geocentric!.distance() * auInLightDay;
}

class PlanetMercury extends Planet {
  @override
  final name = 'Mercury';
  @override
  final id = CelestialId.mercury;
  @override
  final radius = 2439.7;
  @override
  final albedo = 0.142;
  @override
  final absoluteMagnitude = -0.613;
  @override
  final calculateWithVsop87 = Vsop87Mercury.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 0.38709927 + 0.00000037 * t,
      e: (double t) => 0.20563593 + 0.00001906 * t,
      i: (double t) => 7.00497902 - 0.00594749 * t,
      l: (double t) => 252.25032350 + 149472.67411175 * t,
      longPeri: (double t) => 77.45779628 + 0.16047689 * t,
      longNode: (double t) => 48.33076593 - 0.12534081 * t);

  @override
  double phaseIntegral() {
    return phaseAngle *
        (6.328e-2 +
            phaseAngle *
                (-1.6336e-3 +
                    phaseAngle *
                        (3.3644e-5 +
                            phaseAngle *
                                (-3.4265e-7 +
                                    phaseAngle *
                                        (1.6893e-9 +
                                            phaseAngle * -3.0334e-12)))));
  }
}

class PlanetVenus extends Planet {
  @override
  final name = 'Venus';
  @override
  final id = CelestialId.venus;
  @override
  final radius = 6051.8;
  @override
  final albedo = 0.689;
  @override
  final absoluteMagnitude = -4.384;
  @override
  final calculateWithVsop87 = Vsop87Venus.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 0.72333566 + 0.00000390 * t,
      e: (double t) => 0.00677672 - 0.00004107 * t,
      i: (double t) => 3.39467605 - 0.00078890 * t,
      l: (double t) => 181.97909950 + 58517.81538729 * t,
      longPeri: (double t) => 131.60246718 + 0.00268329 * t,
      longNode: (double t) => 76.67984255 - 0.27769418 * t);

  @override
  double phaseIntegral() {
    return phaseAngle <= 163.7
        ? phaseAngle *
            (-1.044e-3 +
                phaseAngle *
                    (3.687e-4 +
                        phaseAngle * (-2.814e-6 + phaseAngle * 8.938e-9)))
        : 240.44228 + phaseAngle * (-2.81914 + phaseAngle * 8.39034e-3);
  }
}

class PlanetEarth extends Planet {
  @override
  final name = 'Earth';
  @override
  final id = CelestialId.earth;
  @override
  final radius = 6371.0;
  @override
  final albedo = 0.367;
  @override
  final absoluteMagnitude = -3.99;
  @override
  final calculateWithVsop87 = Vsop87Earth.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 1.00000261 + 0.00000562 * t,
      e: (double t) => 0.01671123 - 0.00004392 * t,
      i: (double t) => -0.00001531 - 0.01294668 * t,
      l: (double t) => 100.46457166 + 35999.37244981 * t,
      longPeri: (double t) => 102.93768193 + 0.32327364 * t,
      longNode: (double t) => 0.0 + 0.0 * t);

  @override
  double phaseIntegral() {
    return phaseAngle * (-1.060e-3 + phaseAngle * 2.054e-4);
  }
}

class PlanetMars extends Planet {
  @override
  final name = 'Mars';
  @override
  final id = CelestialId.mars;
  @override
  final radius = 3389.5;
  @override
  final albedo = 0.17;
  @override
  final absoluteMagnitude = -1.601;
  @override
  final calculateWithVsop87 = Vsop87Mars.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 1.52371034 + 0.00001847 * t,
      e: (double t) => 0.09339410 + 0.00007882 * t,
      i: (double t) => 1.84969142 - 0.00813131 * t,
      l: (double t) => -4.55343205 + 19140.30268499 * t,
      longPeri: (double t) => -23.94362959 + 0.44441088 * t,
      longNode: (double t) => 49.55953891 - 0.29257343 * t);

  @override
  double phaseIntegral() {
    return phaseAngle <= 50
        ? phaseAngle * (2.267e-2 + phaseAngle * -1.302e-4)
        : phaseAngle <= 120
            ? 1.234 + phaseAngle * (-2.573e-2 + phaseAngle * 3.445e-4)
            : super.phaseIntegral();
  }
}

class PlanetJupiter extends Planet {
  @override
  final name = 'Jupiter';
  @override
  final id = CelestialId.jupiter;
  @override
  final radius = 69911;
  @override
  final albedo = 0.538;
  @override
  final absoluteMagnitude = -9.395;
  @override
  final calculateWithVsop87 = Vsop87Jupiter.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 5.20288700 - 0.00011607 * t,
      e: (double t) => 0.04838624 - 0.00013253 * t,
      i: (double t) => 1.30439695 - 0.00183714 * t,
      l: (double t) => 34.39644051 + 3034.74612775 * t,
      longPeri: (double t) => 14.72847983 + 0.21252668 * t,
      longNode: (double t) => 100.47390909 + 0.20469106 * t);

  @override
  double phaseIntegral() {
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
                                    (-0.062 +
                                        turn * (2.809 + turn * -1.876))))) *
            log10e;
  }
}

class PlanetSaturn extends Planet {
  @override
  final name = 'Saturn';
  @override
  final id = CelestialId.saturn;
  @override
  final radius = 58232;
  @override
  final albedo = 0.499;
  @override
  final absoluteMagnitude = -8.914;
  @override
  final calculateWithVsop87 = Vsop87Saturn.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 9.53667594 - 0.00125060 * t,
      e: (double t) => 0.05386179 - 0.00050991 * t,
      i: (double t) => 2.48599187 + 0.00193609 * t,
      l: (double t) => 49.95424423 + 1222.49362201 * t,
      longPeri: (double t) => 92.59887831 - 0.41897216 * t,
      longNode: (double t) => 113.66242448 - 0.28867794 * t);

  @override
  double phaseIntegral() {
    return phaseAngle <= 6
        ? -0.036 + phaseAngle * (-3.7e-4 + phaseAngle * 6.16e-4)
        : phaseAngle < 150
            ? 0.026 +
                phaseAngle *
                    (2.466e-4 +
                        phaseAngle *
                            (2.672e-4 +
                                phaseAngle *
                                    (-1.505e-6 + 4.767e-9 * phaseAngle)))
            : super.phaseIntegral();
  }

  double saturnRingAngle() {
    final distance = geocentric!.distance();
    const northPoleOfSaturn =
        Offset3D(0.08547883186, 0.4624415234, 0.9407828048);
    final cosAngle = (geocentric!.dx * northPoleOfSaturn.dx +
            geocentric!.dy * northPoleOfSaturn.dy +
            geocentric!.dz * northPoleOfSaturn.dz) /
        distance;
    return 90 - acos(cosAngle) * radInDeg;
  }
}

class PlanetUranus extends Planet {
  @override
  final name = 'Uranus';
  @override
  final id = CelestialId.uranus;
  @override
  final radius = 25362;
  @override
  final albedo = 0.488;
  @override
  final absoluteMagnitude = -7.110;
  @override
  final calculateWithVsop87 = Vsop87Uranus.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 19.18916464 - 0.00196176 * t,
      e: (double t) => 0.04725744 - 0.00004397 * t,
      i: (double t) => 0.77263783 - 0.00242939 * t,
      l: (double t) => 313.23810451 + 428.48202785 * t,
      longPeri: (double t) => 170.95427630 + 0.40805281 * t,
      longNode: (double t) => 74.01692503 + 0.04240589 * t);

  @override
  double phaseIntegral() {
    return phaseAngle < 3.1
        ? phaseAngle * (6.587e-3 + phaseAngle * 1.045e-4)
        : super.phaseIntegral();
  }
}

class PlanetNeptune extends Planet {
  @override
  final name = 'Neptune';
  @override
  final id = CelestialId.neptune;
  @override
  final radius = 24622;
  @override
  final albedo = 0.442;
  @override
  final absoluteMagnitude = -7;
  @override
  final calculateWithVsop87 = Vsop87Neptune.calculatePosition;
  @override
  final orbitalElement = OrbitalElementWithMeanLongitude(
      a: (double t) => 30.06992276 + 0.00026291 * t,
      e: (double t) => 0.00859048 + 0.00005105 * t,
      i: (double t) => 1.77004347 + 0.00035372 * t,
      l: (double t) => -55.12002969 + 218.45945325 * t,
      longPeri: (double t) => 44.96476227 - 0.32241464 * t,
      longNode: (double t) => 131.78422574 - 0.00508664 * t);

  @override
  double phaseIntegral() {
    return (phaseAngle < 133 && jd > 2451545)
        ? phaseAngle * (7.944e-3 + phaseAngle * 9.617e-5)
        : super.phaseIntegral();
  }
}
