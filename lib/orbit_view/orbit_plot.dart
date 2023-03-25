/*
 * orbit_plot.dart
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../astronomical/orbit_calculation/orbit_calculation.dart';
import '../astronomical/solar_system.dart';
import '../astronomical/time_model.dart';
import '../constants.dart';
import '../utilities/offset_3d.dart';
import 'graphical_projection/graphical_projection.dart';
import 'graphical_projection/perspective.dart';
import 'configs.dart';
import 'orbitViewSettingProvider.dart';

/// A widget that displays the solar system.
class OrbitPlot extends ConsumerWidget {
  final GraphicalProjection projection;
  final double zoom;
  final TimeModel timeModel;
  final double interval;
  final int repetition;

  const OrbitPlot(
      {super.key,
      required this.projection,
      required this.zoom,
      required this.timeModel,
      required this.interval,
      required this.repetition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final settings = ref.watch(orbitViewSettingProvider);
    final nameList = {
      'mercury': localizations.mercury,
      'venus': localizations.venus,
      'earth': localizations.earth,
      'mars': localizations.mars,
      'jupiter': localizations.jupiter,
      'saturn': localizations.saturn,
      'uranus': localizations.uranus,
      'neptune': localizations.neptune,
      'ceres': localizations.ceres,
      'pluto': localizations.pluto,
      'haumea': localizations.haumea,
      'makemake': localizations.makemake,
      'eris': localizations.eris,
      'halley': localizations.halley,
      'encke': localizations.encke,
      'biela': localizations.biela,
      'faye': localizations.faye,
      'brorsen': localizations.brorsen,
      'dArrest': localizations.dArrest,
      'ponsWinnecke': localizations.ponsWinnecke,
      'tuttle': localizations.tuttle,
      'tempel1': localizations.tempel1,
      'tempel2': localizations.tempel2,
    };
    final planetVisibility = {
      'mercury': settings.isMercuryVisible,
      'venus': settings.isVenusVisible,
      'earth': settings.isEarthVisible,
      'mars': settings.isMarsVisible,
      'jupiter': settings.isJupiterVisible,
      'saturn': settings.isSaturnVisible,
      'uranus': settings.isUranusVisible,
      'neptune': settings.isNeptuneVisible,
      'ceres': settings.isCeresVisible,
      'pluto': settings.isPlutoVisible,
      'eris': settings.isErisVisible,
      'haumea': settings.isHaumeaVisible,
      'makemake': settings.isMakemakeVisible,
      'halley': settings.isHalleyVisible,
      'encke': settings.isEnckeVisible,
      'faye': settings.isFayeVisible,
      'dArrest': settings.isDArrestVisible,
      'ponsWinnecke': settings.isPonsWinneckeVisible,
      'tuttle': settings.isTuttleVisible,
      'tempel1': settings.isTempel1Visible,
      'tempel2': settings.isTempel2Visible,
    };
    return CustomPaint(
        painter: _ProjectionRenderer(projection, zoom, timeModel, interval,
            repetition, nameList, planetVisibility));
  }
}

class _ProjectionRenderer extends CustomPainter {
  final GraphicalProjection projection;
  final double zoom;
  final TimeModel timeModel;
  final double interval;
  final int repetition;
  final Map<String, String> nameList;
  final Map<String, bool> planetVisibility;

  const _ProjectionRenderer(this.projection, this.zoom, this.timeModel,
      this.interval, this.repetition, this.nameList, this.planetVisibility);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final scale = min(size.width, size.height) * half * zoom;

    _setBackground(canvas, size);
    _drawDirectionOfVernalPoint(canvas, center, zoom);
    _drawOrbitOfPlanet(canvas, center, scale);
    _drawOrbitOfDwarfPlanet(canvas, center, scale);
    _drawOrbitOfComets(canvas, center, scale);

    final list = <_PositionAndColor>[];
    _calculatePlanetPosition(timeModel, interval, repetition, list);
    _calculateDwarfPlanetPosition(timeModel, interval, repetition, list);
    _calculateCometPosition(timeModel, interval, repetition, list);
    list.sort((a, b) => a.position.z.compareTo(b.position.z));

    _drawObjects(canvas, center, scale, list);
    _drawPlanetLabel(canvas, center, scale);
    _drawDwarfPlanetLabel(canvas, center, scale);
    _drawCometLabel(canvas, center, scale);
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

  void _calculatePlanetPosition(TimeModel time, double interval, int repetition,
      List<_PositionAndColor> list) {
    final planetList = SolarSystem.planets;
    for (var i = 0; i < repetition; ++i) {
      final orbitCalculation =
          OrbitCalculationWithMeanLongitude(time + interval * i);
      planetList.forEach((name, planet) {
        if (planetVisibility[name] ?? false) {
          final pos =
              projection.transform(orbitCalculation.calculatePosition(planet));
          final color = planetColor[name];
          if (color != null) list.add(_PositionAndColor(pos, color));
        }
      });
    }
  }

  void _calculateDwarfPlanetPosition(TimeModel time, double interval,
      int repetition, List<_PositionAndColor> list) {
    final dwarfPlanetList = SolarSystem.dwarfPlanets;
    for (var i = 0; i < repetition; ++i) {
      final orbitCalculation =
          OrbitCalculationWithMeanMotion(time + interval * i);
      dwarfPlanetList.forEach((name, planet) {
        if (planetVisibility[name] ?? false) {
          final pos =
              projection.transform(orbitCalculation.calculatePosition(planet));
          final color = dwarfPlanetColor[name];
          if (color != null) list.add(_PositionAndColor(pos, color));
        }
      });
    }
  }

  void _calculateCometPosition(TimeModel time, double interval, int repetition,
      List<_PositionAndColor> list) {
    final cometList = SolarSystem.comets;
    for (var i = 0; i < repetition; ++i) {
      final orbitCalculation =
          OrbitCalculationWithPerihelionPassage(time + interval * i);
      cometList.forEach((name, comet) {
        if (planetVisibility[name] ?? false) {
          final pos =
              projection.transform(orbitCalculation.calculatePosition(comet));
          final color = cometColor[name];
          if (color != null) list.add(_PositionAndColor(pos, color));
        }
      });
    }
  }

  void _drawObjects(Canvas canvas, Offset center, double scale,
      List<_PositionAndColor> list) {
    for (final object in list.where((e) => e.position.z < 0)) {
      final pos = object.position.toXy(center, scale);
      if (pos != null) _drawPlanet(canvas, pos, object.color);
    }

    _drawSun(canvas, center);

    for (final object in list.where((e) => e.position.z >= 0)) {
      final pos = object.position.toXy(center, scale);
      if (pos != null) _drawPlanet(canvas, pos, object.color);
    }
  }

  void _drawPlanet(Canvas canvas, Offset pos, Color? color) {
    final paint = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    canvas.drawCircle(pos, 4, paint);
  }

  void _drawSun(Canvas canvas, Offset center) {
    final paintFillRed = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    canvas.drawCircle(center, 8, paintFillRed);
  }

  void _drawPlanetLabel(Canvas canvas, Offset center, double scale) {
    final planetList = SolarSystem.planets;
    final orbitCalculation = OrbitCalculationWithMeanLongitude(timeModel);
    planetList.forEach((name, planet) {
      if (planetVisibility[name] ?? false) {
        final pos = projection
            .transform(orbitCalculation.calculatePosition(planet))
            .toXy(center, scale);
        if (pos != null && (pos - center).distance > 50) {
          _drawLabel(canvas, pos, name);
        }
      }
    });
  }

  void _drawDwarfPlanetLabel(Canvas canvas, Offset center, double scale) {
    final dwarfPlanetList = SolarSystem.dwarfPlanets;
    final orbitCalculation = OrbitCalculationWithMeanMotion(timeModel);
    dwarfPlanetList.forEach((name, planet) {
      if (planetVisibility[name] ?? false) {
        final pos = projection
            .transform(orbitCalculation.calculatePosition(planet))
            .toXy(center, scale);
        if (pos != null && (pos - center).distance > 50) {
          _drawLabel(canvas, pos, name);
        }
      }
    });
  }

  void _drawCometLabel(Canvas canvas, Offset center, double scale) {
    final cometList = SolarSystem.comets;
    final orbitCalculation = OrbitCalculationWithPerihelionPassage(timeModel);
    cometList.forEach((name, planet) {
      if (planetVisibility[name] ?? false) {
        final pos = projection
            .transform(orbitCalculation.calculatePosition(planet))
            .toXy(center, scale);
        if (pos != null && (pos - center).distance > 50) {
          _drawLabel(canvas, pos, name);
        }
      }
    });
  }

  void _drawLabel(Canvas canvas, Offset pos, String name) {
    final labelSpan = TextSpan(
      style: labelTextStyle,
      text: nameList[name],
    );

    final locationTextPainter = TextPainter(
      text: labelSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    locationTextPainter.layout();
    final height = locationTextPainter.size.height;

    locationTextPainter.paint(canvas, pos.translate(height * 0.5, 0));
  }

  void _drawOrbitOfPlanet(Canvas canvas, Offset center, double scale) {
    final planetList = SolarSystem.planets;
    final orbitCalculation = OrbitCalculationWithMeanLongitude(timeModel);

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    planetList.forEach((name, planet) {
      bool isDrawing;
      final path = Path();

      final begin = projection
          .transform(orbitCalculation.calculatePositionFromEa(planet, 0))
          .toXy(center, scale);

      if (begin == null) {
        isDrawing = false;
      } else {
        isDrawing = true;
        path.moveTo(begin.dx, begin.dy);
      }

      for (var i = 0; i <= 360; ++i) {
        final position = projection
            .transform(
                orbitCalculation.calculatePositionFromEa(planet, i * degInRad))
            .toXy(center, scale);
        if (position == null) {
          isDrawing = false;
        } else if (isDrawing) {
          path.lineTo(position.dx, position.dy);
        } else {
          isDrawing = true;
          path.moveTo(position.dx, position.dy);
        }
      }

      canvas.drawPath(path, paint);
    });
  }

  void _drawOrbitOfDwarfPlanet(Canvas canvas, Offset center, double scale) {
    final planetList = SolarSystem.dwarfPlanets;

    final orbitCalculation = OrbitCalculationWithMeanMotion(timeModel);

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    planetList.forEach((name, planet) {
      if (planetVisibility[name] ?? false) {
        bool isDrawing;
        final path = Path();

        final begin = projection
            .transform(orbitCalculation.calculatePositionFromEa(planet, 0))
            .toXy(center, scale);

        if (begin == null) {
          isDrawing = false;
        } else {
          isDrawing = true;
          path.moveTo(begin.dx, begin.dy);
        }

        for (var i = 0; i <= 360; ++i) {
          final position = projection
              .transform(orbitCalculation.calculatePositionFromEa(
                  planet, i * degInRad))
              .toXy(center, scale);
          if (position == null) {
            isDrawing = false;
          } else if (isDrawing) {
            path.lineTo(position.dx, position.dy);
          } else {
            isDrawing = true;
            path.moveTo(position.dx, position.dy);
          }
        }

        canvas.drawPath(path, paint);
      }
    });
  }

  void _drawOrbitOfComets(Canvas canvas, Offset center, double scale) {
    final cometList = SolarSystem.comets;

    final orbitCalculation = OrbitCalculationWithPerihelionPassage(timeModel);

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    cometList.forEach((name, comet) {
      if (planetVisibility[name] ?? false) {
        bool isDrawing;
        final path = Path();

        final begin = projection
            .transform(orbitCalculation.calculatePositionFromEa(comet, 0))
            .toXy(center, scale);

        if (begin == null) {
          isDrawing = false;
        } else {
          isDrawing = true;
          path.moveTo(begin.dx, begin.dy);
        }

        for (var i = 0; i <= 360; ++i) {
          final position = projection
              .transform(
                  orbitCalculation.calculatePositionFromEa(comet, i * degInRad))
              .toXy(center, scale);
          if (position == null) {
            isDrawing = false;
          } else if (isDrawing) {
            path.lineTo(position.dx, position.dy);
          } else {
            isDrawing = true;
            path.moveTo(position.dx, position.dy);
          }
        }

        canvas.drawPath(path, paint);
      }
    });
  }

  void _drawDirectionOfVernalPoint(Canvas canvas, Offset center, double zoom) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    const scale = 1.0e5;

    for (var i = 0; i < 21; ++i) {
      final start =
          projection.transform(Offset3D(i * 0.5, 0, 0)).toXy(center, scale);
      final end = projection
          .transform(Offset3D(i * 0.5 + 0.25, 0, 0))
          .toXy(center, scale);

      if (start != null && end != null) {
        canvas.drawLine(start, end, paint);
      }
    }

    final start1 =
        projection.transform(const Offset3D(10.25, 0, 0)).toXy(center, scale);
    final end1 = projection
        .transform(const Offset3D(10.0, -0.25, 0))
        .toXy(center, scale);
    if (start1 != null && end1 != null) {
      canvas.drawLine(start1, end1, paint);
    }

    final start2 =
        projection.transform(const Offset3D(10.25, 0, 0)).toXy(center, scale);
    final end2 =
        projection.transform(const Offset3D(10.0, 0.25, 0)).toXy(center, scale);
    if (start2 != null && end2 != null) {
      canvas.drawLine(start2, end2, paint);
    }
  }
}

class _PositionAndColor {
  final Perspective position;
  final Color color;

  const _PositionAndColor(this.position, this.color);
}
