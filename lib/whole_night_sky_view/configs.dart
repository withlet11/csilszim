/*
 * configs.dart
 *
 * Copyright 2023-2024 Yasuhiro Yamakawa <withlet11@gmail.com>
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

const minScale = 1.0;
const maxScale = 20.0;
const initialScale = minScale;
const defaultDec = 0.0;
const defaultRa = pi;
const defaultTfov = 5.0;
const minimumTfov = 1.0;
const maximumTfov = 10.0;

const decRaTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    fontFeatures: [FontFeature.tabularFigures()]);

const decTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    fontFeatures: [FontFeature.tabularFigures()]);

const raTextStyle = decTextStyle;

final planetPointerPaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1;

const dayColor = Color(0xffdbe9ff);
const civilTwilightColor = Color(0xbf9cb4db);
const nauticalTwilightColor = Color(0xbf5284d7);
const astronomicalTwilightColor = Color(0x7f2d579f);
const twilightLineWidth = 1.0;

final dayZonePaint = Paint()
  ..color = dayColor
  ..style = PaintingStyle.fill;

final civilTwilightZonePaint = Paint()
  ..color = civilTwilightColor
  ..style = PaintingStyle.fill;

final nauticalTwilightZonePaint = Paint()
  ..color = nauticalTwilightColor
  ..style = PaintingStyle.fill;

final astronomicalTwilightZonePaint = Paint()
  ..color = astronomicalTwilightColor
  ..style = PaintingStyle.fill;

final dayLinePaint = Paint()
  ..color = dayColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = twilightLineWidth;

final momentaryHorizonLinePaint = Paint()
  ..color = Colors.green
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.5;

final momentaryHorizonHatchPaint = Paint()
  ..color = Colors.green
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 0.5;

final civilTwilightLinePaint = Paint()
  ..color = civilTwilightColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = twilightLineWidth;

final nauticalTwilightLinePaint = Paint()
  ..color = nauticalTwilightColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = twilightLineWidth;

final astronomicalTwilightLinePaint = Paint()
  ..color = astronomicalTwilightColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = twilightLineWidth;
