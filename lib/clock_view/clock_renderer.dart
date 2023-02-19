/*
 * clock_renderer.dart
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
import 'configs.dart';

class ClockRenderer extends CustomPainter {
  final int hour, minute, second;
  final String? upperLabel, lowerLabel;
  final int count;
  final List<String>? signList;
  late final Settings settings;

  ClockRenderer(this.hour, this.minute, this.second, this.upperLabel,
      this.lowerLabel, bool is24hours,
      [this.signList])
      : count = is24hours ? 24 : 12;

  @override
  void paint(Canvas canvas, Size size) {
    settings = Settings(size);
    final center = settings.center;
    final bezelSize = settings.bezelSize;
    final baseStroke = settings.baseStroke;

    drawBezel(canvas, center, bezelSize, baseStroke);
    drawGrid(canvas, center, bezelSize, baseStroke);
    drawHourNumber(canvas, center, bezelSize);
    drawSign(canvas, center, bezelSize);
    drawUpperLabel(canvas, center, bezelSize);
    drawLowerLabel(canvas, center, bezelSize);

    drawHourHand(
        canvas,
        (hour % count + minute / 60 + second / 3600) * 12 / count,
        center,
        bezelSize,
        baseStroke);

    drawMinuteHand(
        canvas, minute + second / 60, center, bezelSize, baseStroke * 4);

    drawSecondHand(canvas, second, center, bezelSize, baseStroke * 2);
  }

  void drawBezel(Canvas canvas, Offset center, double size, double stroke) {
    final panelPaint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawCircle(center, size, panelPaint);

    final framePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawCircle(center, size, framePaint);
  }

  void drawGrid(Canvas canvas, Offset center, double bezelSize, double stroke) {
    final majorGridPaint = Paint()
      ..color = Colors.lightGreen
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke * 3;
    final minorGridPaint = Paint()
      ..color = Colors.lightGreen
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    final gridCount = count * 5;
    for (var i = 0; i < gridCount; i++) {
      final radian = i / gridCount * fullTurn;
      final begin = center + Offset.fromDirection(radian, settings.innerEnd);
      final end = center + Offset.fromDirection(radian, settings.outerEnd);
      canvas.drawLine(begin, end, i % 5 == 0 ? majorGridPaint : minorGridPaint);
    }
  }

  void drawHourNumber(Canvas canvas, Offset center, double bezelSize) {
    for (var i = 1; i <= count; i++) {
      final radian = (i / count) * fullTurn - quarterTurn;
      final position =
          center + Offset.fromDirection(radian, settings.numberPosition);
      final textSpan = TextSpan(
        style: TextStyle(
          color: Colors.lightGreen,
          fontSize: (count == 24 || i % 3 > 0)
              ? settings.smallLetter
              : settings.largeLetter,
          fontWeight: FontWeight.normal,
        ),
        text: i.toString(),
      );

      final painter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      final offset = Offset(painter.size.width, painter.size.height) / 2;
      painter.paint(canvas, position - offset);
    }
  }

  void drawUpperLabel(Canvas canvas, Offset center, double bezelSize) {
    if (upperLabel != null) {
      final position = center + Offset(0, bezelSize * -0.25);
      final textSpan = TextSpan(
        style: TextStyle(
          color: Colors.grey,
          fontSize: settings.smallLetter,
          fontWeight: FontWeight.bold,
        ),
        text: upperLabel,
      );

      final painter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      final offset = Offset(painter.size.width, painter.size.height) / 2;
      painter.paint(canvas, position - offset);
    }
  }

  void drawLowerLabel(Canvas canvas, Offset center, double bezelSize) {
    if (lowerLabel != null) {
      final position = center + Offset(0, bezelSize * 0.30);
      final textSpan = TextSpan(
        style: TextStyle(
            color: Colors.grey,
            fontSize: settings.extraSmallLetter,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()]),
        text: lowerLabel,
      );

      final painter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      final offset = Offset(painter.size.width, painter.size.height) / 2;
      painter.paint(canvas, position - offset);
    }
  }

  void drawSign(Canvas canvas, Offset center, double bezelSize) {
    if (signList != null) {
      signList!.asMap().forEach((i, sign) {
        final radian = (i / 12) * fullTurn - quarterTurn;
        final position =
            center + Offset.fromDirection(radian, settings.symbolPosition);
        final textSpan = TextSpan(
          style: TextStyle(
            color: Colors.lightGreen,
            fontSize: settings.largeLetter,
            fontWeight: FontWeight.normal,
          ),
          text: sign,
        );

        final painter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        painter.layout();

        final offset = Offset(painter.size.width, painter.size.height) / 2;
        painter.paint(canvas, position - offset);
      });
    }
  }

  void drawHourHand(
      canvas, double hour, Offset center, double bezelSize, double stroke) {
    final length = settings.hourHandLength;
    final width = settings.hourHandWidth;
    final centerSize = settings.hourHandCenterSize;

    final radian = hour / 12 * fullTurn;
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..relativeMoveTo(cos(radian) * width, sin(radian) * width)
      ..relativeLineTo(sin(radian) * length, -cos(radian) * length)
      ..relativeLineTo(-cos(radian + pi / 3) * width * tan(pi / 3),
          -sin(radian + pi / 3) * width * tan(pi / 3))
      ..relativeLineTo(-cos(radian - pi / 3) * width * tan(pi / 3),
          -sin(radian - pi / 3) * width * tan(pi / 3))
      ..relativeLineTo(-sin(radian) * length, cos(radian) * length);
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, centerSize, paint);
  }

  void drawMinuteHand(Canvas canvas, double minute, Offset center,
      double bezelSize, double stroke) {
    final length = settings.minuteHandLength;
    final centerSize = settings.minuteHandCenterSize;
    final radian = minute / 60 * fullTurn;
    final end = center.translate(sin(radian) * length, -cos(radian) * length);

    final paint = Paint()
      ..color = Colors.pink
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.square
      ..strokeWidth = stroke;
    canvas.drawLine(center, end, paint);
    canvas.drawCircle(center, centerSize, paint);
  }

  void drawSecondHand(Canvas canvas, int second, Offset center,
      double bezelSize, double stroke) {
    final length = settings.secondHandLength;
    final centerSize = settings.secondHandCenterSize;
    final radian = second / 60 * fullTurn;
    final end = center.translate(sin(radian) * length, -cos(radian) * length);

    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.square
      ..strokeWidth = stroke;
    canvas.drawLine(center, end, paint);
    canvas.drawCircle(center, centerSize, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
