/*
 * date_chooser_dial.dart
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
const _dateFontSize = 14.0;
const _marginForLabel = 25.0;
const _markerPosition = -40.0;
const _dialSize = _dialOuterBorderSize + _marginForLabel * 2;
const _dialCenter = Offset(_dialSize / 2, _dialSize / 2);

const _monthNumberTextStyle = TextStyle(
    fontSize: _monthNumberSize,
    color: Colors.amber,
    fontWeight: FontWeight.bold);

const _indexTextStyle =
    TextStyle(fontSize: _monthNumberSize, color: Colors.amber);

const _dateTextStyle = TextStyle(
    fontSize: _dateFontSize,
    color: Colors.amber,
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

class DateChooserDial extends StatefulWidget {
  final DateTime dateTime;
  final ValueChanged<DateTime> onChanged;

  const DateChooserDial(
      {super.key, required this.dateTime, required this.onChanged});

  @override
  State createState() => _DateChooserDial();
}

class _DateChooserDial extends State<DateChooserDial> {
  static const dialOuterBorderSize = _dialOuterBorderSize;
  static const dialInnerBorderSize = _dialInnerBorderSize;
  static const dialCenter = _dialCenter;
  var date = DateTime.now();
  late final ValueChanged<DateTime> onChanged;
  var _angle = 0.0;
  var _isLeapYear = false;

  @override
  void initState() {
    date = widget.dateTime;
    onChanged = widget.onChanged;

    final year = date.year;
    final yearBegin = DateTime(year).millisecondsSinceEpoch;
    final yearEnd = DateTime(year + 1).millisecondsSinceEpoch;
    final lengthOfYear = yearEnd - yearBegin;
    _angle =
        (date.millisecondsSinceEpoch - yearBegin) / lengthOfYear * fullTurn;
    _isLeapYear = lengthOfYear == 366 * 86400 * 1000;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: dialOuterBorderSize,
          height: dialOuterBorderSize,
          margin: const EdgeInsets.all(_marginForLabel),
          decoration: BoxDecoration(
              color: null,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.amber,
                width: _dialOuterBorderWidth,
              )),
        ),
        Container(
          width: dialInnerBorderSize,
          height: dialInnerBorderSize,
          decoration: BoxDecoration(
              color: null,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.amber,
                width: _dialInnerBorderWidth,
              )),
        ),
        for (final startDay in _isLeapYear
            ? _dayOffsetOfMonthInLeapYear
            : _dayOffsetOfMonthInNormalYear)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(startDay / (_isLeapYear ? 366 : 365) * fullTurn)
              ..translate(0.0, _gridPosition),
            child: Container(
              width: _mainGridWidth,
              height: _mainGridHeight,
              color: Colors.amber,
            ),
          ),
        for (final startDay in _isLeapYear
            ? _dayOffsetOfMonthInLeapYear
            : _dayOffsetOfMonthInNormalYear)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ((startDay + 10) / (_isLeapYear ? 366 : 365) * fullTurn)
              ..translate(0.0, _gridPosition),
            child: Container(
              width: _subGridWidth,
              height: _subGridHeight,
              color: Colors.amber,
            ),
          ),
        for (final startDay in _isLeapYear
            ? _dayOffsetOfMonthInLeapYear
            : _dayOffsetOfMonthInNormalYear)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ((startDay + 20) / (_isLeapYear ? 366 : 365) * fullTurn)
              ..translate(0.0, _gridPosition),
            child: Container(
              width: _subGridWidth,
              height: _subGridHeight,
              color: Colors.amber,
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
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_angle)
            ..translate(0.0, _markerPosition),
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            child: const Text('▲', style: _indexTextStyle),
          ),
        ),
        Text(date.toIso8601String().substring(0, 10), style: _dateTextStyle),
      ]),
      onPointerDown: (event) => _updateWithPosition(event.localPosition),
      onPointerMove: (event) => _updateWithPosition(event.localPosition),
    );
  }

  void _updateWithPosition(Offset position) {
    setState(() {
      final offset = position - dialCenter;
      final distance = offset.distance;
      if (distance < dialInnerBorderSize * 0.125 ||
          distance > dialOuterBorderSize * 0.75) return;
      final angle = (atan2(offset.dx, -offset.dy) + fullTurn) % fullTurn;
      final overYear = (angle - _angle > 0.75 * fullTurn)
          ? -1
          : (angle - _angle < -0.75 * fullTurn)
              ? 1
              : 0;

      _updateWithAngle(angle, overYear);
    });
  }

  void _updateWithAngle(double angle, int overYear) {
    final year = date.year + overYear;
    final yearBegin = DateTime(year).millisecondsSinceEpoch;
    final yearEnd = DateTime(year + 1).millisecondsSinceEpoch;
    final lengthOfYear = yearEnd - yearBegin;
    date = DateTime.fromMillisecondsSinceEpoch(
        (lengthOfYear * angle / fullTurn + yearBegin).round());
    _isLeapYear = lengthOfYear == 366 * 86400 * 1000;
    _angle = angle;
    onChanged(date);
  }
}
