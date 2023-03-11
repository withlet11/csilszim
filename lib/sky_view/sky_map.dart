/*
 * sky_map.dart
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

import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../constants.dart';
import '../provider/sky_view_setting_provider.dart';
import '../utilities/sexagesimal_angle.dart';
import 'configs.dart';
import 'stereographic_projection.dart';

/// A widget that creates a sky map.
class SkyMap extends StatelessWidget {
  final StereographicProjection projectionModel;
  final SphereModel sphereModel;
  final double jd;
  final StarCatalogue starCatalogue;
  final List<Planet> planetList;
  final SkyViewSettings displaySettings;
  final Horizontal mouseAltAz;

  const SkyMap({
    super.key,
    required this.projectionModel,
    required this.sphereModel,
    required this.jd,
    required this.starCatalogue,
    required this.planetList,
    required this.displaySettings,
    required this.mouseAltAz,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ProjectionRenderer(projectionModel, mouseAltAz, sphereModel,
            jd, starCatalogue, planetList, displaySettings));
  }
}

class _ProjectionRenderer extends CustomPainter {
  final StereographicProjection projectionModel;
  final SphereModel sphereModel;
  final double jd;
  final StarCatalogue starCatalogue;
  final List<Planet> planetList;
  final SkyViewSettings displaySettings;
  final Horizontal mouseAltAz;

  const _ProjectionRenderer(
      this.projectionModel,
      this.mouseAltAz,
      this.sphereModel,
      this.jd,
      this.starCatalogue,
      this.planetList,
      this.displaySettings);

  @override
  void paint(Canvas canvas, Size size) {
    _setBackground(canvas, size);

    if (displaySettings.isHorizontalGridVisible) {
      _drawAzimuthGrid(canvas, size);
      _drawAltitudeGrid(canvas, size);
    }
    if (displaySettings.isEquatorialGridVisible) {
      _drawRightAscensionGrid(canvas, size);
      _drawDeclinationGrid(canvas, size);
    }

    _drawDirectionSign(canvas, size, 'N', 0, 24);
    _drawDirectionSign(canvas, size, 'NE', 45, 18);
    _drawDirectionSign(canvas, size, 'E', 90, 24);
    _drawDirectionSign(canvas, size, 'SE', 135, 18);
    _drawDirectionSign(canvas, size, 'S', 180, 24);
    _drawDirectionSign(canvas, size, 'SW', 225, 18);
    _drawDirectionSign(canvas, size, 'W', 270, 24);
    _drawDirectionSign(canvas, size, 'NW', 315, 18);

    _drawStars(canvas, size);

    for (final planet in planetList) {
      _drawPlanet(canvas, size, planet);
    }

    if (displaySettings.isConstellationLineVisible) {
      _drawConstellationLines(canvas, size);
    }

    if (displaySettings.isConstellationNameVisible) {
      _drawConstellationName(canvas, size);
    }

    final altAzText = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
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

  void _setBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    canvas.drawRect(
        Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)), paint);
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
      Canvas canvas, Size size, String sign, int direction, double fontSize) {
    final locationTextSpan = TextSpan(
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
      ),
      text: sign,
    );

    final locationTextPainter = TextPainter(
      text: locationTextSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    locationTextPainter.layout();
    final textSize = locationTextPainter.size;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final position = projectionModel.horizontalToXy(
            Horizontal.fromDegrees(alt: 0, az: direction.toDouble()),
            center,
            unitLength) -
        textSize.center(Offset.zero);

    locationTextPainter.paint(canvas, position);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paintBlur = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    for (final star in starCatalogue.starList) {
      if (star.hipNumber > 0) {
        final size = min(
            3.0 *
                pow(0.63, star.magnitude) *
                (log(projectionModel.scale) * 1.2 + 0.8),
            8.0);
        // if (star.magnitude < 8) {
        if (size > 0.2) {
          final altAz = sphereModel.equatorialToHorizontal(star.position);
          if (altAz.alt > 0) {
            final xy =
                projectionModel.horizontalToXy(altAz, center, unitLength);
            if (size > 4) {
              canvas.drawCircle(xy, size, paintBlur);
              canvas.drawCircle(xy, size - 0.5, paint);
            } else {
              canvas.drawCircle(xy, size, paint);
            }
          }
        }
      }
    }
  }

  void _drawPlanet(Canvas canvas, Size size, Planet planet) {
    final paintBlur = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    final equatorial = planet.vsop87!.toEquatorial();
    final altAz = sphereModel.equatorialToHorizontal(equatorial);
    // if (altAz.alt > 0) {
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final xy = projectionModel.horizontalToXy(altAz, center, unitLength);
    // const size = 4.0;
    // print('name: ${planet.name}, mag: ${planet.magnitude()}');
    final radius = min(
        3.0 *
            pow(0.63, planet.magnitude() ?? 0) *
            (log(projectionModel.scale) * 1.2 + 0.8),
        8.0);
    canvas.drawCircle(xy, radius, paintBlur);
    canvas.drawCircle(xy, radius - 0.5, paint);
    // }
  }

  void _drawConstellationLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

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
        canvas.drawPath(path, paint);
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
          style: const TextStyle(
            color: Colors.lightGreen,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
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
}

double _getUnitLength(Size size) => min(size.width, size.height) * half * 0.9;
