/*
 * orbital_element.dart
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

// Class of orbital elements
//
// Orbital elements, Pályaelemek,
// Eccentricity, excentricitás (e)
// Mean anomaly, középanomália (M0)
// Mean motion, középmozgás (n)
// Argument of periapsis, pericentrum argumentuma (ω)
// Longitude of the ascending node, felszálló csomó hossza (Ω)
// Longitude of perihelion (ϖ)
// Time of periapsis, pericentrumátmenet időpontja (τ)
// inclination, inklináció (i)
// Semi-major axis, fél nagytengely (a)
// radius of planets
//
// References
// - Dálya, Gergely (2021). _Bevezetés a Csillagászatba: Az Atommagoktól a
// Galaxis-szuperhalmazokig_, OOK-Press Kft. 137-139. ISBN 978-963-8361-58-5

import '../../utilities/LinearInterpolation.dart';

/// A class of orbital element
///
///
class OrbitalElement {
  /// [epoch] epoch, Julian day number
  /// [tp] Time of periapsis (τ), Julian Day Number
  /// [argPeri] Argument of periapsis (ω), degrees
  /// [longNode] Longitude of the ascending node (Ω), degrees
  /// [i] Inclination (I), degrees
  /// [e] Eccentricity (e)
  /// [a] Semi-major axis (a), km
  final double epoch;
  final double tp;
  final double argPeri;
  final double longNode;
  final double i;
  final double e;
  final double a;

  const OrbitalElement(
      {required this.epoch,
      required this.tp,
      required this.argPeri,
      required this.longNode,
      required this.i,
      required this.e,
      required this.a});
}

/// A class of orbital element for calculating with mean.
///
/// Please see [Approximate Positions of the Planets](https://ssd.jpl.nasa.gov/planets/approx_pos.html).
class OrbitalElementWithMeanLongitude {
  /// [a] Semi-major axis (a), km
  /// [e] Eccentricity (e)
  /// [i] Inclination (I), degrees
  /// [l] Mean longitude (L), degrees
  /// [longPeri] Longitude of perihelion, degrees
  /// [longNode] Longitude of the ascending node (Ω), degrees
  /// [rd] Radius of planets, km
  double Function(double t) a;
  double Function(double t) e;
  double Function(double t) i;
  double Function(double t) l;
  double Function(double t) longPeri;
  double Function(double t) longNode;

  OrbitalElementWithMeanLongitude(
      {required this.a,
      required this.e,
      required this.i,
      required this.l,
      required this.longPeri,
      required this.longNode});
}

class OrbitalElementWithMeanMotion {
  /// [a] Semi-major axis (a), AU
  /// [e] Eccentricity (e)
  /// [i] inclination (I), degrees
  /// [tp] Time of periapsis (τ), Julian Day Number
  /// [n] Mean motion (n), degrees/sec
  /// [p] Argument of periapsis (ω), degrees
  /// [longNode] Longitude of the ascending node (Ω), degrees
  /// [rd] Radius of planets, km
  double Function(double t) a;
  double Function(double t) e;
  double Function(double t) i;
  double Function(double t) tp;
  double Function(double t) n;
  double Function(double t) p;
  double Function(double t) longNode;

  OrbitalElementWithMeanMotion(
      {required this.a,
      required this.e,
      required this.i,
      required this.tp,
      required this.n,
      required this.p,
      required this.longNode});
}

class OrbitalElementWithPerihelionPassage {
  /// [a] Semi-major axis (a), AU
  /// [e] Eccentricity (e)
  /// [i] Inclination (I), degrees
  /// [tp] Time of perihelion passage (τ), Julian Day Number
  /// [argPeri] Argument of periapsis (ω), degrees
  /// [longNode] Longitude of the ascending node (Ω), degrees
  /// [rd] Radius of planets, km
  final double Function(double t) a;
  final double Function(double t) e;
  final double Function(double t) i;
  final double Function(double t) tp;
  final double Function(double t) argPeri;
  final double Function(double t) longNode;

  OrbitalElementWithPerihelionPassage(InterpolatedOrbitalElement element)
      : tp = element.tp,
        argPeri = element.argPeri,
        longNode = element.longNode,
        e = element.e,
        i = element.i,
        a = element.a;
}

class InterpolatedOrbitalElement {
  final LinearInterpolation lerp;
  final List<double> tpList;
  final List<double> argPeriList;
  final List<double> longNodeList;
  final List<double> iList;
  final List<double> eList;
  final List<double> aList;

  const InterpolatedOrbitalElement._internal(this.lerp, this.tpList,
      this.argPeriList, this.longNodeList, this.iList, this.eList, this.aList);

  factory InterpolatedOrbitalElement(
      {required List<double> epoch,
      required tp,
      required argPeri,
      required longNode,
      required i,
      required e,
      required a}) {
    return InterpolatedOrbitalElement._internal(
        LinearInterpolation(epoch), tp, argPeri, longNode, i, e, a);
  }

  factory InterpolatedOrbitalElement.from(List<OrbitalElement> list) {
    final sortedList = List.of(list)
      ..sort(
          (OrbitalElement a, OrbitalElement b) => a.epoch.compareTo(b.epoch));
    return InterpolatedOrbitalElement._internal(
      LinearInterpolation([for (final e in sortedList) e.epoch]),
      [for (final e in sortedList) e.tp],
      [for (final e in sortedList) e.argPeri],
      [for (final e in sortedList) e.longNode],
      [for (final e in sortedList) e.i],
      [for (final e in sortedList) e.e],
      [for (final e in sortedList) e.a],
    );
  }

  double tp(double t) => lerp.closest(tpList, t);

  double argPeri(double t) => lerp.lerp(argPeriList, t);

  double longNode(double t) => lerp.lerp(longNodeList, t);

  double i(double t) => lerp.lerp(iList, t);

  double e(double t) => lerp.lerp(eList, t);

  double a(double t) => lerp.lerp(aList, t);
}
