/*
 * whole_night_sky_map.dart
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

import 'package:csilszim/astronomical/astronomical_object/celestial_id.dart';
import 'package:flutter/material.dart';

import '../astronomical/astronomical_object/deep_sky_object.dart';
import '../astronomical/astronomical_object/moon.dart';
import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../configs.dart';
import '../constants.dart';
import '../utilities/sexagesimal_angle.dart';
import '../utilities/star_size_on_screen.dart';
import 'configs.dart';
import 'mercator_projection.dart';
import 'whole_night_sky_view_setting_provider.dart';

/// A widget that creates a whole night sky map.
class WholeNightSkyMap extends StatelessWidget {
  final MercatorProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final WholeNightSkyViewSettings displaySettings;
  final Equatorial centerEquatorial;
  final Equatorial sunEquatorial;
  final List<Planet> planetList;
  final Moon moon;
  final Map<CelestialId, String> planetNameList;

  const WholeNightSkyMap({
    super.key,
    required this.projectionModel,
    required this.sphereModel,
    required this.starCatalogue,
    required this.displaySettings,
    required this.centerEquatorial,
    required this.sunEquatorial,
    required this.planetList,
    required this.moon,
    required this.planetNameList,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ProjectionRenderer(
      projectionModel,
      sphereModel,
      starCatalogue,
      displaySettings,
      centerEquatorial,
      sunEquatorial,
      planetList,
      planetNameList,
      moon,
    ));
  }
}

class _ProjectionRenderer extends CustomPainter {
  final MercatorProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final WholeNightSkyViewSettings displaySettings;
  final Equatorial centerEquatorial;
  final Equatorial sunEquatorial;
  final List<Planet> planetList;
  final Map<CelestialId, String> planetNameList;
  final Moon moon;

  const _ProjectionRenderer(
    this.projectionModel,
    this.sphereModel,
    this.starCatalogue,
    this.displaySettings,
    this.centerEquatorial,
    this.sunEquatorial,
    this.planetList,
    this.planetNameList,
    this.moon,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _setBackground(canvas, size);

    if (displaySettings.isEquatorialGridVisible) {
      _drawRightAscensionGrid(canvas, size);
      _drawDeclinationGrid(canvas, size);
      _drawEclipticLine(canvas, size);
    }

    if (displaySettings.isConstellationLineVisible) {
      _drawConstellationLines(canvas, size);
    }

    if (displaySettings.isConstellationNameVisible) {
      _drawConstellationName(canvas, size);
    }

    final midPoint = calculateMidPointOfMagnitude(-3.0, projectionModel.scale);
    _drawStars(canvas, size, midPoint);

    if (displaySettings.isMessierObjectVisible) {
      _drawMessierObject(canvas, size);
    }

    if (displaySettings.isPlanetVisible) {
      _drawPlanet(canvas, size, midPoint);
      _drawMoon(canvas, size, midPoint);
    }

    if (displaySettings.isFovVisible) {
      _drawFOV(canvas, size);
    }

    _drawAstronomicalTwilight(canvas, size, sunEquatorial);
    _drawNauticalTwilight(canvas, size, sunEquatorial);
    _drawCivilTwilight(canvas, size, sunEquatorial);
    _drawDay(canvas, size, sunEquatorial);
    _drawMomentaryHorizon(canvas, size);
    _drawPermanentHorizon(canvas, size);

    final decRaText = TextSpan(
      style: decRaTextStyle,
      text:
          'dec: ${DmsAngle.fromDegrees(centerEquatorial.decInDegrees()).toDmsWithSign()}, '
          'ra: ${HmsAngle.fromHours(centerEquatorial.raInHours()).toHms()}',
    );

    final decRaTextPainter = TextPainter(
      text: decRaText,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    decRaTextPainter.layout();
    decRaTextPainter.paint(canvas, const Offset(8, 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _setBackground(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
        backgroundPaint);
  }

  void _drawRightAscensionGrid(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    for (var ra = 0; ra < 24; ++ra) {
      final pointOnLine = projectionModel.convertToOffset(
          Equatorial.fromDegreesAndHours(dec: 0, ra: ra.toDouble()),
          center,
          unitLength);
      for (var x = pointOnLine.dx % lengthOfFullTurn;
          x < width;
          x += lengthOfFullTurn) {
        final p1 = Offset(x, 0.0);
        final p2 = Offset(x, height);
        canvas.drawLine(p1, p2, equatorialGridPaint);
      }
      _drawRaNumber(canvas, size, ra);
    }
  }

  void _drawDeclinationGrid(Canvas canvas, Size size) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    for (var dec = -80; dec < 90; dec += 10) {
      final pointOnLine = projectionModel.convertToOffset(
          Equatorial.fromDegreesAndHours(dec: dec.toDouble(), ra: 0),
          center,
          unitLength);
      final p1 = Offset(0.0, pointOnLine.dy);
      final p2 = Offset(width, pointOnLine.dy);
      canvas.drawLine(p1, p2, dec == 0 ? equatorPaint : equatorialGridPaint);
      _drawDecNumber(canvas, size, dec);
    }
  }

  void _drawEclipticLine(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final fullTurnList = sphereModel.eclipticLine.map((equatorial) =>
        projectionModel.convertToOffset(equatorial, center, unitLength));

    final firstX = fullTurnList.first.dx % lengthOfFullTurn + lengthOfFullTurn;
    final pointsOfFullScreen = <Offset>[];
    for (var shift = firstX - fullTurnList.first.dx;
        fullTurnList.first.dx + shift > 0;
        shift -= lengthOfFullTurn) {
      for (final offset in fullTurnList) {
        pointsOfFullScreen.add(offset + Offset(shift, 0.0));
      }
    }
    final path = Path()..addPolygon(pointsOfFullScreen, false);
    canvas.drawPath(path, eclipticPaint);
  }

  void _drawDecNumber(Canvas canvas, Size size, int dec) {
    final sign = '${dec.isNegative ? '$dec' : '+$dec'}$degSign';
    final locationTextSpan = TextSpan(style: decTextStyle, text: sign);

    final locationTextPainter = TextPainter(
      text: locationTextSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    locationTextPainter.layout();
    final textSize = locationTextPainter.size;
    final textWidth = textSize.width;
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final position = projectionModel.convertToOffset(
            Equatorial.fromDegreesAndHours(dec: dec.toDouble(), ra: 0.0),
            center,
            unitLength) -
        textSize.center(Offset.zero);
    final y = position.dy;

    locationTextPainter.paint(canvas, Offset(10, y));
    locationTextPainter.paint(canvas, Offset(width - 10 - textWidth, y));
  }

  void _drawRaNumber(Canvas canvas, Size size, int ra) {
    final sign = '${ra}h'.padLeft(3, '0');
    final locationTextSpan = TextSpan(style: raTextStyle, text: sign);

    final locationTextPainter = TextPainter(
      text: locationTextSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    locationTextPainter.layout();
    final textSize = locationTextPainter.size;
    final textHeight = textSize.height;

    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final width = size.width;
    final height = size.height;
    final center = size.center(Offset.zero);

    final position = projectionModel.convertToOffset(
            Equatorial.fromDegreesAndHours(dec: 0.0, ra: ra.toDouble()),
            center,
            unitLength) -
        textSize.center(Offset.zero);

    for (var x = position.dx % lengthOfFullTurn;
        x < width;
        x += lengthOfFullTurn) {
      locationTextPainter.paint(canvas, Offset(x, 10));
      locationTextPainter.paint(canvas, Offset(x, height - 10 - textHeight));
    }
  }

  void _drawPermanentHorizon(Canvas canvas, Size size) {
    var points = <Offset>[];
    final crossingUpperMeridianAndHorizon = Horizontal.fromRadians(
        alt: 0, az: sphereModel.isNorthernHemisphere ? halfTurn : 0.0);
    final equatorial =
        sphereModel.horizontalToEquatorial(crossingUpperMeridianAndHorizon);

    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final point =
        projectionModel.convertToOffset(equatorial, center, unitLength);
    final origin = Offset(0.0, point.dy);
    points = [origin, size.topRight(origin)];
    final path = _preparePathOfZone(size, points);
    canvas.drawPath(path, horizonPaint);
  }

  void _drawMomentaryHorizon(Canvas canvas, Size size) {
    final lineOfHorizon = List.filled(360, Offset.zero);
    final lineBelowHorizon = List.filled(360, Offset.zero);
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lmst = sphereModel.lmst;
    final decOnHorizon = sphereModel.decOnHolizonList;
    final decBelowHorizon = sphereModel.decBelowHorizonList;
    for (var i = 0; i < 360; ++i) {
      final equatorial1 = Equatorial.fromRadians(
          dec: decOnHorizon[359 - i], ra: (359 - i) * degInRad + lmst);
      lineOfHorizon[i] =
          projectionModel.convertToOffset(equatorial1, center, unitLength);
      final equatorial2 = Equatorial.fromRadians(
          dec: decBelowHorizon[359 - i], ra: (359 - i) * degInRad + lmst);
      lineBelowHorizon[i] =
          projectionModel.convertToOffset(equatorial2, center, unitLength);
    }

    _drawPathOnSphere(canvas, size, momentaryHorizonLinePaint, lineOfHorizon);
    _drawHatchOnSphere(canvas, size, momentaryHorizonHatchPaint, lineOfHorizon,
        lineBelowHorizon);
  }

  void _drawDay(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(canvas, size, sun, sphereModel.haAtSunrise,
        sphereModel.haAtSunset, dayZonePaint, dayLinePaint);
  }

  void _drawCivilTwilight(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(
        canvas,
        size,
        sun,
        sphereModel.haAtCivilDawn,
        sphereModel.haAtCivilDusk,
        civilTwilightZonePaint,
        civilTwilightLinePaint);
  }

  void _drawNauticalTwilight(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(
        canvas,
        size,
        sun,
        sphereModel.haAtNauticalDawn,
        sphereModel.haAtNauticalDusk,
        nauticalTwilightZonePaint,
        nauticalTwilightLinePaint);
  }

  void _drawAstronomicalTwilight(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(
        canvas,
        size,
        sun,
        sphereModel.haAtAstronomicalDawn,
        sphereModel.haAtAstronomicalDusk,
        astronomicalTwilightZonePaint,
        astronomicalTwilightLinePaint);
  }

  void _drawZoneAndLineOfTwilight(
      Canvas canvas,
      Size size,
      Equatorial sun,
      double? Function(double) raOnEastHorizon,
      double? Function(double) raOnWestHorizon,
      Paint zonePaint,
      Paint linePaint) {
    final lineGridList1 = <Offset>[];
    final lineGridList2 = <Offset>[];
    final zoneGridList = <Offset>[];

    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    final sunrise = raOnEastHorizon(sun.dec);
    final sunset = raOnWestHorizon(sun.dec);

    if (sunrise != null && sunset != null) {
      final list = sphereModel.decOnHolizonList;
      final sunriseHa = sunrise + sun.ra;
      final sunsetHa = sunset + sun.ra;

      final crossing = (sunriseHa + sunsetHa) / 2 + halfTurn;
      final crossingDec = sphereModel.decOnHorizon(crossing - sunsetHa);
      final crossingOffset = projectionModel.convertToOffset(
          Equatorial.fromRadians(dec: crossingDec, ra: crossing),
          center,
          unitLength);

      var i = 360;
      while (i-- > 180) {
        final ra = i * degInRad + sunsetHa;
        final offset = projectionModel.convertToOffset(
            Equatorial.fromRadians(dec: list[i], ra: ra), center, unitLength);
        if (ra > crossing) {
          zoneGridList.add(offset);
        } else {
          lineGridList1.add(crossingOffset);
          zoneGridList.add(crossingOffset);
          lineGridList1.add(offset);
          break;
        }
      }

      while (i-- > 180) {
        final ra = i * degInRad + sunsetHa;
        final offset = projectionModel.convertToOffset(
            Equatorial.fromRadians(dec: list[i], ra: ra), center, unitLength);
        lineGridList1.add(offset);
      }

      while (i-- > 0) {
        final ra = i * degInRad + sunriseHa;
        final offset = projectionModel.convertToOffset(
            Equatorial.fromRadians(dec: list[i], ra: ra), center, unitLength);
        if (ra > crossing) {
          lineGridList2.add(offset);
        } else {
          zoneGridList.add(offset);
          break;
        }
      }

      while (i-- > 0) {
        final ra = i * degInRad + sunriseHa;
        final offset = projectionModel.convertToOffset(
            Equatorial.fromRadians(dec: list[i], ra: ra), center, unitLength);
        zoneGridList.add(offset);
      }
    }

    if (zoneGridList.isEmpty) {
      if (sphereModel.isNorthernHemisphere) {
        if (sun.dec > 0) {
          final gridList = [
            size.topLeft(Offset.zero),
            size.topRight(Offset.zero)
          ];
          _drawPathOnSphere(canvas, size, zonePaint, gridList);
        }
      } else {
        if (sun.dec.isNegative) {
          final gridList = [
            size.bottomLeft(Offset.zero),
            size.bottomRight(Offset.zero)
          ];
          _drawPathOnSphere(canvas, size, zonePaint, gridList);
        }
      }
    } else {
      final lineGridList = lineGridList2 + lineGridList1;
      _drawPathOnSphere(canvas, size, zonePaint, zoneGridList);
      _drawPathOnSphere(canvas, size, linePaint, lineGridList);
    }
  }

  void _drawPathOnSphere(
      Canvas canvas, Size size, Paint paint, List<Offset> points) {
    final path = _preparePathOfZone(size, points);
    canvas.drawPath(path, paint);
  }

  void _drawHatchOnSphere(Canvas canvas, Size size, Paint paint,
      List<Offset> points1, List<Offset> points2) {
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final firstX = points1.first.dx % lengthOfFullTurn - lengthOfFullTurn;
    var shift = firstX - points1.first.dx;

    final width = size.width;
    for (; points1.first.dx + shift < width; shift += lengthOfFullTurn) {
      for (var i = 0; i < points1.length; ++i) {
        final point1 = points1[i] + Offset(shift, 0);
        final point2 = points2[(i + 2) % points1.length] + Offset(shift, 0);
        if (point1.dy.isNaN || point2.dy.isNaN) continue;
        canvas.drawLine(point1, point2, paint);
      }
    }
  }

  Path _preparePathOfZone(Size size, List<Offset> points) {
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final firstX = points.first.dx % lengthOfFullTurn - lengthOfFullTurn;
    var shift = firstX - points.first.dx;
    final path = Path()..moveTo(points.first.dx + shift, points.first.dy);

    final width = size.width;
    for (; points.first.dx + shift < width; shift += lengthOfFullTurn) {
      for (final offset in points) {
        path.lineTo(offset.dx + shift, offset.dy);
      }
    }

    final bottom = sphereModel.isNorthernHemisphere ? size.height : 0.0;
    path.lineTo(width, points.last.dy);
    path.lineTo(width, bottom);
    path.lineTo(0, bottom);
    return path;
  }

  void _drawStars(Canvas canvas, Size size, double midPoint) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    const minimumRadius = 0.2;
    final magnitudeLimit = faintestMagnitude(minimumRadius, midPoint);

    for (final star in starCatalogue.starList) {
      if (star.hipNumber > 0 && star.magnitude < magnitudeLimit) {
        final xy =
            projectionModel.convertToOffset(star.position, center, unitLength);
        final y = xy.dy;
        final radius = radiusOfObject(star.magnitude, midPoint);
        for (var x = xy.dx % lengthOfFullTurn;
            x < width;
            x += lengthOfFullTurn) {
          final position = Offset(x, y);
          if (radius > 3.0) {
            canvas.drawCircle(
                position, 3.0 + (radius - 3.0) * 0.8, starBlurPaint);
            canvas.drawCircle(position, 3.0 + (radius - 3.0) * 0.5, starPaint);
          } else {
            canvas.drawCircle(position, radius, starPaint);
          }
        }
      }
    }
  }

  void _drawConstellationLines(Canvas canvas, Size size) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    for (final line in starCatalogue.lineList) {
      final star1 = starCatalogue.starList[line.hipNumber1];
      final star2 = starCatalogue.starList[line.hipNumber2];

      final position1 =
          projectionModel.convertToOffset(star1.position, center, unitLength);
      final position2 =
          projectionModel.convertToOffset(star2.position, center, unitLength);

      final double x1, y1, dx, dy;
      if (position1.dx - position2.dx > lengthOfFullTurn / 2) {
        x1 = position1.dx - lengthOfFullTurn;
        y1 = position1.dy;
        dx = position2.dx - position1.dx + lengthOfFullTurn;
        dy = position2.dy - position1.dy;
      } else if (position2.dx - position1.dx > lengthOfFullTurn / 2) {
        x1 = position2.dx - lengthOfFullTurn;
        y1 = position2.dy;
        dx = position1.dx - position2.dx + lengthOfFullTurn;
        dy = position1.dy - position2.dy;
      } else if (position1.dx < position2.dx) {
        x1 = position1.dx; // % lengthOfFullTurn;
        y1 = position1.dy;
        dx = position2.dx - position1.dx;
        dy = position2.dy - position1.dy;
      } else {
        x1 = position2.dx; // % lengthOfFullTurn;
        y1 = position2.dy;
        dx = position1.dx - position2.dx;
        dy = position1.dy - position2.dy;
      }

      for (var x = x1; x < width; x += lengthOfFullTurn) {
        final path = Path()
          ..moveTo(x, y1)
          ..lineTo(x + dx, y1 + dy);
        canvas.drawPath(path, constellationLinePaint);
      }
    }
  }

  void _drawConstellationName(Canvas canvas, Size size) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    for (final name in starCatalogue.nameList) {
      final locationTextSpan = TextSpan(
        style: constellationLabelTextStyle,
        text: name.iauAbbr,
      );

      final locationTextPainter = TextPainter(
        text: locationTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      locationTextPainter.layout();
      final textCenter = locationTextPainter.size.center(Offset.zero);

      final xy =
          projectionModel.convertToOffset(name.position, center, unitLength) -
              textCenter;
      final y = xy.dy;

      for (var x = xy.dx % lengthOfFullTurn; x < width; x += lengthOfFullTurn) {
        locationTextPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  void _drawMessierObject(Canvas canvas, Size size) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    for (DeepSkyObject object in starCatalogue.messierList) {
      final locationTextSpan = TextSpan(
        style: celestialObjectLabelTextStyle,
        text: 'M${object.messierNumber}',
      );

      final locationTextPainter = TextPainter(
        text: locationTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      locationTextPainter.layout();
      final xy =
          projectionModel.convertToOffset(object.position, center, unitLength);
      final y = xy.dy;
      final majorAxisSize = max(
          12.0,
          _lengthOfAltitudeAngle(center, unitLength, object.position,
              object.majorAxisSize ?? 12.0));

      for (var x = xy.dx % lengthOfFullTurn; x < width; x += lengthOfFullTurn) {
        if (object.type == 'Open cluster') {
          _drawOpenCluster(canvas, Offset(x, y), majorAxisSize);
        } else if (object.type == 'Globular cluster') {
          _drawGlobularCluster(canvas, Offset(x, y), majorAxisSize);
        } else if (object.type.toLowerCase().contains('nebula')) {
          if (object.type == 'Planetary nebula') {
            _drawPlanetaryNebula(canvas, Offset(x, y), majorAxisSize);
          } else {
            _drawNebula(canvas, Offset(x, y), majorAxisSize);
          }
        } else if (object.type.contains('galaxy')) {
          final minorAxisSize = max(
              6.0,
              _lengthOfAltitudeAngle(center, unitLength, object.position,
                  object.minorAxisSize ?? 0.0));
          final orientationAngle =
              quarterTurn - (object.orientationAngle ?? 0.0) * degInRad;
          _drawGalaxy(canvas, Offset(x, y), majorAxisSize, minorAxisSize,
              orientationAngle);
        } else {
          switch (object.messierNumber) {
            case 1:
              _drawNebula(canvas, Offset(x, y), majorAxisSize);
            case 24 || 73:
              _drawOpenCluster(canvas, Offset(x, y), majorAxisSize);
            case 40:
              _drawDoubleStar(canvas, Offset(x, y));
          }
        }
        locationTextPainter.paint(canvas, Offset(x + 10.0, y - 6.0));
      }
    }
  }

  void _drawPlanet(Canvas canvas, Size size, double midPoint) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    for (var planet in planetList) {
      final radius = radiusOfObject(planet.magnitude, midPoint);
      final xy = projectionModel.convertToOffset(
          planet.equatorial, center, unitLength);
      final y = xy.dy;
      for (var x = xy.dx % lengthOfFullTurn; x < width; x += lengthOfFullTurn) {
        final position = Offset(x, y);
        if (radius > 3.0) {
          canvas.drawCircle(
              position, 3.0 + (radius - 3.0) * 0.8, starBlurPaint);
          canvas.drawCircle(position, 3.0 + (radius - 3.0) * 0.5, starPaint);
        } else {
          canvas.drawCircle(position, radius, starPaint);
        }
        final path = Path()
          ..moveTo(position.dx + 4, position.dy - 4)
          ..relativeLineTo(12.0, -12.0)
          ..relativeLineTo(20.0, 0.0);
        canvas.drawPath(path, planetPointerPaint);

        final locationTextSpan = TextSpan(
            style: celestialObjectLabelTextStyle,
            text: planetNameList[planet.id]);

        final nameTextPainter = TextPainter(
          text: locationTextSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        nameTextPainter.layout();
        final textPosition = position + const Offset(40.0, -22.0);
        nameTextPainter.paint(canvas, textPosition);
      }
    }
  }

  void _drawMoon(Canvas canvas, Size size, double midPoint) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    final xy =
        projectionModel.convertToOffset(moon.equatorial, center, unitLength);
    final top = Equatorial.fromRadians(
        dec: moon.equatorial.dec + moon.apparentRadius, ra: moon.equatorial.ra);
    final topXy = projectionModel.convertToOffset(top, center, unitLength);
    final y = xy.dy;
    final magnitudeBaseRadius = radiusOfObject(moon.magnitude, midPoint);
    final radius = (y - topXy.dy).abs();
    for (var x = xy.dx % lengthOfFullTurn; x < width; x += lengthOfFullTurn) {
      canvas.save();
      canvas.translate(x, y);

      final path = Path()
        ..moveTo(Offset.zero.dx + 4, Offset.zero.dy - 4)
        ..relativeLineTo(12.0, -12.0)
        ..relativeLineTo(20.0, 0.0);
      canvas.drawPath(path, planetPointerPaint);

      final locationTextSpan = TextSpan(
          style: celestialObjectLabelTextStyle,
          text: planetNameList[CelestialId.moon]);

      final nameTextPainter = TextPainter(
        text: locationTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      nameTextPainter.layout();
      final textPosition = Offset.zero + const Offset(40.0, -22.0);
      nameTextPainter.paint(canvas, textPosition);

      final moonRadius = max(radius, 10.0);
      final moonSize = 2 * moonRadius;
      canvas.drawCircle(
          Offset.zero, 3.0 + (magnitudeBaseRadius - 3.0) * 0.8, starBlurPaint);
      canvas.drawCircle(Offset.zero, moonRadius, moonLightSidePaint);
      final Paint backgroundPaint, foregroundPaint;
      final double arcStart;
      if ((moon.phaseAngle - halfTurn).abs() > quarterTurn) {
        backgroundPaint = moonDarkSidePaint;
        foregroundPaint = moonLightSidePaint;
        arcStart = quarterTurn;
      } else {
        backgroundPaint = moonLightSidePaint;
        foregroundPaint = moonDarkSidePaint;
        arcStart = -quarterTurn;
      }
      canvas.rotate(moon.tilt + quarterTurn);
      canvas.drawCircle(Offset.zero, moonRadius, backgroundPaint);
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: moonRadius),
          arcStart, halfTurn, false, foregroundPaint);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset.zero,
              width: moonSize * cos(moon.phaseAngle),
              height: moonSize),
          foregroundPaint);
      canvas.restore();
    }
  }

  void _drawOpenCluster(Canvas canvas, Offset offset, double signSize) {
    final radius = signSize * half;
    const stepAngle = fullTurn / 12;
    const sweepAngle = stepAngle / 2;
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var angle = 0.0; angle < fullTurn; angle += stepAngle) {
      canvas.drawArc(Rect.fromCircle(center: offset, radius: radius), angle,
          sweepAngle, false, paint);
    }
  }

  void _drawGlobularCluster(Canvas canvas, Offset offset, double signSize) {
    final radius = signSize * half;
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(offset, radius, paint);
    canvas.drawLine(
        offset.translate(0.0, -radius), offset.translate(0.0, radius), paint);
    canvas.drawLine(
        offset.translate(-radius, 0.0), offset.translate(radius, 0.0), paint);
  }

  void _drawPlanetaryNebula(Canvas canvas, Offset offset, double signSize) {
    final radius = signSize / 3.0;
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(offset, radius, paint);
    canvas.drawLine(offset.translate(0.0, -radius * 2),
        offset.translate(0.0, -radius), paint);
    canvas.drawLine(offset.translate(0.0, radius * 2),
        offset.translate(0.0, radius), paint);
    canvas.drawLine(offset.translate(-radius * 2, 0.0),
        offset.translate(-radius, 0.0), paint);
    canvas.drawLine(offset.translate(radius * 2, 0.0),
        offset.translate(radius, 0.0), paint);
  }

  void _drawNebula(Canvas canvas, Offset offset, double signSize) {
    canvas.drawRect(
        Rect.fromCenter(center: offset, width: signSize, height: signSize),
        deepSkyObjectStrokePaint);
  }

  void _drawGalaxy(Canvas canvas, Offset offset, double majorAxisSize,
      double minorAxisSize, double orientationAngle) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(orientationAngle);
    canvas.translate(-offset.dx, -offset.dy);
    canvas.drawOval(
        Rect.fromCenter(
            center: offset, width: majorAxisSize, height: minorAxisSize),
        deepSkyObjectStrokePaint);
    canvas.restore();
  }

  void _drawDoubleStar(Canvas canvas, Offset offset) {
    const radius = 1.5;
    canvas.drawCircle(
        offset.translate(-radius * 3, 0.0), radius, deepSkyObjectStrokePaint);
    canvas.drawCircle(
        offset.translate(radius * 3, 0.0), radius, deepSkyObjectStrokePaint);
    canvas.drawRect(
        Rect.fromCenter(center: offset, width: radius * 6, height: radius * 2),
        deepSkyObjectStrokePaint);
    canvas.drawCircle(offset, radius, deepSkyObjectStrokePaint);
  }

  void _drawFOV(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    final points = projectionModel.pointsOnCircle(
        center, unitLength, displaySettings.trueFov / 2 * degInRad);

    final path = Path();
    if (points.first.dx < points.last.dx) {
      if (points.first.dx < points[1].dx) {
        // Circle is open. Starts from left side.
        path.moveTo(0.0, points.first.dy);
        path.lineTo(points.first.dx, points.first.dy);
        path.addPolygon(points, false);
        path.lineTo(size.width, points.last.dy);
      } else {
        // Circle is closed.
        path.addPolygon(points, true);
      }
    } else {
      if (points.first.dx > points[1].dx) {
        // Circle is open. Starts from right side.
        path.moveTo(size.width, points.first.dy);
        path.lineTo(points.first.dx, points.first.dy);
        path.addPolygon(points, false);
        path.lineTo(0.0, points.last.dy);
      } else {
        // Circle is closed.
        path.addPolygon(points, true);
      }
    }
    canvas.drawPath(path, fovPaint);
  }

  /// Converts angle to length at a position in horizontal coordinator.
  ///
  /// [angle] is given in arc minutes.
  double _lengthOfAltitudeAngle(
      Offset center, double unitLength, Equatorial equatorial, double angle) {
    final dec = equatorial.dec;
    final ra = equatorial.ra;
    final angleInRadian = angle / 60.0 * degInRad;
    final bottomCenter =
        Equatorial.fromRadians(dec: dec - angleInRadian, ra: ra);
    return projectionModel
            .convertToOffset(bottomCenter, center, unitLength)
            .dy -
        projectionModel.convertToOffset(equatorial, center, unitLength).dy;
  }
}

double _getUnitLength(Size size) => size.height * 0.9 / halfTurn;
