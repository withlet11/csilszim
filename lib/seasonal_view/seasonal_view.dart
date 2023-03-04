/*
 * seasonal_view.dart
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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../astronomical/coordinate_system/ecliptic_coordinate.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/geographic_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/orbit_calculation/orbit_calculation.dart';
import '../astronomical/solar_system.dart';
import '../astronomical/star_catalogue.dart';
import '../astronomical/time_model.dart';
import '../constants.dart';
import '../provider/location_provider.dart';
import '../provider/display_setting_provider.dart';
import '../utilities/offset_3d.dart';
import 'configs.dart';
import 'date_chooser_dial.dart';
import 'seasonal_map.dart';
import 'mercator_projection.dart';

/// A view that shows a seasonal map.
class SeasonalView extends ConsumerStatefulWidget {
  final StarCatalogue starCatalogue;

  const SeasonalView({super.key, required this.starCatalogue});

  @override
  ConsumerState createState() => _SeasonalViewState();
}

class _SeasonalViewState extends ConsumerState<SeasonalView> {
  final _seasonalViewKey = GlobalKey();
  var _settings = _Settings.defaultValue();
  var _mouseEquatorial = const Equatorial.fromRadians(dec: 0.0, ra: 0.0);
  double? _scale;
  Offset? _pointerPosition;

  @override
  void didChangeDependencies() {
    final pageStorage = PageStorage.of(context);
    _settings = pageStorage?.readState(context) as _Settings? ??
        _Settings.defaultValue();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final locationData = ref.watch(locationProvider);
    final settingData = ref.watch(displaySettingProvider);

    final sphereModel = SphereModel(
        location: Geographic.fromDegrees(
            lat: locationData.latInDegrees(),
            long: locationData.longInDegrees()));

    return Stack(fit: StackFit.expand, children: [
      ClipRect(
          child: (defaultTargetPlatform == TargetPlatform.android
              ? _makeGestureDetector
              : _makeListener)(
        SeasonalMap(
            // key is necessary for calling setState()
            key: UniqueKey(),
            projectionModel: _settings.projection,
            sphereModel: sphereModel,
            starCatalogue: widget.starCatalogue,
            displaySettings: settingData.copyWith(),
            mouseEquatorial: _mouseEquatorial,
            sunEquatorial: _settings.sunEquatorial),
      )),
      Align(
        alignment: Alignment.topRight,
        child: Listener(
          child: DateChooserDial(
              dateString: _settings.date.toIso8601String().substring(0, 10),
              angle: _settings.dialAngle,
              isLeapYear: _settings.isLeapYear),
          onPointerDown: (event) => _rotateDial(event.localPosition),
          onPointerMove: (event) => _rotateDial(event.localPosition),
        ),
      ),
    ]);
  }

  Widget _makeGestureDetector(Widget child) {
    return GestureDetector(
      key: _seasonalViewKey,
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _showPosition(details.localPosition),
      onScaleStart: (details) {
        _scale = 1;
        _pointerPosition = null;
      },
      onScaleUpdate: (details) => _updateScale(details),
      onScaleEnd: (details) {
        _scale = null;
        _pointerPosition = null;
      },
      child: child,
    );
  }

  Widget _makeListener(Widget child) {
    return Listener(
      key: _seasonalViewKey,
      onPointerDown: (event) => _showPosition(event.localPosition),
      onPointerHover: (event) => _showPosition(event.localPosition),
      onPointerMove: (event) => _moveViewPoint(event.localPosition),
      onPointerSignal: (event) => _zoomWithWheel(event),
      child: child,
    );
  }

  void _showPosition(Offset position) {
    setState(() {
      final size = _seasonalViewKey.currentContext!.size;
      final width = size?.width ?? 0.0;
      final height = size?.height ?? 0.0;
      final center = Offset(width, height) * half;
      final scale = height * 0.9 / halfTurn;
      final offset = (position - center) / scale;

      final equatorial =
          _settings.projection.xyToEquatorial(offset).normalized();
      _mouseEquatorial = equatorial;
      _pointerPosition = null;
      PageStorage.of(context)?.writeState(context, _settings);
    });
  }

  void _moveViewPoint(Offset position) {
    final size = _seasonalViewKey.currentContext!.size;
    final width = size?.width ?? 0.0;
    final height = size?.height ?? 0.0;

    if (position.dx < 0 ||
        position.dx >= width ||
        position.dy < 0 ||
        position.dy >= height) {
      _pointerPosition = null;
    } else {
      setState(() {
        final center = Offset(width, height) * half;
        final scale = height * 0.9 / halfTurn;
        final currentXY = (position - center) / scale;
        final currentEquatorial =
            _settings.projection.xyToEquatorial(currentXY);
        _mouseEquatorial = currentEquatorial.normalized();

        if (_pointerPosition != null) {
          final previousXY = (_pointerPosition! - center) / scale;
          final previousEquatorial =
              _settings.projection.xyToEquatorial(previousXY);
          final deltaEquatorial = currentEquatorial - previousEquatorial;
          _settings.projection.centerEquatorial =
              (_settings.projection.centerEquatorial - deltaEquatorial)
                  .normalized();
        }
        _pointerPosition = position;
        PageStorage.of(context)?.writeState(context, _settings);
      });
    }
  }

  void _rotateDial(Offset position) {
    setState(() {
      final offset = position - dialCenter;
      final distance = offset.distance;
      if (distance < dialInnerBorderSize * 0.125 ||
          distance > dialOuterBorderSize * 0.75) return;
      final angle = (atan2(offset.dx, -offset.dy) + fullTurn) % fullTurn;
      final overYear = (angle - _settings.dialAngle > 0.75 * fullTurn)
          ? -1
          : (angle - _settings.dialAngle < -0.75 * fullTurn)
              ? 1
              : 0;

      _updateWithNewAngle(angle, overYear);
    });
  }

  void _updateWithNewAngle(double angle, int overYear) {
    final year = _settings.date.year + overYear;
    final yearBegin = DateTime(year).millisecondsSinceEpoch;
    final yearEnd = DateTime(year + 1).millisecondsSinceEpoch;
    final lengthOfYear = yearEnd - yearBegin;
    _settings.date = DateTime.fromMillisecondsSinceEpoch(
        (lengthOfYear * angle / fullTurn + yearBegin).round());
    _settings.isLeapYear = lengthOfYear == 366 * 86400 * 1000;
    _settings.dialAngle = angle;
    final time = TimeModel.fromLocalTime(_settings.date);
    final orbitCalculation = OrbitCalculationWithMeanLongitude(time);
    final earthXyz =
        orbitCalculation.calculatePosition(SolarSystem.planets['earth']!);
    final sunXyz = const Offset3D(0.0, 0.0, 0.0) - earthXyz;
    final sunEcliptic = Ecliptic.fromXyz(sunXyz);
    _settings.sunEquatorial = sunEcliptic.toEquatorial();

    PageStorage.of(context)?.writeState(context, _settings);
  }

  void _zoomWithWheel(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        if (event.scrollDelta.dy > 0) {
          _settings.projection.zoomOut();
        } else if (event.scrollDelta.dy < 0) {
          _settings.projection.zoomIn();
        }
        PageStorage.of(context)?.writeState(context, _settings);
      });
    }
  }

  void _updateScale(ScaleUpdateDetails details) {
    if (details.scale == 1.0) {
      _moveViewPoint(details.localFocalPoint);
    } else if (_scale != null) {
      setState(() {
        final delta = details.scale - _scale!;
        _settings.projection.zoom(delta * 2);
        PageStorage.of(context)?.writeState(context, _settings);
      });
    }
    _scale = details.scale;
  }
}

class _Settings {
  MercatorProjection projection;
  DateTime date;
  bool isLeapYear;
  double dialAngle;
  Equatorial sunEquatorial;

  _Settings(
      {required this.projection,
      required this.date,
      required this.isLeapYear,
      required this.dialAngle,
      required this.sunEquatorial});

  static _Settings defaultValue() {
    final date = DateTime.now();
    final year = date.year;
    final yearBegin = DateTime(year).millisecondsSinceEpoch;
    final yearEnd = DateTime(year + 1).millisecondsSinceEpoch;
    final lengthOfYear = yearEnd - yearBegin;

    final time = TimeModel.fromLocalTime(date);
    final orbitCalculation = OrbitCalculationWithMeanLongitude(time);
    final earthXyz =
        orbitCalculation.calculatePosition(SolarSystem.planets['earth']!);
    final sunXyz = const Offset3D(0.0, 0.0, 0.0) - earthXyz;
    final sunEcliptic = Ecliptic.fromXyz(sunXyz);

    return _Settings(
        projection: MercatorProjection(const Equatorial.fromDegreesAndHours(
            dec: defaultDec, ra: defaultRa)),
        date: date,
        dialAngle:
            (date.millisecondsSinceEpoch - yearBegin) / lengthOfYear * fullTurn,
        isLeapYear: lengthOfYear == 366 * 86400 * 1000,
        sunEquatorial: sunEcliptic.toEquatorial());
  }
}
