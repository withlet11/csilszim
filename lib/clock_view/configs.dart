/*
 * configs.dart
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

const zodiacSign = ['♓', '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒'];

class Settings {
  final Size screenSize;

  const Settings(this.screenSize);

  Offset get center => screenSize.center(Offset.zero);

  double get bezelSize => min(screenSize.width, screenSize.height) * 0.45;

  double get hourHandLength => bezelSize * 0.55;

  double get hourHandWidth => bezelSize * 0.03;

  double get hourHandCenterSize => bezelSize * 0.06;

  double get minuteHandLength => bezelSize * 0.8;

  double get minuteHandCenterSize => bezelSize * 0.045;

  double get secondHandLength => bezelSize * 0.8;

  double get secondHandCenterSize => bezelSize * 0.04;

  double get innerEnd => bezelSize * 0.88;

  double get outerEnd => bezelSize * 0.92;

  double get numberPosition => bezelSize * 0.78;

  double get symbolPosition => bezelSize * 0.60;

  double get largeLetter => bezelSize * 0.18;

  double get smallLetter => bezelSize * 0.12;

  double get extraSmallLetter => bezelSize * 0.08;

  double get baseStroke => bezelSize * 0.01;

  TextStyle get smallHourNumberTextStyle => TextStyle(
      color: Colors.lightGreen,
      fontSize: smallLetter,
      fontWeight: FontWeight.normal);

  TextStyle get largeHourNumberTextStyle => TextStyle(
      color: Colors.lightGreen,
      fontSize: largeLetter,
      fontWeight: FontWeight.normal);

  TextStyle get upperLabelTextStyle => TextStyle(
      color: Colors.grey, fontSize: smallLetter, fontWeight: FontWeight.bold);

  TextStyle get lowerLabelTextStyle => TextStyle(
      color: Colors.grey,
      fontSize: extraSmallLetter,
      fontWeight: FontWeight.bold,
      fontFeatures: const [FontFeature.tabularFigures()]);

  TextStyle get signTextStyle => TextStyle(
      color: Colors.lightGreen,
      fontSize: largeLetter,
      fontWeight: FontWeight.normal);
}
