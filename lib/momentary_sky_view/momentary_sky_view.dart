/*
 * momentary_sky_view.dart
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

import 'package:csilszim/astronomical/grs80.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';

import '../astronomical/astronomical_object/celestial_id.dart';
import '../astronomical/astronomical_object/moon.dart';
import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/astronomical_object/sun.dart';
import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/time_model.dart';
import '../constants.dart';
import '../essential_data.dart';
import '../gui/date_time_chooser_dial.dart';
import '../l10n/app_localizations.dart';
import '../provider/base_settings_provider.dart';
import 'configs.dart';
import 'momentary_sky_map.dart';
import 'momentary_sky_view_setting_provider.dart';
import 'stereographic_projection.dart';

/// A view that shows a momentary sky map.
class MomentarySkyView extends ConsumerStatefulWidget {
  final EssentialData starCatalogue;

  const MomentarySkyView({super.key, required this.starCatalogue});

  @override
  ConsumerState createState() => _MomentarySkyViewState();
}

class _MomentarySkyViewState extends ConsumerState<MomentarySkyView>
    with SingleTickerProviderStateMixin {
  final _momentarySkyViewKey = GlobalKey();

  // final _fpsCounter = FpsCounter();
  late TimeModel _timeModel;
  var _settings = _Settings.defaultValue();

  double? _previousScale;
  Offset? _previousPosition;
  var mouseAltAz = const Horizontal.fromRadians(alt: 0, az: 0);
  var centerAltAz = const Horizontal.fromRadians(alt: 0, az: 0);
  late final Planet _earth;
  late final List<Planet> _planetList;
  late final Sun _sun;
  late final Moon _moon;

  late Ticker _ticker;
  var _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    _timeModel =
        TimeModel.fromLocalTime(DateTime.now().add(_settings.dateTimeOffset));
    final jd = _timeModel.jd;
    _earth = PlanetEarth()..update(jd, Vector3.zero());
    _planetList = [
      PlanetMercury(),
      PlanetVenus(),
      PlanetMars(),
      PlanetJupiter(),
      PlanetSaturn(),
      PlanetUranus(),
      PlanetNeptune(),
    ];
    for (final planet in _planetList) {
      planet.update(jd, _earth.heliocentric!);
    }
    _sun = Sun()..update(jd, _earth.heliocentric!);
    _moon = Moon(widget.starCatalogue.elp82b2);

    // For Ticker. It should be disposed when this widget is disposed.
    // Ticker is also paused when the widget is paused. It is good for
    // refreshing display.
    _ticker = createTicker((elapsed) {
      if ((elapsed - _elapsed).inMilliseconds > 1e3) {
        setState(() {
          _elapsed = elapsed;
        });
      }
    });
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    final pageStorage = PageStorage.of(context);
    _settings = pageStorage.readState(context) as _Settings? ??
        _Settings.defaultValue();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ticker.dispose(); // For Ticker.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _timeModel =
        TimeModel.fromLocalTime(DateTime.now().add(_settings.dateTimeOffset));
    final baseSettings = ref.watch(baseSettingsProvider);
    final locationData = baseSettings.toGeographic();
    final displaySettings = ref.watch(momentarySkyViewSettingProvider);
    final jd = _timeModel.jd;
    _earth.update(jd, Vector3.zero());
    for (final planet in _planetList) {
      planet.update(jd, _earth.heliocentric!);
    }
    _sun.update(jd, _earth.heliocentric!);
    _moon.observationPosition = Grs80.fromGeographic(locationData);
    _moon.update(_timeModel, _earth.heliocentric!, _sun);
    final localizations = AppLocalizations.of(context)!;
    final nameList = {
      CelestialId.sun: localizations.sun,
      CelestialId.moon: localizations.moon,
      CelestialId.mercury: localizations.mercury,
      CelestialId.venus: localizations.venus,
      CelestialId.mars: localizations.mars,
      CelestialId.jupiter: localizations.jupiter,
      CelestialId.saturn: localizations.saturn,
      CelestialId.uranus: localizations.uranus,
      CelestialId.neptune: localizations.neptune,
    };

    final directionSignList = [
      (localizations.northSign, 0, true),
      (localizations.northEastSign, 45, false),
      (localizations.eastSign, 90, true),
      (localizations.southEastSign, 135, false),
      (localizations.southSign, 180, true),
      (localizations.southWestSign, 225, false),
      (localizations.westSign, 270, true),
      (localizations.northWestSign, 315, false),
    ];

    final sphereModel =
        SphereModel(location: locationData, timeModel: _timeModel);
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: ClipRect(
                child: (defaultTargetPlatform == TargetPlatform.android
                    ? _makeGestureDetector
                    : _makeListener)(
              MomentarySkyMap(
                  // UniqueKey is needed for calling setState()
                  key: UniqueKey(),
                  projectionModel: _settings.projection,
                  sphereModel: sphereModel,
                  starCatalogue: widget.starCatalogue,
                  planetList: _planetList,
                  sun: _sun,
                  moon: _moon,
                  nameList: nameList,
                  directionSignList: directionSignList,
                  displaySettings: displaySettings.copyWith(),
                  centerAltAz: centerAltAz),
            ))),
        Align(
          alignment: Alignment.topRight,
          child: DateTimeChooserDial(
            dateTimeOffset: _settings.dateTimeOffset,
            onDateChange: (duration) {
              setState(() {
                _settings.dateTimeOffset = duration;
                PageStorage.of(context).writeState(context, _settings);
              });
            },
            onModeChange: (isDateMode) {
              _settings.isDateMode = isDateMode;
            },
            isDateMode: _settings.isDateMode,
            // tzLocation: baseSettings.usesLocationTimeZone
                // ? baseSettings.tzLocation
                // : null,
          ),
        ),
      ],
    );
  }

  Widget _makeGestureDetector(Widget child) {
    return GestureDetector(
      key: _momentarySkyViewKey,
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _showPosition(details.localPosition),
      onScaleStart: (details) {
        _previousScale = 1;
        _previousPosition = null;
      },
      onScaleUpdate: (details) {
        setState(() {
          if (details.scale == 1.0) {
            _moveViewPoint(details.localFocalPoint);
          } else if (_previousScale != null) {
            final delta = details.scale - _previousScale!;
            _settings.projection.zoom(delta * 2);
            PageStorage.of(context).writeState(context, _settings);
          }
          _previousScale = details.scale;
        });
      },
      onScaleEnd: (details) {
        _previousScale = null;
        _previousPosition = null;
      },
      child: child,
    );
  }

  Widget _makeListener(Widget child) {
    return Listener(
      key: _momentarySkyViewKey,
      onPointerDown: (event) => _showPosition(event.localPosition),
      onPointerHover: (event) => _showPosition(event.localPosition),
      onPointerMove: (event) => setState(() {
        _moveViewPoint(event.localPosition);
      }),
      onPointerSignal: (event) {
        setState(() {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy > 0) {
              _settings.projection.zoomOut();
            } else if (event.scrollDelta.dy.isNegative) {
              _settings.projection.zoomIn();
            }
            PageStorage.of(context).writeState(context, _settings);
          }
        });
      },
      child: child,
    );
  }

  void _showPosition(Offset position) {
    setState(() {
      final size = _momentarySkyViewKey.currentContext!.size;
      final width = size?.width ?? 0.0;
      final height = size?.height ?? 0.0;
      final center = size?.center(Offset.zero) ?? Offset.zero;
      final scale = min(width, height) * half * 0.9;
      final offset = (position - center) / scale;

      final horizontal = _settings.projection.xyToHorizontal(offset);
      mouseAltAz = horizontal;
      centerAltAz = _settings.projection.xyToHorizontal(Offset.zero);
      _previousPosition = null;
      PageStorage.of(context).writeState(context, _settings);
    });
  }

  void _moveViewPoint(Offset position) {
    final size = _momentarySkyViewKey.currentContext!.size;
    final width = size?.width ?? 0.0;
    final height = size?.height ?? 0.0;

    if (position.dx.isNegative ||
        position.dx >= width ||
        position.dy.isNegative ||
        position.dy >= height) {
      _previousPosition = null;
    } else {
      final center = size?.center(Offset.zero) ?? Offset.zero;
      final scale = min(width, height) * half * 0.9;
      final currentXY = (position - center) / scale;
      final currentAltAz = _settings.projection.xyToHorizontal(currentXY);
      mouseAltAz = currentAltAz;
      centerAltAz = _settings.projection.xyToHorizontal(Offset.zero);

      if (_previousPosition != null) {
        final previousXY = (_previousPosition! - center) / scale;
        final previousAltAz = _settings.projection.xyToHorizontal(previousXY);
        final deltaAltAz = currentAltAz - previousAltAz;
        _settings.projection.centerAltAz -= deltaAltAz;
      }
      _previousPosition = position;
      PageStorage.of(context).writeState(context, _settings);
    }
  }
}

class _Settings {
  StereographicProjection projection;
  Duration dateTimeOffset;
  bool isDateMode;

  _Settings({
    required this.projection,
    required this.dateTimeOffset,
    required this.isDateMode,
  });

  static _Settings defaultValue() {
    return _Settings(
        projection: StereographicProjection(
            const Horizontal.fromDegrees(alt: defaultAlt, az: defaultAz)),
        dateTimeOffset: Duration.zero,
        isDateMode: false);
  }
}
