/*
 * graphical_projection.dart
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

import '../../utilities/offset_3d.dart';
import 'perspective.dart';

class GraphicalProjection {
  final Offset3D cameraPosition;
  final double distance;
  final double angleX, angleY, angleZ;
  final double a11, a12, a13;
  final double a21, a22, a23;
  final double a31, a32, a33;

  GraphicalProjection._internal(
      this.cameraPosition,
      this.distance,
      this.angleX,
      this.angleY,
      this.angleZ,
      this.a11,
      this.a12,
      this.a13,
      this.a21,
      this.a22,
      this.a23,
      this.a31,
      this.a32,
      this.a33);

  factory GraphicalProjection(Offset3D cameraPosition, [double angleZ = 0]) {
    final directionOfAxisZ = _directionOfAxisZOnPerspective(cameraPosition);

    final x = -cameraPosition.dx;
    final y = -cameraPosition.dy;
    final z = -cameraPosition.dz;

    final angleX = atan2(y, z);
    final angleY = atan2(-x, y * sin(angleX) + z * cos(angleX));

    final sinAngleX = sin(angleX);
    final cosAngleX = cos(angleX);
    final sinAngleY = sin(angleY);
    final cosAngleY = cos(angleY);
    final sinAngleZ = sin(angleZ - directionOfAxisZ);
    final cosAngleZ = cos(angleZ - directionOfAxisZ);

    final a11 = cosAngleY * cosAngleZ;
    final a12 = sinAngleX * sinAngleY * cosAngleZ - cosAngleX * sinAngleZ;
    final a13 = cosAngleX * sinAngleY * cosAngleZ + sinAngleX * sinAngleZ;
    final a21 = cosAngleY * sinAngleZ;
    final a22 = sinAngleX * sinAngleY * sinAngleZ + cosAngleX * cosAngleZ;
    final a23 = cosAngleX * sinAngleY * sinAngleZ - sinAngleX * cosAngleZ;
    final a31 = -sinAngleY;
    final a32 = sinAngleX * cosAngleY;
    final a33 = cosAngleX * cosAngleY;

    return GraphicalProjection._internal(
        cameraPosition,
        sqrt(x * x + y * y + z * z),
        angleX,
        angleY,
        angleZ,
        a11,
        a12,
        a13,
        a21,
        a22,
        a23,
        a31,
        a32,
        a33);
  }

  Perspective transform(Offset3D offset) {
    Offset3D moved = offset - cameraPosition;
    return Perspective(
        moved.dx * a11 + moved.dy * a12 + moved.dz * a13,
        moved.dx * a21 + moved.dy * a22 + moved.dz * a23,
        moved.dx * a31 + moved.dy * a32 + moved.dz * a33);
  }
}

/// Calculates the direction of axis Z after transformation to perspective
/// from camera position.
double _directionOfAxisZOnPerspective(Offset3D cameraPosition) {
  final x = -cameraPosition.dx;
  final y = -cameraPosition.dy;
  final z = -cameraPosition.dz;

  final angleX = atan2(y, z);
  final angleY = atan2(-x, y * sin(angleX) + z * cos(angleX));
  // const angleZ = 0; // no rotation around axis-Z

  final sinAngleX = sin(angleX);
  final cosAngleX = cos(angleX);
  final sinAngleY = sin(angleY);
  final cosAngleY = cos(angleY);
  // final sinAngleZ = sin(angleZ); // always 0
  // final cosAngleZ = cos(angleZ); // always 1

  final a13 = cosAngleX * sinAngleY; // * cosAngleZ + sinAngleX * sinAngleZ;
  final a23 = /* cosAngleX * sinAngleY * sinAngleZ*/ -sinAngleX; // * cosAngleZ;
  final a33 = cosAngleX * cosAngleY;

  final transformedAxisZ = Perspective(a13, a23, a33);

  return transformedAxisZ.isOnAxisZ()
      ? 0.0
      : atan2(-transformedAxisZ.x, transformedAxisZ.y);
}
