/*
 * momentary_sky_view.dart
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
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../astronomical/astronomical_object/planet.dart';
import '../astronomical/coordinate_system/geographic_coordinate.dart';
import '../astronomical/coordinate_system/horizontal_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../astronomical/time_model.dart';
import '../constants.dart';
import '../utilities/fps_counter.dart';
import '../provider/location_provider.dart';
import '../utilities/offset_3d.dart';
import 'configs.dart';
import 'momentary_sky_map.dart';
import 'momentary_sky_view_setting_provider.dart';
import 'stereographic_projection.dart';

/// A view that shows a momentary sky map.
class MomentarySkyView extends ConsumerStatefulWidget {
  final StarCatalogue starCatalogue;

  const MomentarySkyView({super.key, required this.starCatalogue});

  @override
  ConsumerState createState() => _MomentarySkyViewState();
}

class _MomentarySkyViewState extends ConsumerState<MomentarySkyView>
    with SingleTickerProviderStateMixin {
  final _momentarySkyViewKey = GlobalKey();
  final _fpsCounter = FpsCounter();
  late Ticker _ticker;
  var _timeModel = TimeModel.fromLocalTime();
  var _elapsed = Duration.zero;
  var projection = StereographicProjection(
      const Horizontal.fromDegrees(alt: defaultAlt, az: defaultAz));
  double? _previousScale;
  Offset? _previousPosition;
  var mouseAltAz = const Horizontal.fromRadians(alt: 0, az: 0);
  late final Planet _earth;
  late final List<Planet> _planetList;

  @override
  void initState() {
    _earth = PlanetEarth()..update(_timeModel.jd, Offset3D.zero);
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
      planet.update(_timeModel.jd, _earth.heliocentric!);
    }

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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final pageStorage = PageStorage.of(context);
    projection = pageStorage.readState(context) as StereographicProjection? ??
        StereographicProjection(
            const Horizontal.fromDegrees(alt: defaultAlt, az: defaultAz));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ticker.dispose(); // For Ticker.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationData = ref.watch(locationProvider);
    final settingData = ref.watch(momentarySkyViewSettingProvider);
    _timeModel = TimeModel.fromLocalTime();
    _earth.update(_timeModel.jd, Offset3D.zero);
    for (final planet in _planetList) {
      planet.update(_timeModel.jd, _earth.heliocentric!);
    }

    final sphereModel = SphereModel(
        location: Geographic.fromDegrees(
            lat: locationData.latInDegrees(),
            long: locationData.longInDegrees()),
        gmstMicroseconds: _timeModel.gmst);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(locationData.latToString()),
              ),
              SizedBox(
                width: 100,
                child: Text(locationData.longToString()),
              ),
              SizedBox(
                width: 100,
                child: Text('fps: ${_fpsCounter.countFps()}'),
              ),
            ],
          ),
          Expanded(
              child: ClipRect(
                  /*
                  child: (Platform.isAndroid
                      ? _makeGestureDetector
                      : _makeListener)(

                 */
                  child: (defaultTargetPlatform == TargetPlatform.android
                      ? _makeGestureDetector
                      : _makeListener)(
            MomentarySkyMap(
                key: UniqueKey(),
                // for calling setState()
                projectionModel: projection,
                sphereModel: sphereModel,
                starCatalogue: widget.starCatalogue,
                planetList: _planetList,
                displaySettings: settingData.copyWith(),
                mouseAltAz: mouseAltAz),
          )))
        ]);
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
            projection.zoom(delta * 2);
            PageStorage.of(context).writeState(context, projection);
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
              projection.zoomOut();
            } else if (event.scrollDelta.dy < 0) {
              projection.zoomIn();
            }
            PageStorage.of(context).writeState(context, projection);
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

      final horizontal = projection.xyToHorizontal(offset);
      mouseAltAz = horizontal;
      _previousPosition = null;
      PageStorage.of(context).writeState(context, projection);
    });
  }

  void _moveViewPoint(Offset position) {
    final size = _momentarySkyViewKey.currentContext!.size;
    final width = size?.width ?? 0.0;
    final height = size?.height ?? 0.0;

    if (position.dx < 0 ||
        position.dx >= width ||
        position.dy < 0 ||
        position.dy >= height) {
      _previousPosition = null;
    } else {
      final center = size?.center(Offset.zero) ?? Offset.zero;
      final scale = min(width, height) * half * 0.9;
      final currentXY = (position - center) / scale;
      final currentAltAz = projection.xyToHorizontal(currentXY);
      mouseAltAz = currentAltAz;

      if (_previousPosition != null) {
        final previousXY = (_previousPosition! - center) / scale;
        final previousAltAz = projection.xyToHorizontal(previousXY);
        final deltaAltAz = currentAltAz - previousAltAz;
        projection.centerAltAz -= deltaAltAz;
      }
      _previousPosition = position;
      PageStorage.of(context).writeState(context, projection);
    }
  }
}
