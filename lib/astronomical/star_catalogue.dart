/*
 * star_catalogue.dart
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

import 'package:flutter/services.dart';

import 'constellation/constellation_line.dart';
import 'constellation/constellation_name.dart';
import 'coordinate_system/equatorial_coordinate.dart';
import 'astronomical_object/star.dart';

/// A star catalogue contents hip number, position, and magnitude.
class StarCatalogue {
  List starList = <Star>[];
  List lineList = <ConstellationLine>[];
  List nameList = <ConstellationName>[];

  static Future<StarCatalogue> make() async {
    final starCatalogue = StarCatalogue();
    await starCatalogue._loadStarData('hip_lite_a.txt');
    await starCatalogue._loadStarData('hip_lite_b.txt');
    await starCatalogue
        ._loadConstellationLineData('hip_constellation_line.csv');
    await starCatalogue._loadConstellationNameData('constellation_name.csv');

    return Future.value(starCatalogue);
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
}
