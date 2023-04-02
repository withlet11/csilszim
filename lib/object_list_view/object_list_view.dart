/*
 * object_list_view.dart
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

import 'package:csilszim/constants.dart';
import 'package:csilszim/object_list_view/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../astronomical/astronomical_object/deep_sky_object.dart';
import '../astronomical/coordinate_system/equatorial_coordinate.dart';
import '../astronomical/coordinate_system/geographic_coordinate.dart';
import '../astronomical/coordinate_system/sphere_model.dart';
import '../astronomical/star_catalogue.dart';
import '../astronomical/time_model.dart';
import '../provider/location_provider.dart';
import '../utilities/degree_angle.dart';
import '../utilities/sexagesimal_angle.dart';

class ObjectListView extends ConsumerStatefulWidget {
  final StarCatalogue starCatalogue;

  const ObjectListView({super.key, required this.starCatalogue});

  @override
  ConsumerState createState() => _ObjectListView();
}

class _ObjectListView extends ConsumerState<ObjectListView>
    with SingleTickerProviderStateMixin {
  var _timeModel = TimeModel.fromLocalTime();
  late Ticker _ticker;
  final scrollController = ScrollController();
  var previousSeconds = 0;

  @override
  void initState() {
    super.initState();
    // For Ticker. It should be disposed when this widget is disposed.
    // Ticker is also paused when the widget is paused. It is good for
    // refreshing display.
    _ticker = createTicker((elapsed) {
      final currentSeconds = elapsed.inSeconds;
      if (currentSeconds != previousSeconds) {
        setState(() {
          previousSeconds = currentSeconds;
          _timeModel = TimeModel.fromLocalTime();
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose(); // For Ticker.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationData = ref.watch(locationProvider);
    _timeModel = TimeModel.fromLocalTime();

    final sphereModel = SphereModel(
        location: Geographic.fromDegrees(
            lat: locationData.latInDegrees(),
            long: locationData.longInDegrees()),
        gmstMicroseconds: _timeModel.gmst);

    final localizations = AppLocalizations.of(context)!;
    final messierList = widget.starCatalogue.messierList as List<DeepSkyObject>;
    final list = prepareTableRows(sphereModel, locationData, messierList);

    final header = [
      Tuple2<double, String>(numberColumnWidth, localizations.hash),
      const Tuple2<double, String>(typeColumnWidth, ''),
      Tuple2<double, String>(angleColumnWidth, localizations.alt),
      Tuple2<double, String>(angleColumnWidth, localizations.az),
      Tuple2<double, String>(angleColumnWidth, localizations.dec),
      Tuple2<double, String>(angleColumnWidth, localizations.ha),
      Tuple2<double, String>(angleColumnWidth, localizations.ra),
    ];

    final tableWidth = header.fold(0.0,
            (double sum, Tuple2<double, String> item) => sum + item.item1) +
        40.0;

    final latitude =
        DmsAngle.fromDegrees(locationData.latInDegrees()).toDmsWithNS();
    final longitude =
        DmsAngle.fromDegrees(locationData.longInDegrees()).toDmsWithEW();
    final utc = _timeModel.utc.toIso8601String().substring(11, 19);
    final localMeanTime = _timeModel
        .localMeanTime(locationData.longInDegrees())
        .toIso8601String()
        .substring(11, 19);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: tableWidth,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${localizations.universalTime}: $utc'),
                Text('${localizations.latitude}: $latitude'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${localizations.meanSolarTime}: $localMeanTime'),
                Text('${localizations.longitude}: $longitude'),
              ],
            ),
          ]),
        ),
        Container(
          alignment: Alignment.center,
          child: SizedBox(
            width: tableWidth,
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 0.0,
              columns: [
                for (final item in header)
                  DataColumn(
                      label: Container(
                          width: item.item1,
                          alignment: Alignment.centerRight,
                          child: Text(item.item2))),
              ],
              rows: const [],
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            width: tableWidth,
            child: Scrollbar(
              thumbVisibility: true,
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: DataTable(
                  showCheckboxColumn: false,
                  columnSpacing: 0.0,
                  columns: [
                    for (var i = 0; i < header.length; ++i)
                      DataColumn(
                        label: Container(
                            alignment: i < 1
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            width: header[i].item1,
                            child: list.first[i]),
                      ),
                  ],
                  rows: [
                    for (final object in list.sublist(1))
                      DataRow(
                        cells: [
                          DataCell(Container(
                              alignment: Alignment.centerLeft,
                              child: object.first)),
                          for (final e in object.sublist(1))
                            DataCell(Container(
                                alignment: Alignment.centerRight, child: e)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<List<Widget>> prepareTableRows(SphereModel sphereModel,
      Geographic locationData, List<DeepSkyObject> messierList) {
    return messierList.map((DeepSkyObject object) {
      final altAz = sphereModel.equatorialToHorizontal(Equatorial.fromRadians(
          dec: object.position.dec, ra: object.position.ra));
      final decAsDms =
          DmsAngle.fromDegrees(object.position.decInDegrees()).toDmsWithSign();
      final decAsDm = decAsDms.substring(0, decAsDms.length - 3);
      final raAsHms = HmsAngle.fromHours(object.position.raInHours()).toHms();
      final raAsHm = raAsHms.substring(0, raAsHms.length - 3);
      final haAsHms = HmsAngle.fromHours((_timeModel.gmst / 3600e6 +
                  locationData.long * radInHour -
                  object.position.raInHours()) %
              24.0)
          .toHms();
      final haAsHm = haAsHms.substring(0, haAsHms.length - 3);
      final color = altAz.alt > highAltitude
          ? highAltitudeColor
          : altAz.alt > middleAltitude
              ? middleAltitudeColor
              : altAz.alt > lowAltitude
                  ? lowAltitudeColor
                  : invisible;
      final textStyle = TextStyle(color: color);

      return <Widget>[
        Text('M${object.messierNumber}',
            style: textStyle, textAlign: TextAlign.right),
        objectType(object, color),
        Text(DegreeAngle(altAz.altInDegrees()).withSign(), style: textStyle),
        Text(DegreeAngle(altAz.azInDegrees()).withoutSign(), style: textStyle),
        Text(decAsDm, style: textStyle),
        Text(haAsHm, style: textStyle),
        Text(raAsHm, style: textStyle),
      ];
    }).toList();
  }

  Widget objectType(DeepSkyObject object, Color color) {
    if (object.type == 'Open cluster') {
      return _OpenClusterSign(color);
    } else if (object.type == 'Globular cluster') {
      return _GlobularClusterSign(color);
    } else if (object.type.toLowerCase().contains('nebula')) {
      return object.type == 'Planetary nebula'
          ? _PlanetaryNebulaSign(color)
          : _NebulaSign(color);
    } else if (object.type.contains('galaxy')) {
      return _GalaxySign(color);
    } else {
      switch (object.messierNumber) {
        case 1:
          return _NebulaSign(color);
        case 24:
        case 73:
          return _OpenClusterSign(color);
        case 40:
          return _DoubleStarSign(color);
        default:
          return Text('-', style: TextStyle(color: color));
      }
    }
  }
}

class _OpenClusterSign extends StatelessWidget {
  static const size = 16.0;
  static const radius = size * half;
  static const numberOfDots = 16;
  static const dotWidth = radius * fullTurn / numberOfDots * half;
  static const dotHeight = 1.0;
  final Color color;

  const _OpenClusterSign(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: signSize,
      height: signSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < numberOfDots; ++i)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(i / numberOfDots * fullTurn)
                ..translate(0.0, radius),
              child: Container(
                width: dotWidth,
                height: dotHeight,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _GlobularClusterSign extends StatelessWidget {
  static const size = 16.0;
  static const barWidth = size;
  static const barHeight = 1.0;
  final Color color;

  const _GlobularClusterSign(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: signSize,
      height: signSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: null,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: strokeWidth),
            ),
          ),
          Container(
              width: barHeight,
              height: barWidth,
              decoration: BoxDecoration(
                color: null,
                border: Border.all(color: color, width: strokeWidth),
              )),
          Container(
              width: barWidth,
              height: barHeight,
              decoration: BoxDecoration(
                color: null,
                border: Border.all(color: color, width: strokeWidth),
              )),
        ],
      ),
    );
  }
}

class _NebulaSign extends StatelessWidget {
  static const size = 16.0;
  final Color color;

  const _NebulaSign(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: signSize,
      height: signSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: null,
              border: Border.all(color: color, width: strokeWidth),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanetaryNebulaSign extends StatelessWidget {
  static const size = 16.0;
  static const barWidth = 5.0;
  static const barHeight = 1.0;
  static const circleSize = 8.0;
  static const positiveOffset = (size - barWidth) * half;
  static const negativeOffset = -positiveOffset;
  final Color color;

  const _PlanetaryNebulaSign(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: signSize,
        height: signSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: null,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: strokeWidth),
              ),
            ),
            for (final rect in [
              const Rect.fromLTWH(negativeOffset, 0.0, barWidth, barHeight),
              const Rect.fromLTWH(positiveOffset, 0.0, barWidth, barHeight),
              const Rect.fromLTWH(0.0, negativeOffset, barHeight, barWidth),
              const Rect.fromLTWH(0.0, positiveOffset, barHeight, barWidth),
            ])
              Transform(
                transform: Matrix4.identity()..translate(rect.left, rect.top),
                child: Container(
                    width: rect.width,
                    height: rect.height,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: color, width: strokeWidth),
                    )),
              ),
          ],
        ));
  }
}

class _GalaxySign extends StatelessWidget {
  static const size = 16.0;
  final Color color;

  const _GalaxySign(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: signSize,
      height: signSize,
      child: Transform(
        transform: Matrix4.identity()
          ..scale(1.0, 0.5)
          ..translate(0.0, size * half),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: null,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: strokeWidth),
          ),
        ),
      ),
    );
  }
}

class _DoubleStarSign extends StatelessWidget {
  static const size = 16.0;
  static const circleSize = 4.0;
  static const barWidth = 4.0;
  static const barHeight = 1.0;
  static const rightBarPosition = (size - barWidth) * half;
  static const leftBarPosition = -rightBarPosition;
  final Color color;

  const _DoubleStarSign(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: signSize,
      height: signSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Transform(
            transform: Matrix4.identity()..translate(rightBarPosition, 0.0),
            child: Container(
                width: barWidth,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: color, width: strokeWidth),
                )),
          ),
          Transform(
            transform: Matrix4.identity()..translate(leftBarPosition, 0.0),
            child: Container(
                width: barWidth,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: color, width: strokeWidth),
                )),
          ),
        ],
      ),
    );
  }
}
