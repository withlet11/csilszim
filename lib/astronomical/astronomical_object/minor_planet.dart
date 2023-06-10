/*
 * minor_planet.dart
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

import 'package:csilszim/astronomical/orbit_calculation/orbit_calculation.dart';
import 'package:vector_math/vector_math_64.dart';

import '../coordinate_system/ecliptic_coordinate.dart';
import '../coordinate_system/equatorial_coordinate.dart';
import '../orbit_calculation/orbital_element.dart';
import '../orbit_calculation/vsop87/vsop87.dart';
import 'astronomical_object.dart';
import 'celestial_id.dart';

abstract class MinorPlanet implements AstronomicalObject {
  abstract final String name;
  abstract final CelestialId id;
  var jd = 0.0;
  @override
  var heliocentric = Vector3.zero();
  @override
  var geocentric = Vector3.zero();
  var phaseAngle = 0.0;
  abstract final OrbitalElementWithMeanMotion orbitalElement;

  void update(double jd, Vector3 earthPosition) {
    this.jd = jd;
    final calculation =
        OrbitCalculationWithMeanMotion.fromJd(jd - distanceInLd());
    heliocentric = calculation.calculatePosition(orbitalElement);
    geocentric = heliocentric! - earthPosition;
  }

  @override
  Equatorial get equatorial {
    final ecliptic = Ecliptic.fromXyz(geocentric!);
    return ecliptic.toEquatorial();
  }

  double distanceInLd() => geocentric!.length * auInLightDay;
}

class DwarfPlanetCeres extends MinorPlanet {
  @override
  final name = 'Ceres';
  @override
  final id = CelestialId.ceres;
  @override

  final orbitalElement = OrbitalElementWithMeanMotion(
      a: (double t) => 413584014.351947 + 0.148082856990999 * t,
      e: (double t) => 0.107298605591374 - 0.0000000120198222603856 * t,
      i: (double t) => 11.782305750786 - 0.000000484373910411908 * t,
      tp: (double t) =>
          2452155.33370239 +
          0.000422287693029518 * t +
          1681.23133223247 * ((t - 2452350) ~/ 1681.23133223247),
      n: (double t) => 0.00000248159961949641 - 1.32841567817051E-15 * t,
      p: (double t) => -141.930299608497 + 0.0000875010767260137 * t,
      longNode: (double t) => 180.865343168561 - 0.0000409185674687272 * t);
}

class DwarfPlanetPluto extends MinorPlanet {
  @override
  final name = 'Pluto';
  @override
  final id = CelestialId.pluto;
  @override

  final orbitalElement = OrbitalElementWithMeanMotion(
      a: (double t) => 5936109348.80781 - 7.96898499877203 * t,
      e: (double t) => 0.270625948257788 - 0.00000000870557323835501 * t,
      i: (double t) => 17.5970260013943 - 0.000000185365574310984 * t,
      tp: (double t) => 2448772.91433344 - 0.000394794796106099 * t,
      n: (double t) => 0.0000000457034747929794 + 6.74791508226093E-17 * t,
      p: (double t) => 97.3197846878656 + 0.00000671603857575789 * t,
      longNode: (double t) => 108.450803891514 + 0.000000758055914867182 * t);
}

class DwarfPlanetEris extends MinorPlanet {
  @override
  final name = 'Eris';
  @override
  final id = CelestialId.eris;

  @override
  final orbitalElement = OrbitalElementWithMeanMotion(
      a: (double t) => 10037735525.6893 + 48.130570531904 * t,
      e: (double t) => 0.427543225197047 + 0.0000000041275203889238 * t,
      i: (double t) => 44.2828351256134 - 0.000000119352965264619 * t,
      tp: (double t) =>
          2555039.99992356 +
          -0.00376347701579471 * t +
          204304.378252318 * ((t - 2443509.5) ~/ 204304.378252318),
      n: (double t) => 0.0000000207527370773512 - 1.46035233407192E-16 * t,
      p: (double t) => 160.303285614715 - 0.00000371569236101165 * t,
      longNode: (double t) => 36.2071117484117 - 0.000000093705301513182 * t);
}

class DwarfPlanetHaumea extends MinorPlanet {
  @override
  final name = 'Haumea';
  @override
  final id = CelestialId.haumea;

  @override
  final orbitalElement = OrbitalElementWithMeanMotion(
      a: (double t) => 6526592426.43398 - 29.2795678842616 * t,
      e: (double t) => 0.179866795774475 + 0.00000000599068849353148 * t,
      i: (double t) => 28.1082683904377 + 0.0000000401856314040534 * t,
      tp: (double t) =>
          2513824.458571 +
          -0.00551715582470304 * t +
          103523.368971305 * ((t - 2448988.5) ~/ 103523.368971305),
      n: (double t) => 0.0000000395723197557672 + 2.76345968698448E-16 * t,
      p: (double t) => 266.198684688094 - 0.0000107104383808848 * t,
      longNode: (double t) => 122.049347002599 - 0.0000000421146479907754 * t);
}

class DwarfPlanetMakemake extends MinorPlanet {
  @override
  final name = 'Makemake';
  @override
  final id = CelestialId.makemake;
  @override

  final orbitalElement = OrbitalElementWithMeanMotion(
      a: (double t) => 7170706875.95335 - 145.320038757208 * t,
      e: (double t) => 0.229530883430302 - 0.0000000283354374741878 * t,
      i: (double t) => 28.7383384785065 + 0.000000108399116140748 * t,
      tp: (double t) =>
          2535236.6605278 +
          -0.00613849960027377 * t +
          112295.205907611 * ((t - 2463963.5) ~/ 112295.205907611),
      n: (double t) => 0.0000000342159296641432 + 1.17887172335553E-15 * t,
      p: (double t) => 323.080286374457 - 0.0000109459102996137 * t,
      longNode: (double t) => 79.7507885528252 - 0.000000126063226475941 * t);
}
