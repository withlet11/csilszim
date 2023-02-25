/*
 * sphere_model.dart
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

import 'equatorial_coordinate.dart';
import 'geographic_coordinate.dart';
import 'horizontal_coordinate.dart';

/// A spherical model for converting between each coordinate.
class SphereModel {
  /// [_location] is the observation location.
  final Geographic _location;

  /// [_gmst] is the Greenwich Mean Sidereal Time (GMST) in radians.
  final double _gmst;

  /// [_lmst] is the Local Mean Sidereal Time (LMST) in radians.
  final double _lmst;

  /// cos(Latitude) and sin(Latitude).
  final double _cosLat, _sinLat;

  const SphereModel._internal(
      this._location, this._gmst, this._lmst, this._cosLat, this._sinLat);

  factory SphereModel({location = Geographic, gmstMicroseconds = 0}) {
    return SphereModel._internal(
        location,
        gmstMicroseconds / 86400e6 * fullTurn,
        (gmstMicroseconds / 86400e6 * fullTurn) + location.long,
        cos(location.lat),
        sin(location.lat));
  }

  /// Converts from equatorial coordinate to local horizontal coordinate.
  Horizontal equatorialToHorizontal(Equatorial equatorial) {
    final ha = equatorial.ra - _lmst;
    final cosDec = cos(equatorial.dec);
    final sinDec = sin(equatorial.dec);
    final cosHa = cos(ha);
    final sinHa = sin(ha);
    final alt = asin(_cosLat * cosHa * cosDec + _sinLat * sinDec);
    final az =
        atan2(sinHa * cosDec, -_sinLat * cosHa * cosDec + _cosLat * sinDec);
    return Horizontal.fromRadians(alt: alt, az: az);
  }

  /// Converts from local horizontal coordinate to equatorial coordinate.
  Equatorial horizontalToEquatorial(Horizontal horizontal) {
    final cosAlt = cos(horizontal.alt);
    final sinAlt = sin(horizontal.alt);
    final cosAz = cos(horizontal.az);
    final sinAz = sin(horizontal.az);
    final dec = asin(_cosLat * cosAz * cosAlt + _sinLat * sinAlt);
    final ra =
        (atan2(sinAz * cosAlt, -_sinLat * cosAz * cosAlt + _cosLat * sinAlt) +
                _lmst +
                4 * pi) %
            fullTurn;
    return Equatorial.fromRadians(dec: dec, ra: ra);
  }
}
