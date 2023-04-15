/*
 * offset_3d.dart
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

import '../constants.dart';

class Offset3D {
  final double dx, dy, dz;
  static const zero = Offset3D(0.0, 0.0, 0.0);

  const Offset3D(this.dx, this.dy, this.dz);

  Offset3D.fromDirection(double direction1, double direction2,
      [double distance = 1])
      : dx = cos(direction2) * cos(direction1) * distance,
        dy = cos(direction2) * sin(direction1) * distance,
        dz = sin(direction2) * distance;

  Offset3D operator +(Offset3D addend) =>
      Offset3D(dx + addend.dx, dy + addend.dy, dz + addend.dz);

  Offset3D operator -(Offset3D subtrahend) =>
      Offset3D(dx - subtrahend.dx, dy - subtrahend.dy, dz - subtrahend.dz);

  Offset3D operator *(double multiplier) =>
      Offset3D(dx * multiplier, dy * multiplier, dz * multiplier);

  Offset3D operator /(double divisor) =>
      Offset3D(dx / divisor, dy / divisor, dz / divisor);

  Offset3D operator -() => Offset3D(-dx, -dy, -dz);

  Offset3D rotateX(double angle) {
    final cosAngle = cos(angle);
    final sinAngle = sin(angle);
    return Offset3D(
        dx, dy * cosAngle - dz * sinAngle, dy * sinAngle + dz * cosAngle);
  }

  Offset3D rotateY(double angle) {
    final cosAngle = cos(angle);
    final sinAngle = sin(angle);
    return Offset3D(
        dz * sinAngle + dx * cosAngle, dy, dz * cosAngle - dx * sinAngle);
  }

  Offset3D rotateZ(double angle) {
    final cosAngle = cos(angle);
    final sinAngle = sin(angle);
    return Offset3D(
        dx * cosAngle - dy * sinAngle, dx * sinAngle + dy * cosAngle, dz);
  }

  Offset3D rotateToAxisZ(double angle) {
    final distanceFromAxisZ = sqrt(dx * dx + dy * dy);
    if (distanceFromAxisZ == 0) return this;

    final currentAngle = atan(dz / distanceFromAxisZ);
    final newAngle = currentAngle + angle;
    if (newAngle >= halfTurn || newAngle <= -halfTurn) return this;

    final newPosition = Offset3D(
        dx * cos(angle) - dz * sin(angle) * dx / distanceFromAxisZ,
        dy * cos(angle) - dz * sin(angle) * dy / distanceFromAxisZ,
        distanceFromAxisZ * sin(angle) + dz * cos(angle));
    return (dx * newPosition.dx > 0 || dy * newPosition.dy > 0)
        ? newPosition
        : this;
  }

  Offset3D rotateXYZ(double angleX, double angleY, double angleZ) {
    final sinAngleX = sin(angleX);
    final cosAngleX = cos(angleX);
    final sinAngleY = sin(angleY);
    final cosAngleY = cos(angleY);
    final sinAngleZ = sin(angleZ);
    final cosAngleZ = cos(angleZ);
    final a11 = cosAngleY * cosAngleZ;
    final a12 = sinAngleX * sinAngleY * cosAngleZ - cosAngleX * sinAngleZ;
    final a13 = cosAngleX * sinAngleY * cosAngleZ + sinAngleX * sinAngleZ;
    final a21 = cosAngleY * sinAngleZ;
    final a22 = sinAngleX * sinAngleY * sinAngleZ + cosAngleX * cosAngleZ;
    final a23 = cosAngleX * sinAngleY * sinAngleZ - sinAngleX * cosAngleZ;
    final a31 = -sinAngleY;
    final a32 = sinAngleX * cosAngleY;
    final a33 = cosAngleX * cosAngleY;

    return Offset3D(dx * a11 + dy * a12 + dz * a13,
        dx * a21 + dy * a22 + dz * a23, dx * a31 + dy * a32 + dz * a33);
  }

  double distance() => sqrt(dx * dx + dy * dy + dz * dz);
}
