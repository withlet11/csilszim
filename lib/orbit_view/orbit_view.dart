/*
 * orbit_view.dart
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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../astronomical/time_model.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import 'graphical_projection/graphical_projection.dart';
import 'info_table.dart';
import 'orbit_plot.dart';
import 'configs.dart';

/// A view that shows a momentary sky map.
class OrbitView extends StatefulWidget {
  const OrbitView({super.key});

  @override
  State createState() => _OrbitViewState();
}

class _OrbitViewState extends State<OrbitView> {
  final _orbitViewKey = GlobalKey();
  late _Settings _settings;
  var _intervalItems = <DropdownMenuItem<double>>[];
  late final List<DropdownMenuItem<int>> _repetitionItems;
  Offset? _previousPosition;
  double? _previousScale;

  @override
  void initState() {
    super.initState();

    _settings = _Settings(
        projection: GraphicalProjection(Vector3(20, 1800, 500)),
        timeModel: TimeModel.fromLocalTime(),
        zoom: initialZoom,
        interval: initialInterval,
        repetition: initialRepetition);

    _repetitionItems = const [
      DropdownMenuItem(value: 1, child: Text('1')),
      DropdownMenuItem(value: 2, child: Text('2')),
      DropdownMenuItem(value: 3, child: Text('3')),
      DropdownMenuItem(value: 4, child: Text('4')),
      DropdownMenuItem(value: 5, child: Text('5')),
      DropdownMenuItem(value: 6, child: Text('6')),
      DropdownMenuItem(value: 7, child: Text('7')),
      DropdownMenuItem(value: 8, child: Text('8')),
      DropdownMenuItem(value: 9, child: Text('9')),
      DropdownMenuItem(value: 10, child: Text('10')),
      DropdownMenuItem(value: 12, child: Text('12')),
      DropdownMenuItem(value: 15, child: Text('15')),
      DropdownMenuItem(value: 20, child: Text('20')),
      DropdownMenuItem(value: 30, child: Text('30')),
      DropdownMenuItem(value: 60, child: Text('60')),
      DropdownMenuItem(value: 100, child: Text('100')),
      DropdownMenuItem(value: 120, child: Text('120')),
      DropdownMenuItem(value: 180, child: Text('180')),
    ];
  }

  @override
  void didChangeDependencies() {
    final pageStorage = PageStorage.of(context);
    _settings = pageStorage.readState(context) as _Settings? ??
        _Settings(
            projection: GraphicalProjection(Vector3(20, 1800, 500)),
            timeModel: TimeModel.fromLocalTime(),
            zoom: initialZoom,
            interval: initialInterval,
            repetition: initialRepetition);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    _intervalItems = [
      DropdownMenuItem(
          value: 1.0, child: Text(AppLocalizations.of(context)!.nDays(1))),
      DropdownMenuItem(
          value: 5.0, child: Text(AppLocalizations.of(context)!.nDays(5))),
      DropdownMenuItem(
          value: 10.0, child: Text(AppLocalizations.of(context)!.nDays(10))),
      DropdownMenuItem(
          value: 20.0, child: Text(AppLocalizations.of(context)!.nDays(20))),
      DropdownMenuItem(
          value: 30.0, child: Text(AppLocalizations.of(context)!.nDays(30))),
      DropdownMenuItem(
          value: 50.0, child: Text(AppLocalizations.of(context)!.nDays(50))),
      DropdownMenuItem(
          value: 100.0, child: Text(AppLocalizations.of(context)!.nDays(100))),
      DropdownMenuItem(
          value: oneYear * 0.5,
          child: Text(AppLocalizations.of(context)!.nYears(0.5))),
      DropdownMenuItem(
          value: oneYear, child: Text(AppLocalizations.of(context)!.nYears(1))),
      DropdownMenuItem(
          value: oneYear * 5,
          child: Text(AppLocalizations.of(context)!.nYears(5))),
      DropdownMenuItem(
          value: oneYear * 10,
          child: Text(AppLocalizations.of(context)!.nYears(10)))
    ];

    return Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          size.width * 1.5 > size.height
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _settingBar(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _settingBar(),
                ),
          Expanded(
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                ClipRect(
                  child:
                      // (Platform.isAndroid ? _makeGestureDetector : _makeListener)(
                      (defaultTargetPlatform == TargetPlatform.android ? _makeGestureDetector : _makeListener)(
                          OrbitPlot(
                              // for calling setState()
                              key: UniqueKey(),
                              projection: _settings.projection,
                              zoom: _settings.zoom,
                              timeModel: _settings.timeModel,
                              interval: _settings.interval,
                              repetition: _settings.repetition)),
                ),
                InfoTable(timeModel: _settings.timeModel),
              ],
            ),
          ),
        ]));
  }

  List<Widget> _settingBar() {
    return [
      Row(children: [
        Text(AppLocalizations.of(context)!.startUTC(_settings.timeModel.utc)),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            _pickDate(context);
            PageStorage.of(context).writeState(context, _settings);
          },
        ),
      ]),
      Row(children: [
        Text(AppLocalizations.of(context)!.interval),
        DropdownButton(
          items: _intervalItems,
          value: _settings.interval,
          onChanged: (value) {
            setState(() {
              _settings.interval = value ?? oneYear;
            });
            PageStorage.of(context).writeState(context, _settings);
          },
        ),
      ]),
      Row(children: [
        Text(AppLocalizations.of(context)!.repetition),
        DropdownButton(
          items: _repetitionItems,
          value: _settings.repetition,
          onChanged: (value) {
            setState(() {
              _settings.repetition = value ?? 10;
            });
            PageStorage.of(context).writeState(context, _settings);
          },
        ),
      ])
    ];
  }

  Widget _makeGestureDetector(Widget child) {
    return GestureDetector(
      key: _orbitViewKey,
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _previousPosition = null,
      onScaleStart: (details) {
        _previousScale = 1;
        _previousPosition = null;
      },
      onScaleUpdate: (details) {
        if (details.scale == 1.0) {
          _moveViewPoint(details.localFocalPoint);
        } else if (_previousScale != null) {
          final delta = details.scale - _previousScale!;
          setState(() {
            _settings.zoom = switch (delta) {
              > 0 => min(_settings.zoom * zoomingRate2, 10000),
              < 0 => max(_settings.zoom / zoomingRate2, 1),
              _ => _settings.zoom
            };
          });
          PageStorage.of(context).writeState(context, _settings);
        }

        _previousScale = details.scale;
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
      key: _orbitViewKey,
      onPointerDown: (event) => _previousPosition = null,
      onPointerHover: (event) => _previousPosition = null,
      onPointerMove: (event) => _moveViewPoint(event.localPosition),
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          setState(() {
            _settings.zoom = switch (event.scrollDelta.dy) {
              > 0 => min(_settings.zoom * zoomingRate1, 10000),
              < 0 => max(_settings.zoom / zoomingRate1, 1),
              _ => _settings.zoom
            };
          });
          PageStorage.of(context).writeState(context, _settings);
        }
      },
      child: child,
    );
  }

  void _moveViewPoint(Offset position) {
    var size = _orbitViewKey.currentContext!.size;
    final width = size?.width ?? 0.0;
    final height = size?.height ?? 0.0;

    if (position.dx.isNegative ||
        position.dx >= width ||
        position.dy.isNegative ||
        position.dy >= height) {
      _previousPosition = null;
    } else {
      if (_previousPosition != null) {
        final lastPosition = _settings.projection.cameraPosition;
        final matrix = Matrix4.rotationZ((position.dx - _previousPosition!.dx) *
            ((height / 2 - position.dy) * lastPosition.z).sign *
            0.01);
        final temporary = matrix.transformed3(lastPosition);
        final matrix2 = _rotateToAxisZ(temporary, (position.dy - _previousPosition!.dy) * 0.01);
        final newPosition = matrix2.transformed3(temporary);
        if (newPosition.x != 0 && newPosition.y != 0) {
          setState(() {
            _settings.projection = GraphicalProjection(newPosition);
          });
        }
      }
      _previousPosition = position;
      PageStorage.of(context).writeState(context, _settings);
    }
  }

  Matrix4 _rotateToAxisZ(Vector3 vector, double angle) {
    final distanceFromAxisZ = sqrt(vector.x * vector.x + vector.y * vector.y);
    if (distanceFromAxisZ == 0) return Matrix4.identity();

    final tanCurrentAngle = vector.z / distanceFromAxisZ;
    final currentAngle = atan(tanCurrentAngle);
    final newAngle = currentAngle + angle;
    if (newAngle >= halfTurn || newAngle <= -halfTurn) {
      return Matrix4.identity();
    }

    final matrix = Matrix4(
        cos(angle) - sin(angle) * tanCurrentAngle,
        0,
        0,
        0,
        0,
        cos(angle) - sin(angle) * tanCurrentAngle,
        0,
        0,
        0,
        0,
        cos(angle),
        0,
        0,
        0,
        distanceFromAxisZ * sin(angle),
        1);
    return (matrix.row0[0] > 0 || matrix.row1[1] > 0)
        ? matrix
        : Matrix4.identity();
  }

  Future _pickDate(BuildContext context) async {
    final initialDate = _settings.timeModel.localTime(null);
    final today = DateTime.now();
    final selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(today.year - 50),
        lastDate: DateTime(today.year + 50));

    if (selectedDate != null) {
      setState(() => _settings.timeModel = TimeModel.fromUtc(selectedDate));
    }

    return;
  }
}

class _Settings {
  GraphicalProjection projection;
  TimeModel timeModel;
  double zoom;
  double interval;
  int repetition;

  _Settings(
      {required this.projection,
      required this.timeModel,
      required this.zoom,
      required this.interval,
      required this.repetition});
}
