/*
 * momentary_sky_map.dart
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

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../astronomical/astronomical_object/celestial_id.dart';
import '../astronomical/astronomical_object/deep_sky_object.dart';
import '../astronomical/astronomical_object/moon.dart';
import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/astronomical_object/sun.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../configs.dart';
import '../constants.dart';
import '../utilities/sexagesimal_angle.dart';
import 'configs.dart';
import 'momentary_sky_view_setting_provider.dart';
import 'stereographic_projection.dart';

/// A widget that creates a momentary sky map.
class MomentarySkyMap extends StatelessWidget {
  final StereographicProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final List<Planet> planetList;
  final Sun sun;
  final Moon moon;
  final Map<CelestialId, String> nameList;
  final List<Tuple3<String, int, bool>> directionSignList;
  final MomentarySkyViewSettings displaySettings;
  final Horizontal mouseAltAz;

  const MomentarySkyMap({
    super.key,
    required this.projectionModel,
    required this.sphereModel,
    required this.starCatalogue,
    required this.planetList,
    required this.sun,
    required this.moon,
    required this.directionSignList,
    required this.nameList,
    required this.displaySettings,
    required this.mouseAltAz,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ProjectionRenderer(
            projectionModel,
            mouseAltAz,
            sphereModel,
            starCatalogue,
            planetList,
            sun,
            moon,
            nameList,
            directionSignList,
            displaySettings));
  }
}

class _ProjectionRenderer extends CustomPainter {
  final StereographicProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final List<Planet> planetList;
  final Sun sun;
  final Moon moon;
  final Map<CelestialId, String> nameList;
  final List<Tuple3<String, int, bool>> directionSignList;
  final MomentarySkyViewSettings displaySettings;
  final Horizontal mouseAltAz;

  const _ProjectionRenderer(
      this.projectionModel,
      this.mouseAltAz,
      this.sphereModel,
      this.starCatalogue,
      this.planetList,
      this.sun,
      this.moon,
      this.nameList,
      this.directionSignList,
      this.displaySettings);

  @override
  void paint(Canvas canvas, Size size) {
    _drawHorizon(canvas, size);

    if (displaySettings.isHorizontalGridVisible) {
      _drawAzimuthGrid(canvas, size);
      _drawAltitudeGrid(canvas, size);
    }
    if (displaySettings.isEquatorialGridVisible) {
      _drawRightAscensionGrid(canvas, size);
      _drawDeclinationGrid(canvas, size);
    }

    _drawDirectionSign(canvas, size);

    if (displaySettings.isConstellationLineVisible) {
      _drawConstellationLines(canvas, size);
    }
    if (displaySettings.isConstellationNameVisible) {
      _drawConstellationName(canvas, size);
    }

    final midPoint = calculateMidPointOfMagnitude();
    _drawStars(canvas, size, midPoint);

    if (displaySettings.isMessierObjectVisible) {
      _drawMessierObject(canvas, size);
    }

    for (final planet in planetList) {
      _drawPlanet(canvas, size, planet, midPoint);
    }

    _drawSun(canvas, size, midPoint);
    _drawMoon(canvas, size, midPoint);

    if (displaySettings.isFovVisible) {
      _drawFOV(canvas, size);
    }

    final altAzText = TextSpan(
      style: altAzTextStyle,
      text:
          'alt: ${DmsAngle.fromDegrees(mouseAltAz.altInDegrees()).toDmsWithSign()}, '
          'az: ${DmsAngle.fromDegrees(mouseAltAz.azInDegrees()).toDmsWithoutSign()}',
    );
    final altAzTextPainter = TextPainter(
      text: altAzText,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    altAzTextPainter.layout();
    altAzTextPainter.paint(canvas, Offset.zero);

    final decRaText = TextSpan(
      style: decRaTextStyle,
      text:
          'dec: ${DmsAngle.fromDegrees(sphereModel.horizontalToEquatorial(mouseAltAz).decInDegrees()).toDmsWithSign()}, '
          'ra: ${HmsAngle.fromHours(sphereModel.horizontalToEquatorial(mouseAltAz).raInHours()).toHms()}',
    );
    final decRaTextPainter = TextPainter(
      text: decRaText,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    decRaTextPainter.layout();
    decRaTextPainter.paint(canvas, const Offset(0, 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _drawHorizon(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    final Paint innerPartPaint;
    final Paint outerPartPaint;
    if (projectionModel.centerAltAz.alt.isNegative) {
      innerPartPaint = horizonPaint;
      outerPartPaint = backgroundPaint;
    } else {
      innerPartPaint = backgroundPaint;
      outerPartPaint = horizonPaint;
    }

    canvas.drawRect(Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
        outerPartPaint);

    final list = [
      for (var i = 0; i < 360; ++i)
        projectionModel.horizontalToXy(
            Horizontal.fromDegrees(alt: 0, az: i.toDouble()),
            center,
            unitLength),
    ];

    final path = Path()..addPolygon(list, true);
    canvas.drawPath(path, innerPartPaint);
  }

  void _drawAzimuthGrid(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (var azimuth = 0; azimuth < 360; azimuth += 15) {
      final maxAltitude = (azimuth % 90 == 0) ? 90 : 80;
      final list = [
        for (var altitude = 0; altitude <= maxAltitude; altitude += 5)
          projectionModel.horizontalToXy(
              Horizontal.fromDegrees(
                  alt: altitude.toDouble(), az: azimuth.toDouble()),
              center,
              unitLength),
      ];
      final path = Path()..addPolygon(list, false);
      canvas.drawPath(path, horizontalGridPaint);
    }
  }

  void _drawAltitudeGrid(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (var altitude = 0; altitude < 90; altitude += 10) {
      final list = [
        for (var azimuth = 0; azimuth <= 360; azimuth += 3)
          projectionModel.horizontalToXy(
              Horizontal.fromDegrees(
                  alt: altitude.toDouble(), az: azimuth.toDouble()),
              center,
              unitLength),
      ];
      final path = Path()..addPolygon(list, true);
      canvas.drawPath(path, horizontalGridPaint);
    }
  }

  void _drawRightAscensionGrid(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (var ra = 0; ra < 24; ++ra) {
      final begin = projectionModel.horizontalToXy(
          sphereModel.equatorialToHorizontal(
              Equatorial.fromDegreesAndHours(dec: -90, ra: ra.toDouble())),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      for (var dec = -90; dec <= 90; dec += 1) {
        final horizontal = sphereModel.equatorialToHorizontal(
            Equatorial.fromDegreesAndHours(
                dec: dec.toDouble(), ra: ra.toDouble()));
        final position =
            projectionModel.horizontalToXy(horizontal, center, unitLength);
        if (horizontal.alt.isNegative) {
          path.moveTo(position.dx, position.dy);
        } else {
          path.lineTo(position.dx, position.dy);
        }
      }
      canvas.drawPath(path, equatorialGridPaint);
    }
  }

  void _drawDeclinationGrid(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (var dec = -80; dec < 90; dec += 10) {
      final begin = projectionModel.horizontalToXy(
          sphereModel.equatorialToHorizontal(
              Equatorial.fromDegreesAndHours(dec: dec.toDouble(), ra: 0)),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      for (double ra = 0; ra <= 24; ra += 1 / 16) {
        final horizontal = sphereModel.equatorialToHorizontal(
            Equatorial.fromDegreesAndHours(
                dec: dec.toDouble(), ra: ra.toDouble()));
        final position =
            projectionModel.horizontalToXy(horizontal, center, unitLength);
        if (horizontal.alt.isNegative) {
          path.moveTo(position.dx, position.dy);
        } else {
          path.lineTo(position.dx, position.dy);
        }
      }
      canvas.drawPath(path, dec == 0 ? equatorPaint : equatorialGridPaint);
    }
  }

  void _drawDirectionSign(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    for (final e in directionSignList) {
      final signTextSpan = TextSpan(
          style: e.item3
              ? largeDirectionSignTextStyle
              : smallDirectionSignTextStyle,
          text: e.item1);

      final signTextPainter = TextPainter(
          text: signTextSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);

      signTextPainter.layout();
      final textSize = signTextPainter.size;
      final position = projectionModel.horizontalToXy(
              Horizontal.fromDegrees(alt: 0, az: e.item2.toDouble()),
              center,
              unitLength) -
          textSize.center(Offset.zero);

      signTextPainter.paint(canvas, position);
    }
  }

  void _drawStars(Canvas canvas, Size size, double midPoint) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (final star in starCatalogue.starList) {
      if (star.hipNumber > 0) {
        final radius = radiusOfObject(star.magnitude, midPoint);
        if (radius > 0.25) {
          final altAz = sphereModel.equatorialToHorizontal(star.position);
          if (!altAz.alt.isNegative) {
            final xy =
                projectionModel.horizontalToXy(altAz, center, unitLength);
            if (radius > 3.0) {
              canvas.drawCircle(xy, 3.0 + (radius - 3.0) * 0.8, starBlurPaint);
              canvas.drawCircle(xy, 3.0 + (radius - 3.0) * 0.5, starPaint);
            } else {
              canvas.drawCircle(xy, radius, starPaint);
            }
          }
        }
      }
    }
  }

  void _drawPlanet(Canvas canvas, Size size, Planet planet, double midPoint) {
    final altAz = sphereModel.equatorialToHorizontal(planet.equatorial);
    if (altAz.alt > 0) {
      final center = size.center(Offset.zero);
      final unitLength = _getUnitLength(size);
      final offset = projectionModel.horizontalToXy(altAz, center, unitLength);
      final radius = radiusOfObject(planet.magnitude, midPoint);
      if (radius > 3.0) {
        canvas.drawCircle(offset, 3.0 + (radius - 3.0) * 0.8, starBlurPaint);
        canvas.drawCircle(offset, 3.0 + (radius - 3.0) * 0.5, starPaint);
      } else {
        canvas.drawCircle(offset, radius, starPaint);
      }
      _drawPlanetLabel(canvas, size, offset, nameList[planet.id]!);
    }
  }

  void _drawMoon(Canvas canvas, Size size, double midPoint) {
    final equatorial = moon.equatorial;
    final altAz = sphereModel.equatorialToHorizontal(equatorial);
    if (altAz.alt > 0) {
      final center = size.center(Offset.zero);
      final unitLength = _getUnitLength(size);
      final offset = projectionModel.horizontalToXy(altAz, center, unitLength);
      final radius = radiusOfObject(Sun.magnitude, midPoint);
      canvas.drawCircle(offset, 3.0 + (radius - 3.0) * 0.8, starBlurPaint);
      canvas.drawCircle(offset, 3.0 + (radius - 3.0) * 0.5, starPaint);
      _drawPlanetLabel(canvas, size, offset, nameList[CelestialId.moon]!);
    }
  }

  void _drawSun(Canvas canvas, Size size, double midPoint) {
    final equatorial = sun.equatorial;
    final altAz = sphereModel.equatorialToHorizontal(equatorial);
    if (altAz.alt > 0) {
      final center = size.center(Offset.zero);
      final unitLength = _getUnitLength(size);
      final offset = projectionModel.horizontalToXy(altAz, center, unitLength);
      final radius = radiusOfObject(Sun.magnitude, midPoint);
      canvas.drawCircle(offset, 3.0 + (radius - 3.0) * 0.8, starBlurPaint);
      canvas.drawCircle(offset, 3.0 + (radius - 3.0) * 0.5, starPaint);
      _drawPlanetLabel(canvas, size, offset, nameList[CelestialId.sun]!);
    }
  }

  void _drawPlanetLabel(Canvas canvas, Size size, Offset offset, String label) {
    final textSpan =
        TextSpan(style: celestialObjectLabelTextStyle, text: label);

    final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    textPainter.layout();
    final height = textPainter.size.height;

    textPainter.paint(canvas, offset + Offset(height * 0.5, -height * 1.2));
  }

  void _drawConstellationLines(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (final line in starCatalogue.lineList) {
      final star1 = starCatalogue.starList[line.hipNumber1];
      final star2 = starCatalogue.starList[line.hipNumber2];
      final altAz1 = sphereModel.equatorialToHorizontal(star1.position);
      final altAz2 = sphereModel.equatorialToHorizontal(star2.position);

      if (altAz1.alt > 0 && altAz2.alt > 0) {
        final p1 = projectionModel.horizontalToXy(altAz1, center, unitLength);
        final p2 = projectionModel.horizontalToXy(altAz2, center, unitLength);
        if ((p1 - p2).distance < center.dx) {
          canvas.drawLine(p1, p2, constellationLinePaint);
        }
      }
    }
  }

  void _drawConstellationName(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (final name in starCatalogue.nameList) {
      final altAz = sphereModel.equatorialToHorizontal(name.position);
      if (altAz.alt > 0) {
        final textSpan = TextSpan(
          style: constellationLabelTextStyle,
          text: name.iauAbbr,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        final textSize = textPainter.size;
        final textCenter = textSize.center(Offset.zero);
        textPainter.paint(
            canvas,
            projectionModel.horizontalToXy(altAz, center, unitLength) -
                textCenter);
      }
    }
  }

  void _drawMessierObject(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

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
      final altAz = sphereModel.equatorialToHorizontal(object.position);
      if (!altAz.alt.isNegative) {
        final xy = projectionModel.horizontalToXy(altAz, center, unitLength);
        final majorAxisSize = max(
            12.0,
            lengthOfAltitudeAngle(
                center, unitLength, altAz, object.majorAxisSize ?? 12.0));

        if (object.type == 'Open cluster') {
          _drawOpenCluster(canvas, xy, majorAxisSize);
        } else if (object.type == 'Globular cluster') {
          _drawGlobularCluster(canvas, xy, majorAxisSize);
        } else if (object.type.toLowerCase().contains('nebula')) {
          if (object.type == 'Planetary nebula') {
            _drawPlanetaryNebula(canvas, xy, majorAxisSize);
          } else {
            _drawNebula(canvas, xy, majorAxisSize);
          }
        } else if (object.type.contains('galaxy')) {
          final offset =
              topCenterOfDeepSkyObject(center, unitLength, object) - xy;
          final minorAxisSize = max(6.0, offset.distance);
          final orientationAngle =
              offset.direction - (object.orientationAngle ?? 0.0) * degInRad;
          _drawGalaxy(
              canvas, xy, majorAxisSize, minorAxisSize, orientationAngle);
        } else {
          switch (object.messierNumber) {
            case 1:
              _drawNebula(canvas, xy, majorAxisSize);
              break;
            case 24:
            case 73:
              _drawOpenCluster(canvas, xy, majorAxisSize);
              break;
            case 40:
              _drawDoubleStar(canvas, xy);
              break;
            default:
              break;
          }
        }
        locationTextPainter.paint(canvas, xy + const Offset(10.0, -6.0));
      }
    }
  }

  void _drawOpenCluster(Canvas canvas, Offset offset, double signSize) {
    final radius = signSize * half;
    const stepAngle = fullTurn / 12;
    const sweepAngle = stepAngle / 2;
    for (var angle = 0.0; angle < fullTurn; angle += stepAngle) {
      canvas.drawArc(Rect.fromCircle(center: offset, radius: radius), angle,
          sweepAngle, false, deepSkyObjectThickStrokePaint);
    }
  }

  void _drawGlobularCluster(Canvas canvas, Offset offset, double signSize) {
    final radius = signSize * half;
    canvas.drawCircle(offset, radius, deepSkyObjectStrokePaint);
    canvas.drawLine(offset.translate(0.0, -radius),
        offset.translate(0.0, radius), deepSkyObjectStrokePaint);
    canvas.drawLine(offset.translate(-radius, 0.0),
        offset.translate(radius, 0.0), deepSkyObjectStrokePaint);
  }

  void _drawPlanetaryNebula(Canvas canvas, Offset offset, double signSize) {
    final radius = signSize / 3.0;
    canvas.drawCircle(offset, radius, deepSkyObjectStrokePaint);
    canvas.drawLine(offset.translate(0.0, -radius * 2),
        offset.translate(0.0, -radius), deepSkyObjectStrokePaint);
    canvas.drawLine(offset.translate(0.0, radius * 2),
        offset.translate(0.0, radius), deepSkyObjectStrokePaint);
    canvas.drawLine(offset.translate(-radius * 2, 0.0),
        offset.translate(-radius, 0.0), deepSkyObjectStrokePaint);
    canvas.drawLine(offset.translate(radius * 2, 0.0),
        offset.translate(radius, 0.0), deepSkyObjectStrokePaint);
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
        offset.translate(-radius * 3, 0.0), radius, deepSkyObjectFillPaint);
    canvas.drawCircle(
        offset.translate(radius * 3, 0.0), radius, deepSkyObjectFillPaint);
    canvas.drawRect(
        Rect.fromCenter(center: offset, width: radius * 6, height: radius * 2),
        deepSkyObjectFillPaint);
    canvas.drawCircle(offset, radius, deepSkyObjectFillPaint);
  }

  void _drawFOV(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    final pointList = projectionModel.pointsOnCircle(
        center, unitLength, displaySettings.trueFov / 2 * degInRad);

    final path = Path();
    if (pointList.first.dx < pointList.last.dx) {
      if (pointList[0].dx < pointList[1].dx) {
        pointList.insert(0, Offset(0.0, pointList.first.dy));
        pointList.add(Offset(size.width, pointList.last.dy));
        path.addPolygon(pointList, false);
      } else {
        // Circle is closed.
        path.addPolygon(pointList, true);
      }
    } else {
      if (pointList[0].dx > pointList[1].dx) {
        // Circle is open. Starts from right side.
        pointList.insert(0, Offset(size.width, pointList.first.dy));
        pointList.add(Offset(0.0, pointList.last.dy));
        path.addPolygon(pointList, false);
      } else {
        // Circle is closed.
        path.addPolygon(pointList, true);
      }
    }
    canvas.drawPath(path, fovPaint);
  }

  /// Calculates the radius of objects on the canvas with the logistic function.
  ///
  /// [midPoint] should be calculated with [calculateMidPointOfMagnitude] once.
  /// Don't calculate [midPoint] every time.
  double radiusOfObject(double magnitude, double midPoint) {
    const l = 24.0;

    // r = log(sqrt((1/100)^(1/5))) ∵ magnitude 1 star is exactly 100 times
    // brighter than a magnitude 6 star, and the radius is proportional to the
    // square root of the area.
    const r = -2 * (1 / 5) * (1 / 2) / log10e;
    return l / (1 + exp(-r * (magnitude - midPoint)));
  }

  double calculateMidPointOfMagnitude() =>
      -4.0 + log(projectionModel.scale) * 1.5;

  /// Converts angle to length at a position in horizontal coordinator.
  ///
  /// [angle] is given in arc minutes.
  double lengthOfAltitudeAngle(
      Offset center, double unitLength, Horizontal horizontal, double angle) {
    final alt = horizontal.alt;
    final az = horizontal.az;
    final angleInRadian = angle / 60.0 * degInRad;
    final bottomCenter =
        Horizontal.fromRadians(alt: alt - angleInRadian, az: az);
    return projectionModel.horizontalToXy(bottomCenter, center, unitLength).dy -
        projectionModel.horizontalToXy(horizontal, center, unitLength).dy;
  }

  Offset topCenterOfDeepSkyObject(
      Offset center, double unitLength, DeepSkyObject object) {
    final topCenter = Equatorial.fromRadians(
        dec: object.equatorial.dec +
            (object.minorAxisSize ?? 0.0) / 60 * degInRad,
        ra: object.equatorial.ra);
    final altAzOfTopCenter = sphereModel.equatorialToHorizontal(topCenter);
    return projectionModel.horizontalToXy(altAzOfTopCenter, center, unitLength);
  }
}

double _getUnitLength(Size size) => min(size.width, size.height) * half * 0.9;
