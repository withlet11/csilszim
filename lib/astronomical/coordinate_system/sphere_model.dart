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

import '../../constants.dart';
import 'equatorial_coordinate.dart';
import 'geographic_coordinate.dart';
import 'horizontal_coordinate.dart';

/// A spherical model for converting between each coordinate.
class SphereModel {
  /// [location] is the observation location.
  final Geographic location;

  /// [gmst] is the Greenwich Mean Sidereal Time (GMST) in radians.
  final double gmst;

  /// [lmst] is the Local Mean Sidereal Time (LMST) in radians.
  final double lmst;

  /// cos(Latitude) and sin(Latitude).
  final double _cosLat, _sinLat;

  ///
  final List<double> decOnHolizonList;
  final List<double> decBelowHorizonList;
  final List<Equatorial> eclipticLine;

  const SphereModel._internal(this.location, this.gmst, this.lmst, this._cosLat,
      this._sinLat, this.decOnHolizonList, this.decBelowHorizonList, this.eclipticLine);

  factory SphereModel(
      {required Geographic location,
      gmstMicroseconds = 0,
      List<Equatorial> eclipticLine = const <Equatorial>[]}) {
    return SphereModel._internal(
        location,
        gmstMicroseconds / 86400e6 * fullTurn,
        (gmstMicroseconds / 86400e6 * fullTurn) + location.long,
        cos(location.lat),
        sin(location.lat),
        _prepareHorizonLine(location.lat),
        _prepareHorizonLine2(location.lat),
        eclipticLine);
  }

  bool get isNorthernHemisphere => location.lat > 0.0;

  /// Converts from equatorial coordinate to local horizontal coordinate.
  Horizontal equatorialToHorizontal(Equatorial equatorial) {
    final ha = equatorial.ra - lmst;
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
                lmst +
                4 * pi) %
            fullTurn;
    return Equatorial.fromRadians(dec: dec, ra: ra);
  }

  /// Calculates hour angle on west horizon.
  double? haOnWestHorizon(double dec) {
    if (location.lat.abs() >= halfTurn || dec.abs() >= halfTurn) return null;
    final cosHa = -tan(location.lat) * tan(dec);
    return cosHa.abs() > 1 ? null : acos(cosHa);
  }

  /// Calculates hour angle on east horizon.
  double? haOnEastHorizon(double dec) {
    if (location.lat.abs() >= halfTurn || dec.abs() >= halfTurn) return null;
    final cosHa = -tan(location.lat) * tan(dec);
    return cosHa.abs() > 1 ? null : fullTurn - acos(cosHa);
  }

  /// Calculates hour angle from declination at sunset
  double? haAtSunset(double dec) {
    final cosHa = _cosHaAtSunriseOrSunset(dec);
    return cosHa.abs() > 1 ? null : acos(cosHa);
  }

  /// Calculates hour angle from declination at sunrise
  double? haAtSunrise(double dec) {
    final cosHa = _cosHaAtSunriseOrSunset(dec);
    return cosHa.abs() > 1 ? null : fullTurn - acos(cosHa);
  }

  /// Calculates hour angle from declination at civil dusk
  double? haAtCivilDusk(double dec) {
    final cosHa = _cosHaAtCivilDawnOrDusk(dec);
    return cosHa.abs() > 1 ? null : acos(cosHa);
  }

  /// Calculates hour angle from declination at civil dawn
  double? haAtCivilDawn(double dec) {
    final cosHa = _cosHaAtCivilDawnOrDusk(dec);
    return cosHa.abs() > 1 ? null : fullTurn - acos(cosHa);
  }

  /// Calculates hour angle from declination at nautical dusk
  double? haAtNauticalDusk(double dec) {
    final cosHa = _cosHaAtNauticalDawnOrDusk(dec);
    return cosHa.abs() > 1 ? null : acos(cosHa);
  }

  /// Calculates hour angle from declination at nautical dawn
  double? haAtNauticalDawn(double dec) {
    final cosHa = _cosHaAtNauticalDawnOrDusk(dec);
    return cosHa.abs() > 1 ? null : fullTurn - acos(cosHa);
  }

  /// Calculates hour angle from declination at astronomical dusk
  double? haAtAstronomicalDusk(double dec) {
    final cosHa = _cosHaAtAstronomicalDawnOrDusk(dec);
    return cosHa.abs() > 1 ? null : acos(cosHa);
  }

  /// Calculates hour angle from declination at astronomical dawn
  double? haAtAstronomicalDawn(double dec) {
    final cosHa = _cosHaAtAstronomicalDawnOrDusk(dec);
    return cosHa.abs() > 1 ? null : fullTurn - acos(cosHa);
  }

  /// Calculates hour angle from declination at sunrise or sunset
  ///
  /// At sunset, the altitude of the Sun is -15′.
  /// sin h = sin φ sin δ + cos φ cos δ cos t
  double _cosHaAtSunriseOrSunset(double dec) {
    const alt = -15 / 60 * degInRad;
    return (sin(alt) - sin(location.lat) * sin(dec)) /
        cos(location.lat) /
        cos(dec);
  }

  /// Calculates hour angle from declination at civil dawn or dusk
  ///
  /// At dusk, the altitude of the Sun is -6°.
  /// sin h = sin φ sin δ + cos φ cos δ cos t
  double _cosHaAtCivilDawnOrDusk(double dec) {
    const alt = -6 * degInRad;
    return (sin(alt) - sin(location.lat) * sin(dec)) /
        cos(location.lat) /
        cos(dec);
  }

  /// Calculates hour angle from declination at nautical dawn or dusk
  ///
  /// At dusk, the altitude of the Sun is -12°.
  /// sin h = sin φ sin δ + cos φ cos δ cos t
  double _cosHaAtNauticalDawnOrDusk(double dec) {
    const alt = -12 * degInRad;
    return (sin(alt) - sin(location.lat) * sin(dec)) /
        cos(location.lat) /
        cos(dec);
  }

  /// Calculates hour angle from declination at astronomical dawn or dusk
  ///
  /// At dusk, the altitude of the Sun is -18°.
  /// sin h = sin φ sin δ + cos φ cos δ cos t
  double _cosHaAtAstronomicalDawnOrDusk(double dec) {
    const alt = -18 * degInRad;
    return (sin(alt) - sin(location.lat) * sin(dec)) /
        cos(location.lat) /
        cos(dec);
  }

  double decOnHorizon(double ra) {
    const alt = 0.0;
    const cosAlt = 1.0; // cos(alt)
    final lat = location.lat;
    final k = tan((lat - alt) / 2);
    return switch (ra) {
      0.0 => (lat.isNegative ? -1 : 1) * (lat.abs() - quarterTurn + alt),
      halfTurn => (lat.isNegative ? -1 : 1) * (quarterTurn - lat.abs() + alt),
      _ => _decOnHorizon(ra, lat, k, cosAlt)
    };
  }
}

/// Calculates declination on the horizon
List<double> _prepareHorizonLine(double lat) {
  const count = 360;
  final list = List.filled(count, 0.0);
  const alt = 0.0;
  const cosAlt = 1.0; // cos(alt)

  list[0] = (lat.isNegative ? -1 : 1) * (lat.abs() - quarterTurn + alt);
  list[180] = (lat.isNegative ? -1 : 1) * (quarterTurn - lat.abs() + alt);

  if (lat.abs() > quarterTurn) return list;
  final k = tan((lat - alt) / 2);

  for (var i = 1; i < 180; ++i) {
    list[i] = _decOnHorizon(i * degInRad, lat, k, cosAlt);
  }

  for (var i = 181; i < 360; ++i) {
    list[i] = _decOnHorizon(i * degInRad, lat, k, cosAlt);
  }

  return list;
}

/// Calculates declination on the horizon
List<double> _prepareHorizonLine2(double lat) {
  const count = 360;
  final list = List.filled(count, 0.0);
  const alt = -2.0 * degInRad;
  if (lat.abs() > quarterTurn) return list;

  list[0] = (lat.isNegative ? -1 : 1) * (lat.abs() - quarterTurn + alt);
  list[180] = (lat.isNegative ? -1 : 1) * (quarterTurn - lat.abs() + alt);

  final k = tan((lat - alt) / 2);
  final cosAlt = cos(alt);

  for (var i = 1; i < 180; ++i) {
    list[i] = _decOnHorizon(i * degInRad, lat, k, cosAlt);
  }

  for (var i = 181; i < 360; ++i) {
    list[i] = _decOnHorizon(i * degInRad, lat, k, cosAlt);
  }

  return list;
}

double _decOnHorizon(double ha, double lat, double k, double cosAlt) {
  final sinGamma = cos(lat) * sin(ha) / cosAlt;
  if (sinGamma.abs() > 1.0) {
    return sinGamma.sign * -quarterTurn;
  } else {
    final gamma = lat.isNegative ? halfTurn - asin(sinGamma) : asin(sinGamma);
    final angle =
        (2 * atan2(sin((ha - gamma) / 2), k * sin((ha + gamma) / 2))) %
            fullTurn;
    return angle < halfTurn
        ? angle - quarterTurn
        : lat.isNegative
            ? quarterTurn
            : -quarterTurn;
  }
}
