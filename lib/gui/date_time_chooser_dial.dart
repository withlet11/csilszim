/*
 * date_time_chooser_dial.dart
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
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../constants.dart';

const _dialOuterBorderSize = 110.0;
const _dialInnerBorderSize = 100.0;
const _dialInnerBorderWidth = 3.0;
const _dialOuterBorderWidth = 2.0;
const _gridPosition = -60.0;
const _mainGridWidth = 1.5;
const _mainGridHeight = 5.0;
const _subGridWidth = 1.0;
const _subGridHeight = 2.0;
const _monthNumberPosition = -66.0;
const _monthNumberSize = 10.0;
const _hourNumberSize = 10.0;
const _dateTimeFontSize = 14.0;
const _buttonSize = 14.0;
const _marginForLabel = 25.0;
const _markerPosition = -40.0;
const _dialSize = _dialOuterBorderSize + _marginForLabel * 2;
const _dialCenter = Offset(_dialSize / 2, _dialSize / 2);
const _oneDay = Duration(days: 1);
const _oneMinute = Duration(minutes: 1);
const _activeColor = Colors.amber;
const _inactiveColor = Colors.grey;
const _todayIcon = Icons.today;
const _nowIcon = Icons.access_time_filled;
const _incrementIcon = Icons.add_box;
const _decrementIcon = Icons.indeterminate_check_box;

const _monthNumberTextStyle = TextStyle(
    fontSize: _monthNumberSize,
    color: _activeColor,
    fontWeight: FontWeight.bold);

const _hourNumberTextStyle = TextStyle(
    fontSize: _monthNumberSize,
    color: _activeColor,
    fontWeight: FontWeight.bold);

const _indexTextStyle =
    TextStyle(fontSize: _monthNumberSize, color: _activeColor);

const _largeTextStyle = TextStyle(
    fontSize: _dateTimeFontSize,
    color: _activeColor,
    fontFeatures: [FontFeature.tabularFigures()]);

const _smallTextStyle = TextStyle(
    fontSize: _dateTimeFontSize,
    color: _inactiveColor,
    fontFeatures: [FontFeature.tabularFigures()]);

const _dayOffsetOfMonthInNormalYear = [
  0, // January
  31, // February
  59, // March
  90, // April
  120, // May
  151, // June
  181, // July
  212, // August
  243, // September
  273, // October
  304, // November
  334 // December
];

const _dayOffsetOfMonthInLeapYear = [
  0, // January
  31, // February
  60, // March
  91, // April
  121, // May
  152, // June
  182, // July
  213, // August
  244, // September
  274, // October
  305, // November
  335 // December
];

class DateTimeChooserDial extends StatefulWidget {
  final Duration dateTimeOffset;
  final bool isDateMode;
  final ValueChanged<Duration> onDateChange;
  final ValueChanged<bool> onModeChange;

  const DateTimeChooserDial({
    super.key,
    this.dateTimeOffset = Duration.zero,
    required this.isDateMode,
    required this.onDateChange,
    required this.onModeChange,
  });

  @override
  State createState() => _DateChooserDial();
}

class _DateChooserDial extends State<DateTimeChooserDial>
    with SingleTickerProviderStateMixin {
  // static const dialOuterBorderSize = _dialOuterBorderSize;
  // static const dialInnerBorderSize = _dialInnerBorderSize;
  // static const dialCenter = _dialCenter;

  late final ValueChanged<Duration> _onDateChange;
  late final ValueChanged<bool> _onModeChange;
  var _isDateMode = true;
  var _dateTimeOffset = Duration.zero;
  var _angle = 0.0;
  late final double _angleOffset;
  var _rotatesDial = false;

  late Ticker _ticker;
  var _elapsed = Duration.zero;

  @override
  void initState() {
    final dateTime = DateTime.now();
    _dateTimeOffset = widget.dateTimeOffset;
    _onDateChange = widget.onDateChange;
    _onModeChange = widget.onModeChange;
    _isDateMode = widget.isDateMode;
    _angleOffset =
        DateTime(dateTime.year).timeZoneOffset.inMinutes / 60 * hourInRad;

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
  void dispose() {
    _ticker.dispose(); // For Ticker.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = DateTime.now();
    final Widget dialWidget;
    if (_isDateMode) {
      final dateTime = current.add(_dateTimeOffset);
      final year = dateTime.year;
      final isLeapYear = _isLeapYear(year);
      final lengthOfYear = (isLeapYear ? 366 : 365) * 86400e3;
      final yearBegin = DateTime(year).millisecondsSinceEpoch;
      _angle = (dateTime.millisecondsSinceEpoch - yearBegin) /
          lengthOfYear *
          fullTurn;
      dialWidget = _makeDateDial(current, isLeapYear);
    } else {
      final dateTime = current.add(_dateTimeOffset);
      final time = dateTime.millisecondsSinceEpoch % 86400e3;
      _angle = time / 86400e3 * fullTurn;
      dialWidget = _makeTimeDial(current);
    }

    return Listener(
      onPointerDown: _dispatchPointerDown,
      onPointerMove: _dispatchPointerMove,
      onPointerUp: _toggleMode,
      child: dialWidget,
    );
  }

  Widget _makeDateDial(DateTime dateTime, bool isLeapYear) {
    return Stack(alignment: Alignment.center, children: [
      _makeDialOuterBorder(),
      _makeDialInnerBorder(),
      for (final startDay in isLeapYear
          ? _dayOffsetOfMonthInLeapYear
          : _dayOffsetOfMonthInNormalYear)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(startDay / (isLeapYear ? 366 : 365) * fullTurn)
            ..translate(0.0, _gridPosition),
          child: Container(
            width: _mainGridWidth,
            height: _mainGridHeight,
            color: _activeColor,
          ),
        ),
      for (final startDay in isLeapYear
          ? _dayOffsetOfMonthInLeapYear
          : _dayOffsetOfMonthInNormalYear)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ((startDay + 10) / (isLeapYear ? 366 : 365) * fullTurn)
            ..translate(0.0, _gridPosition),
          child: Container(
            width: _subGridWidth,
            height: _subGridHeight,
            color: _activeColor,
          ),
        ),
      for (final startDay in isLeapYear
          ? _dayOffsetOfMonthInLeapYear
          : _dayOffsetOfMonthInNormalYear)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ((startDay + 20) / (isLeapYear ? 366 : 365) * fullTurn)
            ..translate(0.0, _gridPosition),
          child: Container(
            width: _subGridWidth,
            height: _subGridHeight,
            color: _activeColor,
          ),
        ),
      for (var i = 1; i <= 12; ++i)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(
                (_dayOffsetOfMonthInLeapYear[i - 1] + 15) / 366 * fullTurn)
            ..translate(0.0, _monthNumberPosition),
          child: Container(
            width: _monthNumberSize * 2,
            height: _monthNumberSize,
            alignment: Alignment.center,
            child: Text(i.toString(), style: _monthNumberTextStyle),
          ),
        ),
      _makeIndex(_angle),
      _makeDateTimeLabel(dateTime),
      _makeButtons(),
    ]);
  }

  Widget _makeTimeDial(DateTime dateTime) {
    final timezoneOffset = dateTime.add(_dateTimeOffset).timeZoneOffset.inHours;
    return Stack(alignment: Alignment.center, children: [
      _makeDialOuterBorder(),
      _makeDialInnerBorder(),
      for (var hour = 0; hour < 24; ++hour)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(hour * hourInRad)
            ..translate(0.0, _gridPosition),
          child: Container(
            width: _mainGridWidth,
            height: _mainGridHeight,
            color: _activeColor,
          ),
        ),
      for (var hour = 0; hour < 24 * 4; ++hour)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(hour / 4.0 * hourInRad)
            ..translate(0.0, _gridPosition),
          child: Container(
            width: _subGridWidth,
            height: _subGridHeight,
            color: _activeColor,
          ),
        ),
      for (var hour = 0; hour < 24; hour += 3)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ((hour - timezoneOffset) * hourInRad + _angleOffset)
            ..translate(0.0, _monthNumberPosition),
          child: Container(
            width: _hourNumberSize * 2,
            height: _hourNumberSize,
            alignment: Alignment.center,
            child: Text(hour.toString(), style: _hourNumberTextStyle),
          ),
        ),
      _makeIndex(_angle + _angleOffset),
      _makeDateTimeLabel(dateTime),
      _makeButtons(),
    ]);
  }

  Widget _makeDialOuterBorder() {
    return Container(
      width: _dialOuterBorderSize,
      height: _dialOuterBorderSize,
      margin: const EdgeInsets.all(_marginForLabel),
      decoration: BoxDecoration(
          color: null,
          shape: BoxShape.circle,
          border: Border.all(
            color: _activeColor,
            width: _dialOuterBorderWidth,
          )),
    );
  }

  Widget _makeDialInnerBorder() {
    return Container(
      width: _dialInnerBorderSize,
      height: _dialInnerBorderSize,
      decoration: BoxDecoration(
          color: null,
          shape: BoxShape.circle,
          border: Border.all(
            color: _activeColor,
            width: _dialInnerBorderWidth,
          )),
    );
  }

  Widget _makeIndex(double angle) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(angle)
        ..translate(0.0, _markerPosition),
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        child: const Text('\u25b2', style: _indexTextStyle), // ▲
      ),
    );
  }

  Widget _makeDateTimeLabel(DateTime dateTime) {
    final (dateTextStyle, timeTextStyle) = _isDateMode
        ? (_largeTextStyle, _smallTextStyle)
        : (_smallTextStyle, _largeTextStyle);
    final selectedDate = dateTime.add(_dateTimeOffset);
    final dateString = selectedDate.toIso8601String();
    return SizedBox(
      height: _dialOuterBorderSize,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dateString.substring(0, 10), style: dateTextStyle),
          Text(dateString.substring(11, 19), style: timeTextStyle),
        ],
      ),
    );
  }

  Widget _makeButtons() {
    final resetButton = _isDateMode
        ? Icon(_todayIcon,
            color: _dateTimeOffset.inDays == 0 ? _inactiveColor : _activeColor,
            size: _buttonSize)
        : Icon(_nowIcon,
            color: _dateTimeOffset.inSeconds % 86400 == 0
                ? _inactiveColor
                : _activeColor,
            size: _buttonSize);
    return SizedBox(
        height: _dialSize,
        width: _dialOuterBorderSize,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: _decrementDateTimeOffset,
                  child: const Icon(_decrementIcon,
                      color: _activeColor, size: _buttonSize)),
              GestureDetector(
                onTap: _resetDateTimeOffset,
                child: resetButton,
              ),
              GestureDetector(
                onTap: _incrementDateTimeOffset,
                child: const Icon(_incrementIcon,
                    color: _activeColor, size: _buttonSize),
              ),
            ],
          ),
        ));
  }

  void _dispatchPointerDown(PointerDownEvent event) {
    final position = event.localPosition;
    final offset = position - _dialCenter;
    final distance = offset.distance;
    if (distance > _dialInnerBorderSize * 0.25 &&
        distance < _dialOuterBorderSize * 0.6) {
      _rotatesDial = true;
      _updateWithPosition(position);
    } else {
      _rotatesDial = false;
    }
  }

  void _dispatchPointerMove(PointerMoveEvent event) {
    final position = event.localPosition;
    final offset = position - _dialCenter;
    final distance = offset.distance;
    if (distance > _dialInnerBorderSize * 0.25 &&
        distance < _dialOuterBorderSize * 0.6) {
      _rotatesDial = true;
      _updateWithPosition(position);
    }
  }

  void _toggleMode(PointerUpEvent event) {
    final position = event.localPosition;
    final offset = position - _dialCenter;
    final distance = offset.distance;
    if (distance < _dialInnerBorderSize * 0.25 && !_rotatesDial) {
      setState(() {
        _isDateMode = !_isDateMode;
        _onModeChange(_isDateMode);
      });
    }
    _rotatesDial = false;
  }

  void _updateWithPosition(Offset position) {
    final offset = position - _dialCenter;
    final distance = offset.distance;
    if (distance > _dialInnerBorderSize * 0.25 &&
        distance < _dialOuterBorderSize * 0.6) {
      setState(() {
        final angle =
            (atan2(offset.dx, -offset.dy) - (_isDateMode ? 0 : _angleOffset)) %
                fullTurn;
        final overRotation = switch (angle - _angle) {
          > 0.75 * fullTurn => -1,
          < -0.75 * fullTurn => 1,
          _ => 0
        };
        _angle = angle;

        (_isDateMode ? _changeDate : _changeTime)(overRotation);
      });
    }
  }

  void _changeDate(int overYear) {
    final dateTime = DateTime.now();
    final previous = dateTime.add(_dateTimeOffset);
    final newYear = previous.year + overYear;
    final isLeapYear = _isLeapYear(newYear);
    final lengthOfYear = isLeapYear ? 366 : 365;
    final yearBegin = DateTime(newYear).millisecondsSinceEpoch ~/ 86400e3;
    final currentDaySinceEpoch = dateTime.millisecondsSinceEpoch ~/ 86400000;
    final newDaySinceEpoch =
        (lengthOfYear * _angle / fullTurn + yearBegin).round();
    _dateTimeOffset = Duration(
        days: newDaySinceEpoch - currentDaySinceEpoch,
        milliseconds: _dateTimeOffset.inMilliseconds % 86400000);
    _onDateChange(_dateTimeOffset);
  }

  void _changeTime(int overDay) {
    final dateTime = DateTime.now();
    final previous = dateTime.add(_dateTimeOffset);
    final newDate = previous.millisecondsSinceEpoch ~/ 86400e3 + overDay;
    final newDateTime = DateTime.fromMillisecondsSinceEpoch(
        86400000 * newDate + 86400e3 * _angle ~/ fullTurn);
    _dateTimeOffset = newDateTime.difference(dateTime);
    _onDateChange(_dateTimeOffset);
  }

  void _incrementDateTimeOffset() {
    setState(() {
      _dateTimeOffset += _isDateMode ? _oneDay : _oneMinute;
      _onDateChange(_dateTimeOffset);
    });
  }

  void _decrementDateTimeOffset() {
    setState(() {
      _dateTimeOffset -= _isDateMode ? _oneDay : _oneMinute;
      _onDateChange(_dateTimeOffset);
    });
  }

  void _resetDateTimeOffset() {
    setState(() {
      final dateAndTime = _dateTimeOffset.inMilliseconds;
      final time = dateAndTime % 86400000;
      _dateTimeOffset =
          Duration(milliseconds: _isDateMode ? time : dateAndTime - time);
      _onDateChange(_dateTimeOffset);
    });
  }
}

bool _isLeapYear(int year) =>
    year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
