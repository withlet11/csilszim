/*
 * whole_night_sky_view.dart
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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../astronomical/astronomical_object/celestial_id.dart';
import '../astronomical/astronomical_object/moon.dart';
import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/astronomical_object/sun.dart';
import '../astronomical/coordinate_system/ecliptic_coordinate.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/geographic_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/grs80.dart';
import '../astronomical/orbit_calculation/orbit_calculation.dart';
import '../astronomical/time_model.dart';
import '../constants.dart';
import '../essential_data.dart';
import '../gui/date_time_chooser_dial.dart';
import '../l10n/app_localizations.dart';
import '../provider/base_settings_provider.dart';
import 'configs.dart';
import 'mercator_projection.dart';
import 'whole_night_sky_map.dart';
import 'whole_night_sky_view_setting_provider.dart';

/// A view that shows a whole night sky map.
class WholeNightSkyView extends ConsumerStatefulWidget {
  final EssentialData starCatalogue;

  const WholeNightSkyView({super.key, required this.starCatalogue});

  @override
  ConsumerState createState() => _WholeNightSkyViewState();
}

class _WholeNightSkyViewState extends ConsumerState<WholeNightSkyView>
  with SingleTickerProviderStateMixin {
  final _wholeNightSkyViewKey = GlobalKey();
  var _settings = _Settings.defaultValue();
  var _sunEquatorial = Equatorial.zero;
  final _planetList = [
    PlanetMercury(),
    PlanetVenus(),
    PlanetMars(),
    PlanetJupiter(),
    PlanetSaturn(),
    PlanetUranus(),
    PlanetNeptune()
  ];
  late Moon _moon;
  late final List<Equatorial> eclipticLine;
  var _centerEquatorial = Equatorial.zero;
  double? _scale;
  Offset? _pointerPosition;

  late Ticker _ticker;
  var _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    _moon = Moon(widget.starCatalogue.elp82b2);
    eclipticLine = Ecliptic.prepareEclipticLine();

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
    final baseSettings = ref.watch(baseSettingsProvider);
    final locationData = baseSettings.toGeographic();
    _settings.projection.isSouthUp = switch (baseSettings.mapOrientation) {
      MapOrientation.southUp => true,
      MapOrientation.northUp => false,
      MapOrientation.auto => locationData.lat.isNegative
    };
    final displaySettings = ref.watch(wholeNightSkyViewSettingProvider);
    final localizations = AppLocalizations.of(context)!;
    final planetNameList = {
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
      CelestialId.moon: localizations.moon,
    };

    DateTime dateTime = DateTime.now().add(_settings.dateTimeOffset);
    final timeModel = TimeModel.fromLocalTime(dateTime);

    final sphereModel = SphereModel(
        location: locationData,
        timeModel: timeModel,
        eclipticLine: eclipticLine);

    _updateSolarSystem(locationData, timeModel);

    return Stack(fit: StackFit.expand, children: [
      ClipRect(
          child: (defaultTargetPlatform == TargetPlatform.android
              ? _makeGestureDetector
              : _makeListener)(
        WholeNightSkyMap(
          // key is necessary for calling setState()
          key: UniqueKey(),
          projectionModel: _settings.projection,
          sphereModel: sphereModel,
          starCatalogue: widget.starCatalogue,
          displaySettings: displaySettings.copyWith(),
          centerEquatorial: _centerEquatorial,
          sunEquatorial: _sunEquatorial,
          planetList: _planetList,
          moon: _moon,
          planetNameList: planetNameList,
        ),
      )),
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
            isDateMode: _settings.isDateMode),
            // tzLocation: baseSettings.usesLocationTimeZone
                // ? baseSettings.tzLocation
                // : null),
      ),
    ]);
  }

  Widget _makeGestureDetector(Widget child) {
    return GestureDetector(
      key: _wholeNightSkyViewKey,
      behavior: HitTestBehavior.opaque,
      // onTapDown: (details) => _showPosition(details.localPosition),
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
      key: _wholeNightSkyViewKey,
      onPointerDown: (event) => _showPosition(event.localPosition),
      // onPointerHover: (event) => _showPosition(event.localPosition),
      onPointerMove: (event) => _moveViewPoint(event.localPosition),
      onPointerSignal: (event) => _zoomWithWheel(event),
      child: child,
    );
  }

  void _showPosition(Offset position) {
    setState(() {
      final size = _wholeNightSkyViewKey.currentContext!.size;
      final height = size?.height ?? 0.0;
      final center = size?.center(Offset.zero) ?? Offset.zero;
      final scale = height * 0.9 / halfTurn;
      final offset = (position - center) / scale;

      final equatorial =
          _settings.projection.convertToEquatorial(offset).normalized();
      _centerEquatorial = equatorial;
      _pointerPosition = null;
      PageStorage.of(context).writeState(context, _settings);
    });
  }

  void _moveViewPoint(Offset position) {
    final size = _wholeNightSkyViewKey.currentContext!.size;
    final width = size?.width ?? 0.0;
    final height = size?.height ?? 0.0;

    if (position.dx.isNegative ||
        position.dx >= width ||
        position.dy.isNegative ||
        position.dy >= height) {
      _pointerPosition = null;
    } else {
      setState(() {
        final center = size?.center(Offset.zero) ?? Offset.zero;
        final scale = height * 0.9 / halfTurn;
        final currentXY = (position - center) / scale;
        final currentEquatorial =
            _settings.projection.convertToEquatorial(currentXY);
        _centerEquatorial = currentEquatorial.normalized();

        if (_pointerPosition != null) {
          final previousXY = (_pointerPosition! - center) / scale;
          final previousEquatorial =
              _settings.projection.convertToEquatorial(previousXY);
          final deltaEquatorial = currentEquatorial - previousEquatorial;
          _settings.projection.centerEquatorial =
              (_settings.projection.centerEquatorial - deltaEquatorial)
                  .normalized();
        }
        _pointerPosition = position;
        PageStorage.of(context).writeState(context, _settings);
      });
    }
  }

  void _zoomWithWheel(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        if (event.scrollDelta.dy > 0) {
          _settings.projection.zoomOut();
        } else if (event.scrollDelta.dy.isNegative) {
          _settings.projection.zoomIn();
        }
        PageStorage.of(context).writeState(context, _settings);
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
        PageStorage.of(context).writeState(context, _settings);
      });
    }
    _scale = details.scale;
  }

  void _updateSolarSystem(Geographic locationData, TimeModel timeModel) {
    final jd = timeModel.jd;
    _moon.observationPosition = Grs80.fromGeographic(locationData);
    final orbitCalculation = OrbitCalculationWithMeanLongitude(timeModel);
    final earthPosition = // PlanetEarth().calculateWithVsop87(jd);
        orbitCalculation.calculatePosition(PlanetEarth().orbitalElement);
    final sun = Sun()..update(jd, earthPosition);
    _sunEquatorial = sun.equatorial;
    for (final planet in _planetList) {
      planet.update(jd, earthPosition);
    }
    _moon.update(timeModel, earthPosition, sun);
  }
}

class _Settings {
  MercatorProjection projection;
  Duration dateTimeOffset;
  bool isDateMode;

  _Settings({
    required this.projection,
    required this.dateTimeOffset,
    required this.isDateMode,
  });

  static _Settings defaultValue() {
    return _Settings(
        projection: MercatorProjection(
            const Equatorial.fromDegreesAndHours(
                dec: defaultDec, ra: defaultRa),
            false),
        dateTimeOffset: Duration.zero,
        isDateMode: true);
  }
}
