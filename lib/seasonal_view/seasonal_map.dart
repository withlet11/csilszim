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
import 'dart:ui';

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
  final MercatorProjection projectionModel;
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
  final MercatorProjection projectionModel;
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

      for (var i = -80; i <= 80; i += 10) {
        _drawDecNumber(canvas, center, unitLength, i, 12);
      }

      for (var i = 0; i < 24; i += 3) {
        _drawRaNumber(canvas, center, unitLength, i, 12);
      }
    }

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
        fontFeatures: [FontFeature.tabularFigures()],
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

    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final width = center.dx * 2;
    final height = center.dy * 2;

    for (var ra = 0; ra < 24; ++ra) {
      final pointOnLine = projectionModel.equatorialToXy(
          Equatorial.fromDegreesAndHours(dec: 0, ra: ra.toDouble()),
          center,
          unitLength);
      for (var x = pointOnLine.dx % lengthOfFullTurn;
          x < width;
          x += lengthOfFullTurn) {
        final path = Path()..moveTo(x, 0);
        path.lineTo(x, height);
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDeclinationGrid(Canvas canvas, Offset center, double unitLength) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    final width = center.dx * 2;

    for (var dec = -80; dec < 90; dec += 10) {
      final pointOnLine = projectionModel.equatorialToXy(
          Equatorial.fromDegreesAndHours(dec: dec.toDouble(), ra: 0),
          center,
          unitLength);
      final y = pointOnLine.dy;
      final path = Path()..moveTo(0, y);
      path.lineTo(width, y);
      canvas.drawPath(path, paint);
    }
  }

  void _drawDecNumber(Canvas canvas, Offset center, double unitLength, int dec,
      double fontSize) {
    final sign = '${dec.isNegative ? '$dec' : '+$dec'}\u00b0';

    final locationTextSpan = TextSpan(
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      text: sign,
    );

    final locationTextPainter = TextPainter(
      text: locationTextSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    locationTextPainter.layout();
    final textWidth = locationTextPainter.size.width;
    final textHeight = locationTextPainter.size.height;

    final width = center.dx * 2;

    final position = projectionModel.equatorialToXy(
            Equatorial.fromDegreesAndHours(dec: dec, ra: 0),
            center,
            unitLength) -
        Offset(textWidth, textHeight) / 2;
    final y = position.dy;

    locationTextPainter.paint(canvas, Offset(10, y));
    locationTextPainter.paint(canvas, Offset(width - 10 - textWidth, y));
  }

  void _drawRaNumber(Canvas canvas, Offset center, double unitLength, int ra,
      double fontSize) {
    final sign = '${ra}h'.padLeft(3, '0');

    final locationTextSpan = TextSpan(
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      text: sign,
    );

    final locationTextPainter = TextPainter(
      text: locationTextSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    locationTextPainter.layout();
    final testWidth = locationTextPainter.size.width;
    final textHeight = locationTextPainter.size.height;

    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final width = center.dx * 2;

    final position = projectionModel.equatorialToXy(
            Equatorial.fromDegreesAndHours(dec: 0, ra: ra),
            center,
            unitLength) -
        Offset(testWidth, textHeight) / 2;
    final y = position.dy;

    for (var x = position.dx % lengthOfFullTurn;
        x < width;
        x += lengthOfFullTurn) {
      locationTextPainter.paint(canvas, Offset(x, y));
    }
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

    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final width = center.dx * 2;

    for (final star in starCatalogue.starList) {
      if (star.hipNumber > 0) {
        final size = min(
            3.0 *
                pow(0.63, star.magnitude) *
                (log(projectionModel.scale) * 1.2 + 1.8),
            8.0);
        if (star.magnitude < 8) {
          if (size > 0.2) {
            final xy = projectionModel.equatorialToXy(
                star.position, center, unitLength);
            final y = xy.dy;
            for (var x = xy.dx % lengthOfFullTurn;
                x < width;
                x += lengthOfFullTurn) {
              final position = Offset(x, y);
              if (size > 4) {
                canvas.drawCircle(position, size, paintBlur);
                canvas.drawCircle(position, size - 0.5, paint);
              } else {
                canvas.drawCircle(position, size, paint);
              }
            }
          }
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

    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final width = center.dx * 2;

    for (final line in starCatalogue.lineList) {
      final star1 = starCatalogue.starList[line.hipNumber1];
      final star2 = starCatalogue.starList[line.hipNumber2];

      final position1 =
          projectionModel.equatorialToXy(star1.position, center, unitLength);
      final position2 =
          projectionModel.equatorialToXy(star2.position, center, unitLength);

      final double x1, y1, dx, dy;
      if (position1.dx - position2.dx > lengthOfFullTurn / 2) {
        x1 = position1.dx % lengthOfFullTurn;
        y1 = position1.dy;
        dx = position2.dx - position1.dx + lengthOfFullTurn;
        dy = position2.dy - position1.dy;
      } else if (position2.dx - position1.dx > lengthOfFullTurn / 2) {
        x1 = position2.dx % lengthOfFullTurn;
        y1 = position2.dy;
        dx = position1.dx - position2.dx + lengthOfFullTurn;
        dy = position1.dy - position2.dy;
      } else if (position1.dx < position2.dx) {
        x1 = position1.dx % lengthOfFullTurn;
        y1 = position1.dy;
        dx = position2.dx - position1.dx;
        dy = position2.dy - position1.dy;
      } else {
        x1 = position2.dx % lengthOfFullTurn;
        y1 = position2.dy;
        dx = position1.dx - position2.dx;
        dy = position1.dy - position2.dy;
      }

      for (var x = x1; x < width; x += lengthOfFullTurn) {
        final path = Path()
          ..moveTo(x, y1)
          ..lineTo(x + dx, y1 + dy);
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawConstellationName(Canvas canvas, Offset center, double unitLength) {
    for (final name in starCatalogue.nameList) {
      final locationTextSpan = TextSpan(
        style: const TextStyle(
          color: Colors.lightGreen,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          fontFeatures: [FontFeature.tabularFigures()],
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

      final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
      final width = center.dx * 2;

      final xy =
          projectionModel.equatorialToXy(name.position, center, unitLength) -
              offset;
      final y = xy.dy;

      for (var x = xy.dx % lengthOfFullTurn; x < width; x += lengthOfFullTurn) {
        locationTextPainter.paint(canvas, Offset(x, y));
      }
    }
  }
}
