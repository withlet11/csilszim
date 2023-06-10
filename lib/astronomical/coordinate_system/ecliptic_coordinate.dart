/*
 * ecliptic_coordinate.dart
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

import 'package:vector_math/vector_math_64.dart';

import '../../constants.dart';
import '../constants/earth.dart';
import 'equatorial_coordinate.dart';

/// A position in the ecliptic coordinate system.
class Ecliptic {
  /// [lat] & [long] are provided latitude and longitude in radians.
  final double lat, long;

  const Ecliptic({
    required int latSign,
    required int latDeg,
    required int latMin,
    required double latSec,
    required int longDeg,
    required int longMin,
    required double longSec,
  })  : lat = (latSign * 2 - 1) *
            (latDeg + latMin / 60 + latSec / 3600) *
            degInRad,
        long = (longDeg + longMin / 60 + longSec / 3600) * degInRad;

  const Ecliptic.fromDegrees({required double lat, required double long})
      : lat = lat * degInRad,
        long = long * degInRad;

  const Ecliptic.fromRadians({required this.lat, required this.long});

  factory Ecliptic.fromXyz(Vector3 vector) {
    final x = vector.x;
    final y = vector.y;
    final z = vector.z;
    final r = sqrt(x * x + y * y);
    final lat =
        r == 0 ? (z.isNegative ? -quarterTurn : quarterTurn) : atan(z / r);
    final long = atan2(y, x);
    return Ecliptic.fromRadians(lat: lat, long: long);
  }

  double latInDegrees() => lat * radInDeg;

  double longInDegrees() => long * radInDeg;

  Ecliptic operator +(Ecliptic other) => add(lat: other.lat, long: other.long);

  Ecliptic operator -(Ecliptic other) =>
      add(lat: -other.lat, long: -other.long);

  Ecliptic add({required double lat, required double long}) {
    var tempLong = this.long + long;
    var tempLat = this.lat + lat;

    if (tempLat > quarterTurn) {
      tempLat = halfTurn - tempLat;
      tempLong += halfTurn;
    } else if (tempLat < -quarterTurn) {
      tempLat = -halfTurn - tempLat;
      tempLong += halfTurn;
    }

    return Ecliptic.fromRadians(long: tempLong % fullTurn, lat: tempLat);
  }

  Ecliptic normalized() {
    final tempLat = (lat + quarterTurn) % fullTurn;
    final tempLong =
        ((tempLat ~/ halfTurn).isEven ? long : long + halfTurn) % fullTurn;
    return Ecliptic.fromRadians(lat: tempLat - quarterTurn, long: tempLong);
  }

  Equatorial toEquatorial() {
    final cosLong = cos(long);
    final sinLong = sin(long);
    final cosLat = cos(lat);
    final sinLat = sin(lat);
    final vector = Vector3(cosLong * cosLat, sinLong * cosLat, sinLat);
    matrixFromEclipticToEquatorial.transform3(vector);
    final x = vector.x;
    final y = vector.y;
    final z = vector.z;
    final r = sqrt(x * x + y * y);
    final dec = r == 0 ? (z.isNegative ? -halfTurn : halfTurn) : atan(z / r);
    final ra = atan2(y, x);
    return Equatorial.fromRadians(dec: dec, ra: ra);
  }

  static List<Equatorial> prepareEclipticLine() {
    const step = 5;
    const count = 360 ~/ step;
    final eclipticLine = List.filled(count, Equatorial.zero);
    for (var i = 0; i < count ~/ 4; ++i) {
      final long = i * step - 180.0;
      final ecliptic = Ecliptic.fromDegrees(long: long, lat: 0.0);
      final equatorial1 = ecliptic.toEquatorial();
      final equatorial2 = Equatorial.fromRadians(
          dec: equatorial1.dec, ra: -halfTurn - equatorial1.ra);
      final equatorial3 = Equatorial.fromRadians(
          dec: -equatorial1.dec, ra: halfTurn + equatorial1.ra);
      final equatorial4 =
          Equatorial.fromRadians(dec: -equatorial1.dec, ra: -equatorial1.ra);
      eclipticLine[i] = equatorial1;
      eclipticLine[count ~/ 2 - 1 - i] = equatorial2;
      eclipticLine[i + count ~/ 2] = equatorial3;
      eclipticLine[count - 1 - i] = equatorial4;
    }
    return eclipticLine;
  }
}
