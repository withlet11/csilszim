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

import 'package:csilszim/astronomical/coordinate_system/equatorial_coordinate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../astronomical/coordinate_system/geographic_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../constants.dart';
import '../provider/location_provider.dart';
import '../provider/display_setting_provider.dart';
import 'configs.dart';
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

  var projection = CylindricalProjection(
      const Equatorial.fromDegreesAndHours(dec: defaultDec, ra: defaultRa));
  double? _previousScale;
  Offset? _previousPosition;
  var mouseEquatorial = const Equatorial.fromRadians(ra: 0, dec: 0);

  @override
  void didChangeDependencies() {
    final pageStorage = PageStorage.of(context);
    projection = pageStorage?.readState(context) as CylindricalProjection? ??
        CylindricalProjection(const Equatorial.fromDegreesAndHours(
            dec: defaultDec, ra: defaultRa));
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          /*
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
           */
          Expanded(
              child: ClipRect(
                  child: (defaultTargetPlatform == TargetPlatform.android
                      ? _makeGestureDetector
                      : _makeListener)(
            SeasonalMap(
                // key is necessary for calling setState()
                key: UniqueKey(),
                projectionModel: projection,
                sphereModel: sphereModel,
                starCatalogue: widget.starCatalogue,
                displaySettings: settingData.copyWith(),
                mouseEquatorial: mouseEquatorial),
          )))
        ]);
  }

  Widget _makeGestureDetector(Widget child) {
    return GestureDetector(
      key: _seasonalViewKey,
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
            PageStorage.of(context)?.writeState(context, projection);
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
      key: _seasonalViewKey,
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
            PageStorage.of(context)?.writeState(context, projection);
          }
        });
      },
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

      final equatorial = projection.xyToEquatorial(offset).normalized();
      mouseEquatorial = equatorial;
      _previousPosition = null;
      PageStorage.of(context)?.writeState(context, projection);
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
      _previousPosition = null;
    } else {
      final center = Offset(width, height) * half;
      final scale = height * 0.9 / halfTurn;
      final currentXY = (position - center) / scale;
      final currentEquatorial = projection.xyToEquatorial(currentXY);
      mouseEquatorial = currentEquatorial;

      if (_previousPosition != null) {
        final previousXY = (_previousPosition! - center) / scale;
        final previousEquatorial = projection.xyToEquatorial(previousXY);
        final deltaEquatorial = currentEquatorial - previousEquatorial;
        projection.centerEquatorial -= deltaEquatorial;
      }
      _previousPosition = position;
      PageStorage.of(context)?.writeState(context, projection);
    }
  }
}
