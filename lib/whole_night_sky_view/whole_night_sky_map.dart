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

import 'package:flutter/material.dart';

import '../astronomical/astronomical_object/deep_sky_object.dart';
import '../astronomical/coordinate_system/ecliptic_coordinate.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../constants.dart';
import '../provider/whole_night_sky_view_setting_provider.dart';
import '../utilities/sexagesimal_angle.dart';
import 'configs.dart';
import 'mercator_projection.dart';

/// A widget that creates a whole night sky map.
class WholeNightSkyMap extends StatelessWidget {
  final MercatorProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final WholeNightSkyViewSettings displaySettings;
  final Equatorial mouseEquatorial;
  final Equatorial sunEquatorial;
  final Map<String, Equatorial> planetEquatorialList;
  final Map<String, String> planetNameList;

  const WholeNightSkyMap({
    super.key,
    required this.projectionModel,
    required this.sphereModel,
    required this.starCatalogue,
    required this.displaySettings,
    required this.mouseEquatorial,
    required this.sunEquatorial,
    required this.planetEquatorialList,
    required this.planetNameList,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ProjectionRenderer(
            projectionModel,
            mouseEquatorial,
            sphereModel,
            starCatalogue,
            displaySettings,
            sunEquatorial,
            planetEquatorialList,
            planetNameList));
  }
}

class _ProjectionRenderer extends CustomPainter {
  final MercatorProjection projectionModel;
  final SphereModel sphereModel;
  final StarCatalogue starCatalogue;
  final WholeNightSkyViewSettings displaySettings;
  final Equatorial mouseEquatorial;
  final Equatorial sunEquatorial;
  final Map<String, Equatorial> planetEquatorialList;
  final Map<String, String> planetNameList;

  const _ProjectionRenderer(
    this.projectionModel,
    this.mouseEquatorial,
    this.sphereModel,
    this.starCatalogue,
    this.displaySettings,
    this.sunEquatorial,
    this.planetEquatorialList,
    this.planetNameList,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _setBackground(canvas, size);

    if (displaySettings.isEquatorialGridVisible) {
      _drawRightAscensionGrid(canvas, size);
      _drawDeclinationGrid(canvas, size);
      _drawEclipticLine(canvas, size);

      for (var i = -80; i <= 80; i += 10) {
        _drawDecNumber(canvas, size, i);
      }

      for (var i = 0; i < 24; ++i) {
        _drawRaNumber(canvas, size, i);
      }
    }

    _drawStars(canvas, size);

    if (displaySettings.isConstellationLineVisible) {
      _drawConstellationLines(canvas, size);
    }

    if (displaySettings.isConstellationNameVisible) {
      _drawConstellationName(canvas, size);
    }

    _drawMessierObject(canvas, size);
    _drawPlanet(canvas, size);

    _drawAstronomicalTwilight(canvas, size, sunEquatorial);
    _drawNauticalTwilight(canvas, size, sunEquatorial);
    _drawCivilTwilight(canvas, size, sunEquatorial);
    _drawDay(canvas, size, sunEquatorial);
    _drawHorizon(canvas, size);

    final decRaText = TextSpan(
      style: decRaTextStyle,
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
      ..color = nightSkyColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)), paint);
  }

  void _drawRightAscensionGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = raGridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = raGridWidth;

    final width = size.width;
    final height = size.height;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

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

  void _drawDeclinationGrid(Canvas canvas, Size size) {
    final decLine = Paint()
      ..color = decGridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = decGridWidth;

    final equatorialLine = Paint()
      ..color = equatorialLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = equatorialLineWidth;

    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    for (var dec = -80; dec < 90; dec += 10) {
      final pointOnLine = projectionModel.equatorialToXy(
          Equatorial.fromDegreesAndHours(dec: dec.toDouble(), ra: 0),
          center,
          unitLength);
      final y = pointOnLine.dy;
      final path = Path()..moveTo(0, y);
      path.lineTo(width, y);
      canvas.drawPath(path, dec == 0 ? equatorialLine : decLine);
    }
  }

  void _drawEclipticLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = eclipticLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = eclipticLineWidth;

    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    var list = <Offset>[];
    for (var long = -180; long < 180; long += 5) {
      final ecliptic = Ecliptic.fromDegrees(long: long.toDouble(), lat: 0.0);
      final equatorial = ecliptic.toEquatorial();
      list.add(projectionModel.equatorialToXy(equatorial, center, unitLength));
    }

    var firstX = list[0].dx;
    while (firstX < width) {
      firstX += lengthOfFullTurn;
    }
    var shift = firstX - list[0].dx;
    final path = Path()..moveTo(list[0].dx + shift, list[0].dy);

    for (; list[0].dx + shift > 0; shift -= lengthOfFullTurn) {
      for (final offset in list) {
        path.lineTo(offset.dx + shift, offset.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawDecNumber(Canvas canvas, Size size, int dec) {
    final sign = '${dec.isNegative ? '$dec' : '+$dec'}\u00b0';
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
    final position = projectionModel.equatorialToXy(
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

    final position = projectionModel.equatorialToXy(
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

  void _drawHorizon(Canvas canvas, Size size) {
    var list = <Offset>[];
    final crossingUpperMeridianAndHorizon = Horizontal.fromRadians(
        alt: 0, az: sphereModel.isNorthernHemisphere ? halfTurn : 0.0);
    final equatorial =
        sphereModel.horizontalToEquatorial(crossingUpperMeridianAndHorizon);

    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final xy = projectionModel.equatorialToXy(equatorial, center, unitLength);
    final origin = Offset(0.0, xy.dy);
    list = [origin, size.topRight(origin)];
    final path = _preparePathOfZone(list, size);
    final paint = Paint()
      ..color = horizonColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  void _drawDay(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(
        canvas,
        size,
        sun,
        sphereModel.raOnEastHorizonAtSunrise,
        sphereModel.raOnWestHorizonAtSunset,
        dayColor);
  }

  void _drawCivilTwilight(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(
        canvas,
        size,
        sun,
        sphereModel.raOnEastHorizonAtCivilDawn,
        sphereModel.raOnWestHorizonAtCivilDusk,
        civilTwilightColor);
  }

  void _drawNauticalTwilight(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(
        canvas,
        size,
        sun,
        sphereModel.raOnEastHorizonAtNauticalDawn,
        sphereModel.raOnWestHorizonAtNauticalDusk,
        nauticalTwilightColor);
  }

  void _drawAstronomicalTwilight(Canvas canvas, Size size, Equatorial sun) {
    _drawZoneAndLineOfTwilight(
        canvas,
        size,
        sun,
        sphereModel.raOnEastHorizonAtAstronomicalDawn,
        sphereModel.raOnWestHorizonAtAstronomicalDusk,
        astronomicalTwilightColor);
  }

  void _drawZoneAndLineOfTwilight(
      Canvas canvas,
      Size size,
      Equatorial sun,
      double? Function(Equatorial, double) raOnEastHorizon,
      double? Function(Equatorial, double) raOnWestHorizon,
      Color zoneColor) {
    var zoneGridList1 = <Offset>[];
    var lineGridList2 = <Offset>[];
    var zoneGridList2 = <Offset>[];
    var lineGridList1 = <Offset>[];

    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);

    for (var deg = 90.0; deg >= -90.0; deg -= 0.5) {
      final dec = deg * degInRad;
      final ra = raOnEastHorizon(sun, dec);
      if (ra != null) {
        if (ra - sun.ra > halfTurn) {
          zoneGridList1.add(projectionModel.equatorialToXy(
              Equatorial.fromRadians(dec: dec, ra: ra), center, unitLength));
        } else {
          lineGridList1.add(projectionModel.equatorialToXy(
              Equatorial.fromRadians(dec: dec, ra: ra), center, unitLength));
        }
      }
    }

    for (var deg = -90.0; deg <= 90.0; deg += 0.5) {
      final dec = deg * degInRad;
      final ra = raOnWestHorizon(sun, dec);
      if (ra != null) {
        if (ra - sun.ra < halfTurn) {
          zoneGridList2.add(projectionModel.equatorialToXy(
              Equatorial.fromRadians(dec: dec, ra: ra), center, unitLength));
        } else {
          lineGridList2.add(projectionModel.equatorialToXy(
              Equatorial.fromRadians(dec: dec, ra: ra), center, unitLength));
        }
      }
    }

    final List<Offset> zoneGridList;
    final List<Offset> lineGridList;

    if (sphereModel.isNorthernHemisphere) {
      if (zoneGridList1.isEmpty) {
        if (sun.dec > 0) {
          zoneGridList = [
            size.topLeft(Offset.zero),
            size.topRight(Offset.zero)
          ];
          _drawZoneTwilight(canvas, size, zoneColor, zoneGridList);
        }
      } else {
        zoneGridList = zoneGridList1 + zoneGridList2;
        _drawZoneTwilight(canvas, size, zoneColor, zoneGridList);
      }
      lineGridList = lineGridList2 + lineGridList1;
    } else {
      if (zoneGridList1.isEmpty) {
        if (sun.dec < 0) {
          zoneGridList = [
            size.bottomLeft(Offset.zero),
            size.bottomRight(Offset.zero)
          ];
          _drawZoneTwilight(canvas, size, zoneColor, zoneGridList);
        }
      } else {
        zoneGridList = (zoneGridList2 + zoneGridList1).reversed.toList();
        _drawZoneTwilight(canvas, size, zoneColor, zoneGridList);
      }
      lineGridList = (lineGridList1 + lineGridList2).reversed.toList();
    }

    if (lineGridList.isNotEmpty) {
      _drawLineTwilight(canvas, size, zoneColor, lineGridList);
    }
  }

  void _drawZoneTwilight(
      Canvas canvas, Size size, Color zoneColor, List<Offset> zoneGridList) {
    final zonePath = _preparePathOfZone(zoneGridList, size);
    final zonePaint = Paint()
      ..color = zoneColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(zonePath, zonePaint);
  }

  void _drawLineTwilight(
      Canvas canvas, Size size, Color zoneColor, List<Offset> lineGridList) {
    final linePath = _preparePathOfZone(lineGridList, size);
    final linePaint = Paint()
      ..color = zoneColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = twilightLineWidth;
    canvas.drawPath(linePath, linePaint);
  }

  Path _preparePathOfZone(List<Offset> list, Size size) {
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);
    final firstX = list[0].dx % lengthOfFullTurn - lengthOfFullTurn;
    var shift = firstX - list[0].dx;
    final path = Path()..moveTo(list[0].dx + shift, list[0].dy);

    final width = size.width;
    for (; list[0].dx + shift < width; shift += lengthOfFullTurn) {
      for (final offset in list) {
        path.lineTo(offset.dx + shift, offset.dy);
      }
    }

    final bottom = sphereModel.isNorthernHemisphere ? size.height : 0.0;
    path.lineTo(width, list.last.dy);
    path.lineTo(width, bottom);
    path.lineTo(0, bottom);
    return path;
  }

  void _drawStars(Canvas canvas, Size size) {
    final paintBlur = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    for (final star in starCatalogue.starList) {
      if (star.hipNumber > 0) {
        final radius = min(
            3.0 *
                pow(0.63, star.magnitude) *
                (log(projectionModel.scale) * 1.2 + 1.8),
            8.0);
        if (star.magnitude < 8) {
          if (radius > 0.2) {
            final xy = projectionModel.equatorialToXy(
                star.position, center, unitLength);
            final y = xy.dy;
            for (var x = xy.dx % lengthOfFullTurn;
                x < width;
                x += lengthOfFullTurn) {
              final position = Offset(x, y);
              if (radius > 4) {
                canvas.drawCircle(position, radius, paintBlur);
                canvas.drawCircle(position, radius - 0.5, paint);
              } else {
                canvas.drawCircle(position, radius, paint);
              }
            }
          }
        }
      }
    }
  }

  void _drawConstellationLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = constellationLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = constellationLineWidth;

    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

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

  void _drawConstellationName(Canvas canvas, Size size) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    for (final name in starCatalogue.nameList) {
      final locationTextSpan = TextSpan(
        style: constellationNameTextStyle,
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
          projectionModel.equatorialToXy(name.position, center, unitLength) -
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
        style: decTextStyle,
        text: 'M${object.messierNumber}',
      );

      final locationTextPainter = TextPainter(
        text: locationTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      locationTextPainter.layout();
      final xy =
          projectionModel.equatorialToXy(object.position, center, unitLength);
      final y = xy.dy;

      for (var x = xy.dx % lengthOfFullTurn; x < width; x += lengthOfFullTurn) {
        if (object.type == 'Open cluster') {
          _drawOpenCluster(canvas, Offset(x, y));
        } else if (object.type == 'Globular cluster') {
          _drawGlobularCluster(canvas, Offset(x, y));
        } else if (object.type.toLowerCase().contains('nebula')) {
          if (object.type == 'Planetary nebula') {
            _drawPlanetaryNebula(canvas, Offset(x, y));
          } else {
            _drawNebula(canvas, Offset(x, y));
          }
        } else if (object.type.contains('galaxy')) {
          _drawGalaxy(canvas, Offset(x, y));
        } else {
          switch (object.messierNumber) {
            case 1:
              _drawNebula(canvas, Offset(x, y));
              break;
            case 24:
            case 73:
              _drawOpenCluster(canvas, Offset(x, y));
              break;
            case 40:
              _drawDoubleStar(canvas, Offset(x, y));
              break;
            default:
              break;
          }
        }
        locationTextPainter.paint(canvas, Offset(x + 8.0, y - 6.0));
      }
    }
  }

  void _drawPlanet(Canvas canvas, Size size) {
    final width = size.width;
    final center = size.center(Offset.zero);
    final unitLength = _getUnitLength(size);
    final lengthOfFullTurn = projectionModel.lengthOfFullTurn(unitLength);

    const radius = 3.0;
    planetEquatorialList.forEach((String name, Equatorial equatorial) {
      final xy = projectionModel.equatorialToXy(equatorial, center, unitLength);
      final y = xy.dy;
      for (var x = xy.dx % lengthOfFullTurn; x < width; x += lengthOfFullTurn) {
        final position = Offset(x, y);
        canvas.drawCircle(position, radius, planetEdgePaint);
        canvas.drawCircle(position, radius - 0.5, planetBodyPaint);
        final path = Path()
          ..moveTo(position.dx + 4, position.dy - 4)
          ..relativeLineTo(12.0, -12.0)
          ..relativeLineTo(20.0, 0.0);
        canvas.drawPath(path, planetPointerPaint);

        final locationTextSpan =
            TextSpan(style: planetNameTextStyle, text: planetNameList[name]);

        final nameTextPainter = TextPainter(
          text: locationTextSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        nameTextPainter.layout();
        final textPosition = position + const Offset(40.0, -22.0);
        nameTextPainter.paint(canvas, textPosition);
      }
    });
  }

  void _drawOpenCluster(Canvas canvas, Offset offset) {
    const radius = 6.0;
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

  void _drawGlobularCluster(Canvas canvas, Offset offset) {
    const radius = 6.0;
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

  void _drawPlanetaryNebula(Canvas canvas, Offset offset) {
    const radius = 3.0;
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

  void _drawNebula(Canvas canvas, Offset offset) {
    const length = 12.0;
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(
        Rect.fromCenter(center: offset, width: length, height: length), paint);
  }

  void _drawGalaxy(Canvas canvas, Offset offset) {
    const width = 12.0;
    const height = width / 2;
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawOval(
        Rect.fromCenter(center: offset, width: width, height: height), paint);
  }

  void _drawDoubleStar(Canvas canvas, Offset offset) {
    const radius = 1.5;
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset.translate(-radius * 3, 0.0), radius, paint);
    canvas.drawCircle(offset.translate(radius * 3, 0.0), radius, paint);
    canvas.drawRect(
        Rect.fromCenter(center: offset, width: 9.0, height: 3.0), paint);
    canvas.drawCircle(offset, radius, paint);
  }
}

double _getUnitLength(Size size) => size.height * 0.9 / halfTurn;
