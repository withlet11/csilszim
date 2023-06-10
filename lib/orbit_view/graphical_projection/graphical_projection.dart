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

import 'package:vector_math/vector_math_64.dart';

import 'perspective.dart';

class GraphicalProjection {
  final Vector3 cameraPosition;
  final double distance;
  final double angleX, angleY, angleZ;
  final Matrix4 matrix;

  GraphicalProjection._internal(this.cameraPosition, this.distance, this.angleX,
      this.angleY, this.angleZ, this.matrix);

  factory GraphicalProjection(Vector3 cameraPosition, [double angleZ = 0]) {
    final directionOfAxisZ = _directionOfAxisZOnPerspective(cameraPosition);

    final x = -cameraPosition.x;
    final y = -cameraPosition.y;
    final z = -cameraPosition.z;

    final angleX = atan2(y, z);
    final angleY = atan2(-x, y * sin(angleX) + z * cos(angleX));

    final matrix = Matrix4.rotationZ(angleZ - directionOfAxisZ)
      ..rotateY(angleY)
      ..rotateX(angleX);

    return GraphicalProjection._internal(cameraPosition,
        sqrt(x * x + y * y + z * z), angleX, angleY, angleZ, matrix);
  }

  Perspective transform(Vector3 offset) {
    final moved = offset - cameraPosition;
    return Perspective(matrix.transformed3(moved));
  }
}

/// Calculates the direction of axis Z after transformation to perspective
/// from camera position.
double _directionOfAxisZOnPerspective(Vector3 cameraPosition) {
  final x = -cameraPosition.x;
  final y = -cameraPosition.y;
  final z = -cameraPosition.z;

  final angleX = atan2(y, z);
  final angleY = atan2(-x, y * sin(angleX) + z * cos(angleX));
  // const angleZ = 0; // no rotation around axis-Z

  final ez = Vector3(0, 0, 1); // unit vector along the z-axis
  final matrix = Matrix4.rotationY(angleY)..rotateX(angleX);
  matrix.transform3(ez);

  return (ez.x == 0 && ez.y == 0) ? 0.0 : atan2(-ez.x, ez.y);
}
