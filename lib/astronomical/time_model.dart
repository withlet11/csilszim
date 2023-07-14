/*
 * time_model.dart
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

import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';

class TimeModel {
  final DateTime utc;
  final double jd;

  /// Greenwich Mean Sidereal Time (GMST) in microseconds.
  final int gmst;

  const TimeModel._internal(
      {required this.utc, required this.jd, required this.gmst});

  factory TimeModel.fromLocalTime([DateTime? dateTime]) {
    final localTime = dateTime ?? DateTime.now();
    final utc = localTime.toUtc();
    final jd = _convertToJD(utc);
    final gmst = _convertToGmst(jd);
    return TimeModel._internal(utc: utc, jd: jd, gmst: gmst);
  }

  factory TimeModel.fromUtc([DateTime? dateTime]) {
    final utc = dateTime ?? DateTime.now().toUtc();
    final jd = _convertToJD(utc);
    final gmst = _convertToGmst(jd);
    return TimeModel._internal(utc: utc, jd: jd, gmst: gmst);
  }

  factory TimeModel.fromJd(double jd) {
    final utc = DateTime.fromMicrosecondsSinceEpoch(
        ((jd - 2440587.5) * 86400e6).toInt(),
        isUtc: true);
    final gmst = _convertToGmst(jd);
    return TimeModel._internal(utc: utc, jd: jd, gmst: gmst);
  }

  DateTime localTime(tz.Location? location) =>
      location == null ? utc.toLocal() : tz.TZDateTime.from(utc, location);

  String timeZoneName(tz.Location? location) => location == null
      ? utc.toLocal().timeZoneName
      : tz.TZDateTime.from(utc, location).timeZoneName;

  Duration timeZoneOffset(tz.Location? location) => location == null
      ? utc.toLocal().timeZoneOffset
      : tz.TZDateTime.from(utc, location).timeZoneOffset;

  TimeModel operator +(double days) => TimeModel.fromJd(jd + days);

  /// Returns the Local Mean Time at [longitude].
  DateTime localMeanTime(double longitude) => utc.add(Duration(
          microseconds: (longitude) {
        return (longitude / fullTurn * 86400.0e6).toInt() ?? 0;
      }(longitude)));

  /// Returns the Local Mean Sidereal Time at [longitude] as DateTime.
  DateTime lmstAsDateTime(double long) =>
      DateTime.fromMicrosecondsSinceEpoch(lmst(long)).toUtc();

  /// Returns the Local Mean Sidereal Time at [longitude].
  int lmst(double long) => gmst + (long / fullTurn * 86400e6).toInt();

  /// Returns the Julian Day Number
  int get jdn => utc.millisecondsSinceEpoch ~/ 86400000 + 2440588;

  /// Returns the Modified Julian Day at [time]
  double get mjd => utc.microsecondsSinceEpoch / 86400e6 + 40587.0;
}

/// Returns the Julian Day at [time]
double _convertToJD(DateTime time) =>
    time.microsecondsSinceEpoch / 86400e6 + 2440587.5;

/// Returns the Greenwich Mean Standard Time (GMT) in microseconds at [time].
int _convertToGmst(double jd) {
  final jc = (jd - 2451545.0) / 36525.0;
  return (67310.54841e6 +
              (876600.0 * 3600.0e6 + 8640184.812866e6) * jc +
              0.093104e6 * jc * jc -
              6.2 * jc * jc * jc)
          .toInt() %
      86400000000;
}
