/*
 * sexagesimal_angle.dart
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

import 'package:intl/intl.dart';

/// A class that holds an angle in degrees-minutes-seconds.
///
/// This class doesn't handle any radians value.
/// [deg] is a degree part of angle in degree. -180 <= [deg] < 360.
/// [min] is a minute part of angle in degree. 0 <= [min] < 60.
/// [sec] a second part of angle in degree. 0 <= [sec] < 60.
class DmsAngle {
  final bool isNegative;
  final int deg;
  final int min;
  final int sec;

  const DmsAngle(
      [this.isNegative = false, this.deg = 0, this.min = 0, this.sec = 0]);

  factory DmsAngle.fromDegrees(double value) {
    final isNegative = value.isNegative;
    final absValue = value.abs();
    final deg = absValue.toInt();
    final minAndSec = (absValue - deg) * 60;
    final min = minAndSec.toInt();
    final sec = ((minAndSec - min) * 60).round();
    if (sec != 60) return DmsAngle(isNegative, deg, min, sec);
    if (min + 1 != 60) return DmsAngle(isNegative, deg, min + 1);
    if (deg + 1 != 360) return DmsAngle(isNegative, deg + 1);
    return const DmsAngle();
  }

  double toDegrees() =>
      (isNegative ? -1 : 1) * (deg.abs() + (min + sec / 60) / 60);

  /// Generate a text between '0° 0′ 0' and '359° 59′ 59″'.
  ///
  /// Requires [deg] >= 0 and [deg] < 360.
  String toDmsWithoutSign() {
    final threeDigits = NumberFormat("##0");
    final twoDigits = NumberFormat("00");
    if (isNegative) {
      if (sec == 0) {
        if (min == 0) {
          if (deg == 0) {
            return '${threeDigits.format(0)}\u00b0${twoDigits.format(0)}\u2032${twoDigits.format(0)}\u2033';
          }
          return '${threeDigits.format(360 - deg)}\u00b0${twoDigits.format(0)}\u2032${twoDigits.format(0)}\u2033';
        }
        return '${threeDigits.format(359 - deg)}\u00b0${twoDigits.format(60 - min)}\u2032${twoDigits.format(0)}\u2033';
      }
      return '${threeDigits.format(359 - deg)}\u00b0${twoDigits.format(59 - min)}\u2032${twoDigits.format(60 - sec)}\u2033';
    }
    return '${threeDigits.format(deg)}\u00b0${twoDigits.format(min)}\u2032${twoDigits.format(sec)}\u2033';
  }

  /// Generate a text between '-90° 0′ 0' and '+90° 0′ 0″'.
  ///
  /// Requires [deg] >= -90 and [deg] <= 90.
  String toDmsWithSign() {
    final twoDigits = NumberFormat("00");
    return '${isNegative ? '-' : '+'}${twoDigits.format(deg)}\u00b0'
        '${twoDigits.format(min)}\u2032'
        '${twoDigits.format(sec)}\u2033';
  }

  /// Generate a text between '90° 0′ 0'N and '90° 0′ 0″S'.
  ///
  /// Requires [deg] >= -90 and [deg] <= 90.
  String toDmsWithNS() {
    final oneOrTwoDigit = NumberFormat("#0");
    final twoDigits = NumberFormat("00");
    return '${oneOrTwoDigit.format(deg.abs())}\u00b0'
        '${twoDigits.format(min)}\u2032'
        '${twoDigits.format(sec)}\u2033 '
        '${isNegative ? 'S' : 'N'}';
  }

  /// Generate a text between '180° 0′ 0'W and '180° 0′ 0″E'.
  ///
  /// Requires [deg] >= -180 and [deg] <= 180.
  String toDmsWithEW() {
    final threeDigits = NumberFormat("##0");
    final twoDigits = NumberFormat("00");
    return '${threeDigits.format(deg.abs())}\u00b0'
        '${twoDigits.format(min)}\u2032'
        '${twoDigits.format(sec)}\u2033 '
        '${isNegative ? 'W' : 'E'}';
  }
}

/// A class that holds an angle in hours-minutes-seconds.
///
/// This class doesn't handle any radians value.
/// [hour] is a hour part of angle in hours. 0 <= [hour] < 24.
/// [min] is a minute part of angle in hours. 0 <= [min] < 60.
/// [sec] is a second part of angle in hours. 0 <= [sec] < 60.
class HmsAngle {
  final int hour, min, sec;

  const HmsAngle([this.hour = 0, this.min = 0, this.sec = 0]);

  factory HmsAngle.fromHours(double value) {
    final hour = value.toInt();
    final minAndSec = (value - hour) * 60;
    final min = minAndSec.toInt();
    final sec = ((minAndSec - min) * 60).round();
    if (sec != 60) return HmsAngle(hour, min, sec);
    if (min + 1 != 60) return HmsAngle(hour, min + 1);
    if (hour + 1 != 24) return HmsAngle(hour + 1);
    return const HmsAngle();
  }

  double toHours() => hour + (min + sec / 60) / 60;

  /// Generate a text between '0h00m00s and '23h59m59s″'.
  ///
  /// Requires [hour] >= 0 and [hour] < 24.
  String toHms() {
    NumberFormat oneOrTwoDigit = NumberFormat("#0");
    NumberFormat twoDigits = NumberFormat("00");
    return '${oneOrTwoDigit.format(hour)}h'
        '${twoDigits.format(min)}m'
        '${twoDigits.format(sec)}s';
  }
}
