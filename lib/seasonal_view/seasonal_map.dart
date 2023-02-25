/*
 * seasonal_map.dart
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

// import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../constants.dart';
import '../utilities/sexagesimal_angle.dart';
import '../provider/display_setting_provider.dart';
import 'mercator_projection.dart';

/// A widget that creates a sky map.
class SeasonalMap extends StatelessWidget {
  final CylindricalProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final DisplaySettings displaySettings;
  final Equatorial mouseEquatorial;

  const SeasonalMap({
    super.key,
    required this.projectionModel,
    required this.sphereModel,
    required this.starCatalogue,
    required this.displaySettings,
    required this.mouseEquatorial,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ProjectionRenderer(projectionModel, mouseEquatorial,
            sphereModel, starCatalogue, displaySettings));
  }
}

class _ProjectionRenderer extends CustomPainter {
  final CylindricalProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final DisplaySettings displaySettings;
  final Equatorial mouseEquatorial;

  const _ProjectionRenderer(this.projectionModel, this.mouseEquatorial,
      this.sphereModel, this.starCatalogue, this.displaySettings);

  @override
  void paint(Canvas canvas, Size size) {
    _setBackground(canvas, size);
    final center = Offset(size.width, size.height) * half;
    final unitLength = size.height * 0.9 / halfTurn;

    /*
    if (displaySettings.isHorizontalGridVisible) {
      _drawAzimuthGrid(canvas, center, unitLength);
      _drawAltitudeGrid(canvas, center, unitLength);
    }
     */
    if (displaySettings.isEquatorialGridVisible) {
      _drawRightAscensionGrid(canvas, center, unitLength);
      _drawDeclinationGrid(canvas, center, unitLength);
    }

    _drawDirectionSign(canvas, center, unitLength, '00h', 0, 12);
    _drawDirectionSign(canvas, center, unitLength, '03h', 3, 12);
    _drawDirectionSign(canvas, center, unitLength, '06h', 6, 12);
    _drawDirectionSign(canvas, center, unitLength, '09h', 9, 12);
    _drawDirectionSign(canvas, center, unitLength, '12h', 12, 12);
    _drawDirectionSign(canvas, center, unitLength, '15h', 15, 12);
    _drawDirectionSign(canvas, center, unitLength, '18h', 18, 12);
    _drawDirectionSign(canvas, center, unitLength, '21h', 21, 12);

    _drawStars(canvas, center, unitLength);

    if (displaySettings.isConstellationLineVisible) {
      _drawConstellationLines(canvas, center, unitLength);
    }

    if (displaySettings.isConstellationNameVisible) {
      _drawConstellationName(canvas, center, unitLength);
    }

    /*
    final altAzText = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      text:
          'alt: ${DmsAngle.fromDegrees(mouseEquatorial.altInDegrees()).toDmsWithSign()}, '
          'az: ${DmsAngle.fromDegrees(mouseEquatorial.azInDegrees()).toDmsWithoutSign()}',
    );
    final altAzTextPainter = TextPainter(
      text: altAzText,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    altAzTextPainter.layout();
    altAzTextPainter.paint(canvas, const Offset(0, 0));
     */

    final decRaText = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      text:
          'dec: ${DmsAngle.fromDegrees(mouseEquatorial.decInDegrees()).toDmsWithSign()}, '
          'ra: ${HmsAngle.fromHours(mouseEquatorial.raInHours()).toHms()}',
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
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), paint);
  }

  /*
  void _drawAzimuthGrid(Canvas canvas, Offset center, double unitLength) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    for (var azimuth = 0; azimuth < 360; azimuth += 15) {
      final begin = projectionModel.equatorialToXy(
          Horizontal.fromDegrees(alt: 0, az: azimuth.toDouble()),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      final maxAltitude = (azimuth % 90 == 0) ? 90 : 80;
      for (var altitude = 0; altitude <= maxAltitude; altitude += 5) {
        final position = projectionModel.equatorialToXy(
            Horizontal.fromDegrees(
                alt: altitude.toDouble(), az: azimuth.toDouble()),
            center,
            unitLength);
        path.lineTo(position.dx, position.dy);
      }
      canvas.drawPath(path, paint);
    }
  }


  void _drawAltitudeGrid(Canvas canvas, Offset center, double unitLength) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    for (var altitude = 0; altitude < 90; altitude += 10) {
      final begin = projectionModel.equatorialToXy(
          Horizontal.fromDegrees(alt: altitude.toDouble(), az: 0),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      for (var azimuth = 0; azimuth <= 360; azimuth += 3) {
        final position = projectionModel.equatorialToXy(
            Horizontal.fromDegrees(
                alt: altitude.toDouble(), az: azimuth.toDouble()),
            center,
            unitLength);
        path.lineTo(position.dx, position.dy);
      }
      canvas.drawPath(path, paint);
    }
  }
   */

  void _drawRightAscensionGrid(
      Canvas canvas, Offset center, double unitLength) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    for (var ra = 0; ra < 24; ++ra) {
      final begin = projectionModel.equatorialToXy(
              Equatorial.fromDegreesAndHours(dec: -87, ra: ra.toDouble()),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      for (var dec = -87; dec <= 87; dec += 1) {
        final equatorial = Equatorial.fromDegreesAndHours(
            dec: dec.toDouble(), ra: ra.toDouble());
        final position =
            projectionModel.equatorialToXy(equatorial, center, unitLength);
        // if (equatorial.alt < 0) {
        // path.moveTo(position.dx, position.dy);
        // } else {
        path.lineTo(position.dx, position.dy);
        // }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawDeclinationGrid(Canvas canvas, Offset center, double unitLength) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    for (var dec = -80; dec < 90; dec += 10) {
      final begin = projectionModel.equatorialToXy(
          Equatorial.fromDegreesAndHours(dec: dec.toDouble(), ra: 0),
          center,
          unitLength);
      final path = Path()..moveTo(begin.dx, begin.dy);
      for (double ra = 0; ra <= 24; ra += 1 / 16) {
        final equatorial = Equatorial.fromDegreesAndHours(
                dec: dec.toDouble(), ra: ra.toDouble());
        final position =
            projectionModel.equatorialToXy(equatorial, center, unitLength);
        // if (equatorial.alt < 0) {
          // path.moveTo(position.dx, position.dy);
        // } else {
          path.lineTo(position.dx, position.dy);
        // }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawDirectionSign(Canvas canvas, Offset center, double unitLength,
      String sign, int direction, double fontSize) {
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
    final width = locationTextPainter.size.width;
    final height = locationTextPainter.size.height;

    final position = projectionModel.equatorialToXy(
            Equatorial.fromDegreesAndHours(dec: 0, ra: direction), center, unitLength) -
        Offset(width, height) / 2;

    locationTextPainter.paint(canvas, position);
  }

  void _drawStars(Canvas canvas, Offset center, double unitLength) {
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

    for (final star in starCatalogue.starList) {
      if (star.hipNumber > 0) {
        final size = min(
            3.0 *
                pow(0.63, star.magnitude) *
                (log(projectionModel.scale) * 1.2 + 1.8),
            8.0);
        // if (star.magnitude < 8) {
        if (size > 0.2) {
          final equatorial = star.position;
          // if (equatorial.alt > 0) {
          final xy =
              projectionModel.equatorialToXy(equatorial, center, unitLength);
          if (size > 4) {
            canvas.drawCircle(xy, size, paintBlur);
            canvas.drawCircle(xy, size - 0.5, paint);
          } else {
            canvas.drawCircle(xy, size, paint);
          }
          // }
        }
      }
    }
  }

  /*
  void _drawPlanet(
      Canvas canvas, Offset center, double unitLength, Planet planet) {
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
    final xy = projectionModel.horizontalToXy(altAz, center, unitLength);
    // const size = 4.0;
    print('name: ${planet.name}, mag: ${planet.magnitude()}');
    final size = min(
        3.0 *
            pow(0.63, planet.magnitude() ?? 0) *
            (log(projectionModel.scale) * 1.2 + 0.8),
        8.0);
    canvas.drawCircle(xy, size, paintBlur);
    canvas.drawCircle(xy, size - 0.5, paint);
    // }
  }
   */

  void _drawConstellationLines(
      Canvas canvas, Offset center, double unitLength) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    for (final line in starCatalogue.lineList) {
      final star1 = starCatalogue.starList[line.hipNumber1];
      final star2 = starCatalogue.starList[line.hipNumber2];
      // final altAz1 = sphereModel.equatorialToHorizontal(star1.position);
      // final altAz2 = sphereModel.equatorialToHorizontal(star2.position);

      // if (altAz1.alt > 0 && altAz2.alt > 0) {
      final begin =
          projectionModel.equatorialToXy(star1.position, center, unitLength);
      final end =
          projectionModel.equatorialToXy(star2.position, center, unitLength);
      final path = Path()
        ..moveTo(begin.dx, begin.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
      // }
    }
  }

  void _drawConstellationName(Canvas canvas, Offset center, double unitLength) {
    for (final name in starCatalogue.nameList) {
      // final altAz = sphereModel.equatorialToHorizontal(name.position);
      // if (altAz.alt > 0) {
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
      final offset = Offset(
              locationTextPainter.size.width, locationTextPainter.size.height) /
          2;

      locationTextPainter.paint(
          canvas,
          projectionModel.equatorialToXy(name.position, center, unitLength) -
              offset);
      // }
    }
  }
}
