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

class DateChooserDial extends StatelessWidget {
  static const dialOuterBorderSize = _dialOuterBorderSize;
  static const dialInnerBorderSize = _dialInnerBorderSize;
  static const dialCenter = _dialCenter;
  final String dateString;
  final double angle;
  final bool isLeapYear;

  const DateChooserDial(
      {super.key,
      required this.dateString,
      required this.angle,
      required this.isLeapYear});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
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
            color: Colors.amber,
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
            color: Colors.amber,
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
          // ..rotateZ(elapsedYear * fullTurn)
          ..rotateZ(angle)
          ..translate(0.0, _markerPosition),
        child: Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: const Text('▲', style: _indexTextStyle),
        ),
      ),
      Text(dateString, style: _dateTextStyle),
      // ),
      // ),
    ]);
  }
}
