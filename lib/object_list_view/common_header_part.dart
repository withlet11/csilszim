/*
 * common_header_part.dart
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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../astronomical/coordinate_system/geographic_coordinate.dart';
import '../astronomical/time_model.dart';
import '../constants.dart';
import '../utilities/sexagesimal_angle.dart';

class CommonHeaderPart extends StatelessWidget {
  final double width;
  final AppLocalizations localizations;
  final TimeModel timeModel;
  final Geographic locationData;

  const CommonHeaderPart(
      {super.key,
      required this.width,
      required this.localizations,
      required this.timeModel,
      required this.locationData});

  @override
  Widget build(BuildContext context) {
    final utc = timeModel.utc.toIso8601String().substring(11, 19);
    final localMeanTime = timeModel
        .localMeanTime(locationData.longInDegrees())
        .toIso8601String()
        .substring(11, 19);
    final latitude =
        DmsAngle.fromDegrees(locationData.latInDegrees()).toDmsWithNS();
    final longitude =
        DmsAngle.fromDegrees(locationData.longInDegrees()).toDmsWithEW();

    return SizedBox(
      width: width,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                width: width * half,
                alignment: Alignment.center,
                child: Text('${localizations.universalTime}: $utc')),
            Container(
                width: width * half,
                alignment: Alignment.center,
                child: Text('${localizations.latitude}: $latitude')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                width: width * half,
                alignment: Alignment.center,
                child: Text('${localizations.meanSolarTime}: $localMeanTime')),
            Container(
                width: width * half,
                alignment: Alignment.center,
                child: Text('${localizations.longitude}: $longitude')),
          ],
        ),
      ]),
    );
  }
}
