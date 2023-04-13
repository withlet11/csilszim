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

import 'dart:ui';

import 'package:flutter/material.dart';

const minScale = 1.0;
const maxScale = 128.0;
const initialScale = minScale;
const defaultAlt = 89.999;
const defaultAz = 180.0;

const backgroundColor = Color(0xff192029);
const horizonColor = Color(0xff0c1014); // Color(0xff192920);

const altAzTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    fontFeatures: [FontFeature.tabularFigures()]);

const decRaTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    fontFeatures: [FontFeature.tabularFigures()]);

const constellationLabelTextStyle = TextStyle(
    color: Colors.lightGreen, fontSize: 18.0, fontWeight: FontWeight.normal);

const largeDirectionSignTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
);

const smallDirectionSignTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 12.0,
  fontWeight: FontWeight.normal,
);

final starBlurPaint = Paint()
  ..color = Colors.grey
  ..imageFilter =
      ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0, tileMode: TileMode.decal)
  ..style = PaintingStyle.fill;

final starPaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.fill;

final constellationLinePaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 0.5;
