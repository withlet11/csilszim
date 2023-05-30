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

  bool get isNorthernHemisphere => _location.lat > 0.0;

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

  /// Calculates hour angle on west horizon.
  double? haOnWestHorizon(double dec) {
    if (_location.lat.abs() >= halfTurn || dec.abs() >= halfTurn) return null;
    final cosHa = -tan(_location.lat) * tan(dec);
    return cosHa.abs() > 1 ? null : acos(cosHa);
  }

  /// Calculates hour angle on east horizon.
  double? haOnEastHorizon(double dec) {
    if (_location.lat.abs() >= halfTurn || dec.abs() >= halfTurn) return null;
    final cosHa = -tan(_location.lat) * tan(dec);
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
    return (sin(alt) - sin(_location.lat) * sin(dec)) /
        cos(_location.lat) /
        cos(dec);
  }

  /// Calculates hour angle from declination at civil dawn or dusk
  ///
  /// At dusk, the altitude of the Sun is -6°.
  /// sin h = sin φ sin δ + cos φ cos δ cos t
  double _cosHaAtCivilDawnOrDusk(double dec) {
    const alt = -6 * degInRad;
    return (sin(alt) - sin(_location.lat) * sin(dec)) /
        cos(_location.lat) /
        cos(dec);
  }

  /// Calculates hour angle from declination at nautical dawn or dusk
  ///
  /// At dusk, the altitude of the Sun is -12°.
  /// sin h = sin φ sin δ + cos φ cos δ cos t
  double _cosHaAtNauticalDawnOrDusk(double dec) {
    const alt = -12 * degInRad;
    return (sin(alt) - sin(_location.lat) * sin(dec)) /
        cos(_location.lat) /
        cos(dec);
  }

  /// Calculates hour angle from declination at astronomical dawn or dusk
  ///
  /// At dusk, the altitude of the Sun is -18°.
  /// sin h = sin φ sin δ + cos φ cos δ cos t
  double _cosHaAtAstronomicalDawnOrDusk(double dec) {
    const alt = -18 * degInRad;
    return (sin(alt) - sin(_location.lat) * sin(dec)) /
        cos(_location.lat) /
        cos(dec);
  }

  /// Calculates declination on the west horizon
  void decOnWestHorizon(List<double> list) {
    const alt = 0.0;
    final lat = _location.lat;
    if (lat.abs() > quarterTurn) return;
    final k = tan((alt - lat) / 2);
    for (var i = 0; i < 180; ++i) {
      // list.add(_decOnHorizon(i.toDouble(), lat, k));
      final ha = i * degInRad;
      final sinGamma = cos(lat) * sin(ha) / cos(alt);
      switch (sinGamma) {
        case > 1.0:
          list.add(-halfTurn);
        case < -1.0:
          list.add(halfTurn);
        default:
          if (i == 0 || i == 180) {
            list.add((lat.isNegative ? -1 : 1) *
                (i == 0 ? -1 : 1) *
                (quarterTurn - lat.abs()));
          } else {
            final gamma =
                lat.isNegative ? asin(sinGamma) : halfTurn - asin(sinGamma);
            final angle =
                (2 * atan2(sin((ha - gamma) / 2), k * sin((ha + gamma) / 2))) % fullTurn;
            list.add(angle > halfTurn ? angle - halfTurn - quarterTurn : quarterTurn - angle);
          }
      }
    }
    return;
  }

  double decOnHorizon(double ra) {
    const alt = 0.0;
    final lat = _location.lat;
    final k = tan((alt - lat) / 2);
    return _decOnHorizon(ra * radInDeg, lat, k);
  }

  double _decOnHorizon(double i, double lat, double k) {
    const alt = 0.0;
    final ha = i * degInRad;
    final sinGamma = cos(lat) * sin(ha) / cos(alt);
    switch (sinGamma) {
      case > 1.0:
        return -halfTurn;
      case < -1.0:
        return halfTurn;
      default:
        if (i == 0 || i == 180.0) {
          return (lat.isNegative ? -1 : 1) *
              (i == 0 ? -1 : 1) *
              (quarterTurn - lat.abs());
        } else {
          final gamma =
              lat.isNegative ? asin(sinGamma) : halfTurn - asin(sinGamma);
          final angle =
              (2 * atan2(sin((ha - gamma) / 2), k * sin((ha + gamma) / 2))) % fullTurn;
          return angle > halfTurn ? angle - halfTurn - quarterTurn : quarterTurn - angle;
        }
    }
  }

  /// Calculates declination on the east horizon
  void decOnEastHorizon(List<double> list) {
    const alt = 0.0;
    final lat = _location.lat;
    if (lat.abs() > quarterTurn) return;
    final k = tan((alt - lat) / 2);
    for (var i = 180; i < 360; ++i) {
      // list.add(_decOnHorizon(i.toDouble(), lat, k));
      final ha = i * degInRad;
      final sinGamma = cos(lat) * sin(ha) / cos(alt);
      switch (sinGamma) {
        case > 1.0:
          list.add(-halfTurn);
        case < -1.0:
          list.add(halfTurn);
        default:
          if (i == 0 || i == 180) {
            list.add((lat.isNegative ? -1 : 1) *
                (i == 0 ? -1 : 1) *
                (quarterTurn - lat.abs()));
          } else {
            final gamma =
                lat.isNegative ? asin(sinGamma) : halfTurn - asin(sinGamma);
            final angle =
                (2 * atan2(sin((ha - gamma) / 2), k * sin((ha + gamma) / 2))) % fullTurn;
            list.add(angle > halfTurn ? angle - halfTurn - quarterTurn : quarterTurn - angle);
          }
      }
    }
    return;
  }

  /// Calculates α on the west horizon
  ///
  /// Return value is [ra of the meridian, ra of the meridian + 2π)
  double? raOnWestHorizon(int gmst, double dec) {
    final ha = haOnWestHorizon(dec);
    if (ha == null) return null;
    return -ha % fullTurn + gmst / 86400e6 * fullTurn;
  }


  /// Calculates α on the east horizon
  ///
  /// Return value is [ra of the meridian, ra of the meridian + 2π)
  double? raOnEastHorizon(int gmst, double dec) {
    final ha = haOnEastHorizon(dec);
    if (ha == null) return null;
    return -ha % fullTurn + gmst / 86400e6 * fullTurn;
  }

  /// Calculates α on the west horizon at sunset.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnWestHorizonAtSunset(Equatorial sun, double dec) {
    final sunHa = haAtSunset(sun.dec);
    final ha = haOnWestHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }

  /// Calculates α on the east horizon at sunrise.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnEastHorizonAtSunrise(Equatorial sun, double dec) {
    final sunHa = haAtSunrise(sun.dec);
    final ha = haOnEastHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }

  /// Calculates α on the west horizon at civil dusk.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnWestHorizonAtCivilDusk(Equatorial sun, double dec) {
    final sunHa = haAtCivilDusk(sun.dec);
    final ha = haOnWestHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }

  /// Calculates α on the east horizon at civil dawn.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnEastHorizonAtCivilDawn(Equatorial sun, double dec) {
    final sunHa = haAtCivilDawn(sun.dec);
    final ha = haOnEastHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }

  /// Calculates α on the west horizon at nautical dusk.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnWestHorizonAtNauticalDusk(Equatorial sun, double dec) {
    final sunHa = haAtNauticalDusk(sun.dec);
    final ha = haOnWestHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }

  /// Calculates α on the east horizon at nautical dawn.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnEastHorizonAtNauticalDawn(Equatorial sun, double dec) {
    final sunHa = haAtNauticalDawn(sun.dec);
    final ha = haOnEastHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }

  /// Calculates α on the west horizon at astronomical dusk.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnWestHorizonAtAstronomicalDusk(Equatorial sun, double dec) {
    final sunHa = haAtAstronomicalDusk(sun.dec);
    final ha = haOnWestHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }

  /// Calculates α on the east horizon at astronomical dawn.
  ///
  /// Return value is [ra of the Sun, ra of the Sun + 2π)
  double? raOnEastHorizonAtAstronomicalDawn(Equatorial sun, double dec) {
    final sunHa = haAtAstronomicalDawn(sun.dec);
    final ha = haOnEastHorizon(dec);
    if (sunHa == null || ha == null) return null;
    return (sunHa - ha) % fullTurn + sun.ra;
  }
}
