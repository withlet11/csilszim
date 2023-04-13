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

import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
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
  final MomentarySkyViewSettings displaySettings;
  final Horizontal mouseAltAz;

  const MomentarySkyMap({
    super.key,
    required this.projectionModel,
    required this.sphereModel,
    required this.starCatalogue,
    required this.planetList,
    required this.displaySettings,
    required this.mouseAltAz,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ProjectionRenderer(projectionModel, mouseAltAz, sphereModel,
            starCatalogue, planetList, displaySettings));
  }
}

class _ProjectionRenderer extends CustomPainter {
  final StereographicProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final List<Planet> planetList;
  final MomentarySkyViewSettings displaySettings;
  final Horizontal mouseAltAz;

  const _ProjectionRenderer(
      this.projectionModel,
      this.mouseAltAz,
      this.sphereModel,
      this.starCatalogue,
      this.planetList,
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

    const signList = [
      Tuple3<String, int, bool>('N', 0, true),
      Tuple3<String, int, bool>('NE', 45, false),
      Tuple3<String, int, bool>('E', 90, true),
      Tuple3<String, int, bool>('SE', 135, false),
      Tuple3<String, int, bool>('S', 180, true),
      Tuple3<String, int, bool>('SW', 225, false),
      Tuple3<String, int, bool>('W', 270, true),
      Tuple3<String, int, bool>('NW', 315, false),
    ];

    _drawDirectionSign(canvas, size, signList);

    _drawStars(canvas, size);

    final x0 = x0ForCalculatingRadiusOfObject();
    for (final planet in planetList) {
      _drawPlanet(canvas, size, planet, x0);
    }

    if (displaySettings.isConstellationLineVisible) {
      _drawConstellationLines(canvas, size);
    }

    if (displaySettings.isConstellationNameVisible) {
      _drawConstellationName(canvas, size);
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

    final Color innerPartColor;
    final Color outerPartColor;
    if (projectionModel.centerAltAz.alt.isNegative) {
      innerPartColor = horizonColor;
      outerPartColor = backgroundColor;
    } else {
      innerPartColor = backgroundColor;
      outerPartColor = horizonColor;
    }

    final outerPartPaint = Paint()
      ..color = outerPartColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
        outerPartPaint);

    final innerPartPaint = Paint()
      ..color = innerPartColor
      ..style = PaintingStyle.fill;

    final list = [
      for (var i = 0; i < 360; ++i)
        projectionModel.horizontalToXy(
            Horizontal.fromDegrees(alt: 0, az: i.toDouble()),
            center,
            unitLength),
    ];

    final path = Path();
    path.addPolygon(list, true);
    canvas.drawPath(path, innerPartPaint);
  }

  void _drawAzimuthGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (var azimuth = 0; azimuth < 360; azimuth += 15) {
      final begin = projectionModel.horizontalToXy(
          Horizontal.fromDegrees(alt: 0, az: azimuth.toDouble()),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      final maxAltitude = (azimuth % 90 == 0) ? 90 : 80;
      for (var altitude = 0; altitude <= maxAltitude; altitude += 5) {
        final position = projectionModel.horizontalToXy(
            Horizontal.fromDegrees(
                alt: altitude.toDouble(), az: azimuth.toDouble()),
            center,
            unitLength);
        path.lineTo(position.dx, position.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawAltitudeGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (var altitude = 0; altitude < 90; altitude += 10) {
      final begin = projectionModel.horizontalToXy(
          Horizontal.fromDegrees(alt: altitude.toDouble(), az: 0),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      for (var azimuth = 0; azimuth <= 360; azimuth += 3) {
        final position = projectionModel.horizontalToXy(
            Horizontal.fromDegrees(
                alt: altitude.toDouble(), az: azimuth.toDouble()),
            center,
            unitLength);
        path.lineTo(position.dx, position.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawRightAscensionGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

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
        if (horizontal.alt < 0) {
          path.moveTo(position.dx, position.dy);
        } else {
          path.lineTo(position.dx, position.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawDeclinationGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

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
        if (horizontal.alt < 0) {
          path.moveTo(position.dx, position.dy);
        } else {
          path.lineTo(position.dx, position.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawDirectionSign(
      Canvas canvas, Size size, List<Tuple3<String, int, bool>> list) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    for (final e in list) {
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

  void _drawStars(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final x0 = x0ForCalculatingRadiusOfObject();
    for (final star in starCatalogue.starList) {
      if (star.hipNumber > 0) {
        final size = radiusOfObject(star.magnitude, x0);
        if (size > 0.25) {
          final altAz = sphereModel.equatorialToHorizontal(star.position);
          if (!altAz.alt.isNegative) {
            final xy =
                projectionModel.horizontalToXy(altAz, center, unitLength);
            if (size > 3.0) {
              canvas.drawCircle(xy, 3.0 + (size - 3.0) * 0.8, starBlurPaint);
              canvas.drawCircle(xy, 3.0 + (size - 3.0) * 0.5, starPaint);
            } else {
              canvas.drawCircle(xy, size, starPaint);
            }
          }
        }
      }
    }
  }

  void _drawPlanet(Canvas canvas, Size size, Planet planet, double x0) {
    final altAz = sphereModel.equatorialToHorizontal(planet.equatorial);
    if (altAz.alt > 0) {
      final center = size.center(Offset.zero);
      final unitLength = _getUnitLength(size);
      final xy = projectionModel.horizontalToXy(altAz, center, unitLength);
      final radius = radiusOfObject(planet.magnitude() ?? 0.0, x0);
      if (radius > 3.0) {
        canvas.drawCircle(xy, 3.0 + (radius - 3.0) * 0.8, starBlurPaint);
        canvas.drawCircle(xy, 3.0 + (radius - 3.0) * 0.5, starPaint);
      } else {
        canvas.drawCircle(xy, radius, starPaint);
      }
    }
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
        final begin =
            projectionModel.horizontalToXy(altAz1, center, unitLength);
        final end = projectionModel.horizontalToXy(altAz2, center, unitLength);
        final path = Path()
          ..moveTo(begin.dx, begin.dy)
          ..lineTo(end.dx, end.dy);
        canvas.drawPath(path, constellationLinePaint);
      }
    }
  }

  void _drawConstellationName(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (final name in starCatalogue.nameList) {
      final altAz = sphereModel.equatorialToHorizontal(name.position);
      if (altAz.alt > 0) {
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
        final textSize = locationTextPainter.size;
        final textCenter = textSize.center(Offset.zero);
        locationTextPainter.paint(
            canvas,
            projectionModel.horizontalToXy(altAz, center, unitLength) -
                textCenter);
      }
    }
  }

  /// Calculates the radius of objects on the canvas with the logistic function.
  ///
  /// [x0] should be calculated with x0ForCalculatingRadiusOfObject() once.
  /// Don't calculate [x0] every time.
  double radiusOfObject(double magnitude, double x0) {
    const l = 24.0;

    // log(sqrt((1/100)^(1/5))) ∵ magnitude 1 star is exactly 100 times brighter
    // than a magnitude 6 star, and the radius is square root of the area.
    const r = -2 * (1 / 5) * (1 / 2) / log10e;
    return l / (1 + exp(-r * (magnitude - x0)));
  }

  double x0ForCalculatingRadiusOfObject() =>
      -4.0 + log(projectionModel.scale) * 1.5;
}

double _getUnitLength(Size size) => min(size.width, size.height) * half * 0.9;
