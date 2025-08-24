/*
 * orbit_plot.dart
 *
 * Copyright 2023-2024 Yasuhiro Yamakawa <withlet11@gmail.com>
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../astronomical/astronomical_object/celestial_id.dart';
import '../astronomical/orbit_calculation/orbit_calculation.dart';
import '../astronomical/solar_system.dart';
import '../astronomical/time_model.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'configs.dart';
import 'graphical_projection/graphical_projection.dart';
import 'graphical_projection/perspective.dart';
import 'orbit_view_setting_provider.dart';

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
    final nameList = <CelestialId, String>{
      CelestialId.mercury: localizations.mercury,
      CelestialId.venus: localizations.venus,
      CelestialId.earth: localizations.earth,
      CelestialId.mars: localizations.mars,
      CelestialId.jupiter: localizations.jupiter,
      CelestialId.saturn: localizations.saturn,
      CelestialId.uranus: localizations.uranus,
      CelestialId.neptune: localizations.neptune,
      CelestialId.ceres: localizations.ceres,
      CelestialId.pluto: localizations.pluto,
      CelestialId.haumea: localizations.haumea,
      CelestialId.makemake: localizations.makemake,
      CelestialId.eris: localizations.eris,
      CelestialId.halley: localizations.halley,
      CelestialId.encke: localizations.encke,
      CelestialId.biela: localizations.biela,
      CelestialId.faye: localizations.faye,
      CelestialId.brorsen: localizations.brorsen,
      CelestialId.dArrest: localizations.dArrest,
      CelestialId.ponsWinnecke: localizations.ponsWinnecke,
      CelestialId.tuttle: localizations.tuttle,
      CelestialId.tempel1: localizations.tempel1,
      CelestialId.tempel2: localizations.tempel2,
    };

    final planetVisibility = {
      CelestialId.mercury: settings.isMercuryVisible,
      CelestialId.venus: settings.isVenusVisible,
      CelestialId.earth: settings.isEarthVisible,
      CelestialId.mars: settings.isMarsVisible,
      CelestialId.jupiter: settings.isJupiterVisible,
      CelestialId.saturn: settings.isSaturnVisible,
      CelestialId.uranus: settings.isUranusVisible,
      CelestialId.neptune: settings.isNeptuneVisible,
      CelestialId.ceres: settings.isCeresVisible,
      CelestialId.pluto: settings.isPlutoVisible,
      CelestialId.eris: settings.isErisVisible,
      CelestialId.haumea: settings.isHaumeaVisible,
      CelestialId.makemake: settings.isMakemakeVisible,
      CelestialId.halley: settings.isHalleyVisible,
      CelestialId.encke: settings.isEnckeVisible,
      CelestialId.faye: settings.isFayeVisible,
      CelestialId.dArrest: settings.isDArrestVisible,
      CelestialId.ponsWinnecke: settings.isPonsWinneckeVisible,
      CelestialId.tuttle: settings.isTuttleVisible,
      CelestialId.tempel1: settings.isTempel1Visible,
      CelestialId.tempel2: settings.isTempel2Visible,
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
  final Map<CelestialId, String> nameList;
  final Map<CelestialId, bool> planetVisibility;

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
    _calculateSunPosition(list);
    _calculatePlanetPosition(timeModel, interval, repetition, list);
    _calculateDwarfPlanetPosition(timeModel, interval, repetition, list);
    _calculateCometPosition(timeModel, interval, repetition, list);
    list.sort((a, b) => b.position.xyz.z.compareTo(a.position.xyz.z));
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

  void _calculateSunPosition(List<_PositionAndColor> list) {
    final pos = projection.transform(vector.Vector3.zero());
    const color = sunColor;
    list.add(_PositionAndColor(pos, color, sunSize));
  }

  void _calculatePlanetPosition(TimeModel timeModel, double interval,
      int repetition, List<_PositionAndColor> list) {
    final planetList = SolarSystem.planets;
    for (var i = 0; i < repetition; ++i) {
      final orbitCalculation =
          OrbitCalculationWithMeanLongitude(timeModel + interval * i);
      for (final planet in planetList) {
        if (planetVisibility[planet.id] ?? false) {
          final pos = projection.transform(
              orbitCalculation.calculatePosition(planet.orbitalElement));
          final color = planetColor[planet.id];
          if (color != null) list.add(_PositionAndColor(pos, color));
        }
      }
    }
  }

  void _calculateDwarfPlanetPosition(TimeModel time, double interval,
      int repetition, List<_PositionAndColor> list) {
    final dwarfPlanetList = SolarSystem.dwarfPlanets;
    for (var i = 0; i < repetition; ++i) {
      final orbitCalculation =
          OrbitCalculationWithMeanMotion(time + interval * i);
      for (final planet in dwarfPlanetList) {
        if (planetVisibility[planet.id] ?? false) {
          final pos = projection.transform(
              orbitCalculation.calculatePosition(planet.orbitalElement));
          final color = dwarfPlanetColor[planet.id];
          if (color != null) list.add(_PositionAndColor(pos, color));
        }
      }
    }
  }

  void _calculateCometPosition(TimeModel time, double interval, int repetition,
      List<_PositionAndColor> list) {
    final cometList = SolarSystem.comets;
    for (var i = 0; i < repetition; ++i) {
      final orbitCalculation =
          OrbitCalculationWithPerihelionPassage(time + interval * i);
      for (final comet in cometList) {
        if (planetVisibility[comet.id] ?? false) {
          final pos = projection
              .transform(orbitCalculation.calculatePosition(comet.element));
          final color = cometColor[comet.id];
          if (color != null) list.add(_PositionAndColor(pos, color));
        }
      }
    }
  }

  void _drawObjects(Canvas canvas, Offset center, double scale,
      List<_PositionAndColor> list) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    for (final object in list) {
      final pos = object.position.toXy(center, scale);
      if (pos != null) {
        paint.color = object.color;
        canvas.drawCircle(pos, object.size, paint);
      }
    }
  }

  void _drawPlanetLabel(Canvas canvas, Offset center, double scale) {
    final planetList = SolarSystem.planets;
    final orbitCalculation = OrbitCalculationWithMeanLongitude(timeModel);
    for (final planet in planetList) {
      if (planetVisibility[planet.id] ?? false) {
        final pos = projection
            .transform(
                orbitCalculation.calculatePosition(planet.orbitalElement))
            .toXy(center, scale);
        if (pos != null && (pos - center).distance > 50) {
          _drawLabel(canvas, pos, nameList[planet.id]!);
        }
      }
    }
  }

  void _drawDwarfPlanetLabel(Canvas canvas, Offset center, double scale) {
    final dwarfPlanetList = SolarSystem.dwarfPlanets;
    final orbitCalculation = OrbitCalculationWithMeanMotion(timeModel);
    for (final planet in dwarfPlanetList) {
      if (planetVisibility[planet.id] ?? false) {
        final pos = projection
            .transform(
                orbitCalculation.calculatePosition(planet.orbitalElement))
            .toXy(center, scale);
        if (pos != null && (pos - center).distance > 50) {
          _drawLabel(canvas, pos, nameList[planet.id]!);
        }
      }
    }
  }

  void _drawCometLabel(Canvas canvas, Offset center, double scale) {
    final cometList = SolarSystem.comets;
    final orbitCalculation = OrbitCalculationWithPerihelionPassage(timeModel);
    for (final comet in cometList) {
      if (planetVisibility[comet.id] ?? false) {
        final pos = projection
            .transform(orbitCalculation.calculatePosition(comet.element))
            .toXy(center, scale);
        if (pos != null && (pos - center).distance > 50) {
          _drawLabel(canvas, pos, nameList[comet.id]!);
        }
      }
    }
  }

  void _drawLabel(Canvas canvas, Offset pos, String name) {
    final labelSpan = TextSpan(
      style: labelTextStyle,
      text: name,
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

    for (final planet in planetList) {
      bool isDrawing;
      final path = Path();

      final begin = projection
          .transform(orbitCalculation.calculatePositionFromEa(
              planet.orbitalElement, 0))
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
                planet.orbitalElement, i * degInRad))
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
  }

  void _drawOrbitOfDwarfPlanet(Canvas canvas, Offset center, double scale) {
    final planetList = SolarSystem.dwarfPlanets;

    final orbitCalculation = OrbitCalculationWithMeanMotion(timeModel);

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    for (final planet in planetList) {
      if (planetVisibility[planet.id] ?? false) {
        bool isDrawing;
        final path = Path();

        final begin = projection
            .transform(orbitCalculation.calculatePositionFromEa(
                planet.orbitalElement, 0))
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
                  planet.orbitalElement, i * degInRad))
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
    }
  }

  void _drawOrbitOfComets(Canvas canvas, Offset center, double scale) {
    final cometList = SolarSystem.comets;

    final orbitCalculation = OrbitCalculationWithPerihelionPassage(timeModel);

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    for (final comet in cometList) {
      if (planetVisibility[comet.id] ?? false) {
        bool isDrawing;
        final path = Path();

        final begin = projection
            .transform(
                orbitCalculation.calculatePositionFromEa(comet.element, 0))
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
                  comet.element, i * degInRad))
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
    }
  }

  void _drawDirectionOfVernalPoint(Canvas canvas, Offset center, double zoom) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    const scale = 1.0e5;

    for (var i = 0; i < 21; ++i) {
      final start = projection
          .transform(vector.Vector3(i * 0.5, 0, 0))
          .toXy(center, scale);
      final end = projection
          .transform(vector.Vector3(i * 0.5 + 0.25, 0, 0))
          .toXy(center, scale);

      if (start != null && end != null) {
        canvas.drawLine(start, end, paint);
      }
    }

    final start1 =
        projection.transform(vector.Vector3(10.25, 0, 0)).toXy(center, scale);
    final end1 = projection
        .transform(vector.Vector3(10.0, -0.25, 0))
        .toXy(center, scale);
    if (start1 != null && end1 != null) {
      canvas.drawLine(start1, end1, paint);
    }

    final start2 =
        projection.transform(vector.Vector3(10.25, 0, 0)).toXy(center, scale);
    final end2 =
        projection.transform(vector.Vector3(10.0, 0.25, 0)).toXy(center, scale);
    if (start2 != null && end2 != null) {
      canvas.drawLine(start2, end2, paint);
    }
  }
}

class _PositionAndColor {
  final Perspective position;
  final Color color;
  final double size;

  const _PositionAndColor(this.position, this.color, [this.size = planetSize]);
}
