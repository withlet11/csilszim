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

/// A class of orbital element for calculating with mean.
///
/// Please see [Approximate Positions of the Planets](https://ssd.jpl.nasa.gov/planets/approx_pos.html).
class OrbitalElementWithMeanLongitude {
  /// [a] Semi-major axis (a), km
  /// [e] Eccentricity (e)
  /// [i] inclination (I), degrees
  /// [l] Mean longitude (L), degrees
  /// [longPeri] Longitude of perihelion, degrees
  /// [longNode] Longitude of the ascending node (Ω), degrees
  /// [rd] radius of planets, km
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
  /// [a] Semi-major axis (a) AU
  /// [e] Eccentricity (e)
  /// [i] inclination (I), degrees
  /// [tp] Time of periapsis (τ), Julian Day Number
  /// [n] Mean motion (n), degrees/sec
  /// [p] Argument of periapsis (ω), degrees
  /// [longNode] Longitude of the ascending node (Ω), degrees
  /// [rd] radius of planets, km
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
