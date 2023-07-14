/*
 * essential_data.dart
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

import 'package:csilszim/astronomical/orbit_calculation/elp82b2.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'astronomical/astronomical_object/deep_sky_object.dart';
import 'astronomical/constellation/constellation_line.dart';
import 'astronomical/constellation/constellation_name.dart';
import 'astronomical/coordinate_system/equatorial_coordinate.dart';
import 'astronomical/astronomical_object/star.dart';

/// A star catalogue contents hip number, position, and magnitude.
class EssentialData {
  List starList = <Star>[];
  List lineList = <ConstellationLine>[];
  List nameList = <ConstellationName>[];
  List messierList = <DeepSkyObject>[];
  List brightestStarList = <Star>[];
  late Elp82b2 elp82b2;

  static Future<EssentialData> make() async {
    final essentialData = EssentialData();
    await essentialData._loadStarData('hip_lite_a.txt');
    await essentialData._loadStarData('hip_lite_b.txt');
    await essentialData
        ._loadConstellationLineData('hip_constellation_line.csv');
    await essentialData._loadConstellationNameData('constellation_name.csv');
    await essentialData._loadDeepSkyObjectData('messier.csv');
    await essentialData._loadBrightestStarData('brightest_stars.csv');
    essentialData.elp82b2 = await Elp82b2.make(prec: 4.85e-11);

    return Future.value(essentialData);
  }

  Future<void> _loadStarData(String filename) async {
    String text = await rootBundle.loadString('assets/$filename');

    for (final line in text.split('\n')) {
      final e = line.split(',');
      if (e.length >= 9) {
        while (starList.length < int.parse(e[0])) {
          starList.add(const Star(
              hipNumber: 0,
              position: Equatorial(
                  raHour: 0,
                  raMin: 0,
                  raSec: 0,
                  decSign: 1,
                  decDeg: 0,
                  decMin: 0,
                  decSec: 0),
              magnitude: 0.0));
        }
        starList.add(Star(
            hipNumber: int.parse(e[0]),
            position: Equatorial(
                raHour: int.parse(e[1]),
                raMin: int.parse(e[2]),
                raSec: double.parse(e[3]),
                decSign: int.parse(e[4]),
                decDeg: int.parse(e[5]),
                decMin: int.parse(e[6]),
                decSec: double.parse(e[7])),
            magnitude: double.parse(e[8])));
      }
    }
  }

  Future<void> _loadConstellationLineData(String filename) async {
    String text = await rootBundle.loadString('assets/$filename');

    for (final line in text.split('\n')) {
      final e = line.split(',');
      if (e.length >= 3) {
        lineList.add(ConstellationLine(int.parse(e[1]), int.parse(e[2])));
      }
    }
  }

  Future<void> _loadConstellationNameData(String filename) async {
    String text = await rootBundle.loadString('assets/$filename');

    for (final line in text.split('\n')) {
      final e = line.split(',');
      if (e.length > 4) {
        nameList.add(ConstellationName(
            iauAbbr: e[0],
            position: Equatorial.fromDegreesAndHours(
                ra: int.parse(e[1]) + int.parse(e[2]) / 60,
                dec: double.parse(e[3])),
            name: e[4]));
      }
    }
  }

  Future<void> _loadDeepSkyObjectData(String filename) async {
    final text = await rootBundle.loadString('assets/$filename');
    final numReg = RegExp(r'[0-9]+(\.[0-9]+)?');

    for (final line in text.split('\n')) {
      final e = line.split('\t');
      if (e.length >= 10) {
        final messier = e[0].substring(0, 1) == 'M'
            ? int.tryParse(e[0].substring(1))
            : null;
        if (messier == null) continue;
        final ngc = e[1].length > 4 && e[1].substring(0, 3) == 'NGC'
            ? int.tryParse(e[1].substring(4))
            : null;
        final commonName = e[2];
        final type = e[4];
        final distance = e[5];
        final constellation = e[6];
        final magnitude = e[7];
        final raStr = numReg.allMatches(e[8]).toList();
        final raHour =
            raStr.isNotEmpty ? int.parse(raStr[0].group(0) ?? '0') : 0;
        final raMin =
            raStr.length > 1 ? double.parse(raStr[1].group(0) ?? '0.0') : 0.0;
        final raSec =
            raStr.length > 2 ? double.parse(raStr[2].group(0) ?? '0.0') : 0.0;
        final ra = (raHour + (raMin + raSec / 60.0) / 60.0) * hourInRad;
        final decStr = numReg.allMatches(e[9]).toList();
        final decDeg =
            decStr.isNotEmpty ? int.parse(decStr[0].group(0) ?? '0') : 0;
        final decMin =
            decStr.length > 1 ? double.parse(decStr[1].group(0) ?? '0.0') : 0.0;
        final decSec =
            decStr.length > 2 ? double.parse(decStr[2].group(0) ?? '0.0') : 0.0;
        final dec = (e[9][0] == minusSign ? -1 : 1) *
            (decDeg + (decMin + decSec / 60.0) / 60.0) *
            degInRad;

        double? majorAxisSize;
        double? minorAxisSize;
        double? orientationAngle;
        if (e.length >= 11) {
          majorAxisSize = double.parse(e[10]);
          if (e.length >= 12) {
            minorAxisSize = double.parse(e[11]);
            if (e.length >= 13) {
              orientationAngle = double.parse(e[12]);
            }
          }
        }

        messierList.add(DeepSkyObject(
            messierNumber: messier,
            ngcNumber: ngc,
            position: Equatorial.fromRadians(dec: dec, ra: ra),
            magnitude: magnitude,
            majorAxisSize: majorAxisSize,
            minorAxisSize: minorAxisSize,
            orientationAngle: orientationAngle,
            type: type,
            name: commonName.split(',')));
      }
    }
  }

  Future<void> _loadBrightestStarData(String filename) async {
    final text = await rootBundle.loadString('assets/$filename');
    final numReg = RegExp(r'[0-9]+(\.[0-9]+)?');

    for (final line in text.split('\n')) {
      final e = line.split('\t');
      if (e.length >= 8) {
        final double magnitude;
        if (e.first[0] == minusSign) {
          final temp = double.tryParse(e[0].substring(1).split(' ').first);
          if (temp == null) continue;
          magnitude = -temp;
        } else {
          final temp = double.tryParse(e[0].split(' ').first);
          if (temp == null) continue;
          magnitude = temp;
        }
        final name = e[1];
        final raStr = numReg.allMatches(e[6]).toList();
        final raHour =
            raStr.isNotEmpty ? int.parse(raStr[0].group(0) ?? '0') : 0;
        final raMin =
            raStr.length > 1 ? double.parse(raStr[1].group(0) ?? '0.0') : 0.0;
        final raSec =
            raStr.length > 2 ? double.parse(raStr[2].group(0) ?? '0.0') : 0.0;
        final ra = (raHour + (raMin + raSec / 60.0) / 60.0) * hourInRad;
        final decStr = numReg.allMatches(e[7]).toList();
        final decDeg =
            decStr.isNotEmpty ? int.parse(decStr[0].group(0) ?? '0') : 0;
        final decMin =
            decStr.length > 1 ? double.parse(decStr[1].group(0) ?? '0.0') : 0.0;
        final decSec =
            decStr.length > 2 ? double.parse(decStr[2].group(0) ?? '0.0') : 0.0;
        final dec = (e[7][0] == minusSign ? -1 : 1) *
            (decDeg + (decMin + decSec / 60.0) / 60.0) *
            degInRad;

        brightestStarList.add(Star(
            position: Equatorial.fromRadians(dec: dec, ra: ra),
            magnitude: magnitude,
            name: [name],
            hipNumber: 0));
      }
    }
  }
}
