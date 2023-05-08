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

const appName = 'Csilszim';
const defaultLatNeg = false;
const defaultLatDeg = 47;
const defaultLatMin = 26;
const defaultLatSec = 32;
const defaultLongNeg = false;
const defaultLongDeg = 19;
const defaultLongMin = 32;
const defaultLongSec = 18;

final horizonPaint = Paint()
  ..color = const Color(0xff0f1317) // Color(0xff0c1014)
  ..style = PaintingStyle.fill;

final backgroundPaint = Paint()
  ..color = const Color(0xff1f252d) // Color(0xff192029)
  ..style = PaintingStyle.fill;

final horizontalGridPaint = Paint()
  ..color = Colors.orange
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 0.5;

final equatorialGridPaint = Paint()
  ..color = Colors.green
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 0.5;

final equatorPaint = Paint()
  ..color = Colors.red
  ..style = PaintingStyle.stroke
  ..strokeWidth = 0.5;

final eclipticPaint = Paint()
  ..color = Colors.yellow
  ..style = PaintingStyle.stroke
  ..strokeWidth = 0.5;

final constellationLinePaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 0.5;

final starBlurPaint = Paint()
  ..color = Colors.grey
  ..imageFilter =
  ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0, tileMode: TileMode.decal)
  ..style = PaintingStyle.fill;

final starPaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.fill;

final moonBlurPaint = Paint()
  ..color = Colors.grey
  ..imageFilter =
  ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0, tileMode: TileMode.decal)
  ..style = PaintingStyle.fill;

final moonLightSidePaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.fill;

final moonDarkSidePaint = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.fill;

final deepSkyObjectStrokePaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.0;

final deepSkyObjectThickStrokePaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.5;

final deepSkyObjectFillPaint = Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.fill
  ..strokeWidth = 0;

final fovPaint = Paint()
  ..color = Colors.red
  ..style = PaintingStyle.stroke;

const celestialObjectLabelTextStyle = TextStyle(
    color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.normal);

const constellationLabelTextStyle = TextStyle(
    color: Colors.lightGreen, fontSize: 18.0, fontWeight: FontWeight.normal);

