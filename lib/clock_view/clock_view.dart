/*
 * clock_view.dart
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

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../astronomical/time_model.dart';
import '../provider/location_provider.dart';
import 'analog_clock.dart';
import 'configs.dart';

/// A view that displays several kind of clocks.
class ClockView extends ConsumerStatefulWidget {
  const ClockView({super.key});

  @override
  ConsumerState createState() => _ClockViewState();
}

class _ClockViewState extends ConsumerState<ClockView>
    with SingleTickerProviderStateMixin {
  var timeModel = TimeModel.fromLocalTime();
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    // For Ticker. It should be disposed when this widget is disposed.
    // Ticker is also paused when the widget is paused. It is good for
    // refreshing display.
    _ticker = createTicker((elapsed) {
      setState(() {
        timeModel = TimeModel.fromLocalTime();
      });
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
    final model = ref.watch(locationProvider);
    final utc = timeModel.utc;
    final localTime = timeModel.localTime;
    final localMeanTime = timeModel.localMeanTime(model.longInDegrees());
    final lmst = DateTime.fromMicrosecondsSinceEpoch(
            timeModel.gmst + (model.longInDegrees() / 360 * 86400e6).toInt())
        .toUtc();

    final screenSize = MediaQuery.of(context).size;
    final clockSize = min(screenSize.width * 0.45, screenSize.height * 0.4);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _utcClock(utc, clockSize),
              _localTimeClock(localTime, clockSize),
            ]),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _localMeanTimeClock(
                  localMeanTime,
                  '${AppLocalizations.of(context)!.latitude}: ${model.latToString()}\n'
                  '${AppLocalizations.of(context)!.longitude}: ${model.longToString()}',
                  clockSize),
              _localMeanSiderealTimeClock(lmst, clockSize),
            ]),
      ],
    );
  }

  Widget _utcClock(DateTime utc, double clockSize) {
    return AnalogClock(
      key: UniqueKey(),
      hour: utc.hour,
      minute: utc.minute,
      second: utc.second,
      upperLabel: AppLocalizations.of(context)!.universalTime,
      lowerLabel: '${utc.toString().replaceFirst(RegExp(r'\.[0-9]*Z$'), '')}\n'
          'JDN: ${timeModel.jdn}\n'
          'JD: ${timeModel.jd.toStringAsFixed(6)}\n'
          'MJD: ${timeModel.mjd.toStringAsFixed(6)}',
      is24hours: false,
      width: clockSize,
      height: clockSize,
    );
  }

  Widget _localTimeClock(DateTime localTime, double clockSize) {
    return AnalogClock(
        hour: localTime.hour,
        minute: localTime.minute,
        second: localTime.second,
        upperLabel: AppLocalizations.of(context)!.standardTime,
        lowerLabel:
            '${localTime.toString().replaceFirst(RegExp(r'\.[0-9]*$'), '')}\n'
            '${AppLocalizations.of(context)!.timeZone}: ${timeModel.localTime.timeZoneName}\n'
            '${AppLocalizations.of(context)!.timeOffset}: ${timeModel.localTime.timeZoneOffset.toString().replaceFirst(RegExp(r'\.[0-9]*$'), '')}',
        is24hours: false,
        width: clockSize,
        height: clockSize);
  }

  Widget _localMeanTimeClock(
      DateTime localMeanTime, String location, double clockSize) {
    return AnalogClock(
      hour: localMeanTime.hour,
      minute: localMeanTime.minute,
      second: localMeanTime.second,
      upperLabel: AppLocalizations.of(context)!.meanSolarTime,
      lowerLabel:
          '${localMeanTime.toString().replaceFirst(RegExp(r'\.[0-9]*Z$'), ' ')}\n$location',
      is24hours: false,
      width: clockSize,
      height: clockSize,
    );
  }

  Widget _localMeanSiderealTimeClock(DateTime lmst, double clockSize) {
    return AnalogClock(
      hour: lmst.hour,
      minute: lmst.minute,
      second: lmst.second,
      upperLabel: AppLocalizations.of(context)!.siderealTime,
      lowerLabel: lmst
          .toString()
          .replaceFirst(RegExp(r'^[0-9-]* '), ' ')
          .replaceFirst(RegExp(r'\.[0-9]*Z$'), ''),
      is24hours: true,
      signList: zodiacSign,
      width: clockSize,
      height: clockSize,
    );
  }
}
