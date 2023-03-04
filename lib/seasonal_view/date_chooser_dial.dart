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

const dialOuterBorderSize = 110.0;
const dialInnerBorderSize = 100.0;
const dialInnerBorderWidth = 3.0;
const dialOuterBorderWidth = 2.0;
const gridPosition = -60.0;
const mainGridWidth = 1.5;
const mainGridHeight = 5.0;
const subGridWidth = 1.0;
const subGridHeight = 2.0;
const monthNumberPosition = -66.0;
const monthNumberSize = 10.0;
const dateFontSize = 14.0;
const marginForLabel = 25.0;
const markerPosition = -40.0;
const dialSize = dialOuterBorderSize + marginForLabel * 2;
const dialCenter = Offset(dialSize / 2, dialSize / 2);

const dayOffsetOfMonthInNormalYear = [
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

const dayOffsetOfMonthInLeapYear = [
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
        margin: const EdgeInsets.all(marginForLabel),
        decoration: BoxDecoration(
            color: null,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber,
              width: dialOuterBorderWidth,
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
              width: dialInnerBorderWidth,
            )),
      ),
      for (final startDay in isLeapYear
          ? dayOffsetOfMonthInLeapYear
          : dayOffsetOfMonthInNormalYear)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(startDay / (isLeapYear ? 366 : 365) * fullTurn)
            ..translate(0.0, gridPosition),
          child: Container(
            width: mainGridWidth,
            height: mainGridHeight,
            color: Colors.amber,
          ),
        ),
      for (final startDay in isLeapYear
          ? dayOffsetOfMonthInLeapYear
          : dayOffsetOfMonthInNormalYear)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ((startDay + 10) / (isLeapYear ? 366 : 365) * fullTurn)
            ..translate(0.0, gridPosition),
          child: Container(
            width: subGridWidth,
            height: subGridHeight,
            color: Colors.amber,
          ),
        ),
      for (final startDay in isLeapYear
          ? dayOffsetOfMonthInLeapYear
          : dayOffsetOfMonthInNormalYear)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ((startDay + 20) / (isLeapYear ? 366 : 365) * fullTurn)
            ..translate(0.0, gridPosition),
          child: Container(
            width: subGridWidth,
            height: subGridHeight,
            color: Colors.amber,
          ),
        ),
      for (var i = 1; i <= 12; ++i)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ((dayOffsetOfMonthInLeapYear[i - 1] + 15) / 366 * fullTurn)
            ..translate(0.0, monthNumberPosition),
          child: Container(
            width: monthNumberSize * 2,
            height: monthNumberSize,
            alignment: Alignment.center,
            child: Text(i.toString(),
                style: const TextStyle(
                    fontSize: monthNumberSize,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                )),
          ),
        ),
      Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          // ..rotateZ(elapsedYear * fullTurn)
          ..rotateZ(angle)
          ..translate(0.0, markerPosition),
        child: Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: const Text('▲',
              style: TextStyle(
                fontSize: monthNumberSize,
                color: Colors.amber,
              )),
        ),
      ),
      Text(dateString,
          style: const TextStyle(
            fontSize: dateFontSize,
            color: Colors.amber,
            fontFeatures: [FontFeature.tabularFigures()],
          )),
      // ),
      // ),
    ]);
  }
}
