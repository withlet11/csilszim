import 'dart:math';

import 'package:csilszim/orbit_view/graphical_projection/graphical_projection.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  const double x1 = 1.5;
  const double y1 = 2.8;
  const double z1 = 9.5;
  final object1 = Vector3(x1, y1, z1);

  const double x2 = -3.5;
  const double y2 = -50;
  const double z2 = -100.2;
  final object2 = Vector3(x2, y2, z2);

  double direction1 = pi / 6;
  double direction2 = pi / 4;
  const double distance = 2;
  // final object3 = Vector3.fromDirection(direction1, direction2, distance);
  final object3 = Vector3(cos(direction1) * cos(direction2), sin(direction1) * cos(direction2), sin(direction2)) * distance;

  test('test: Vector3, constructor', () {
    expect(object1.x, x1);
    expect(object1.y, y1);
    expect(object1.z, z1);
    expect(object2.x, x2);
    expect(object2.y, y2);
    expect(object2.z, z2);
    expect((object3.x).toStringAsPrecision(14),
        (sqrt(3 / 2)).toStringAsPrecision(14));
    expect((object3.y).toStringAsPrecision(14),
        (sqrt(0.5)).toStringAsPrecision(14));
    expect(
        (object3.z).toStringAsPrecision(14), (sqrt(2)).toStringAsPrecision(14));
  });

  test('test: Vector3, addition, subtraction, multiplication, division', () {
    expect((object1 + object2).x, x1 + x2);
    expect((object1 + object2).y, y1 + y2);
    expect((object1 + object2).z, z1 + z2);
    expect((object1 - object2).x, x1 - x2);
    expect((object1 - object2).y, y1 - y2);
    expect((object1 - object2).z, z1 - z2);
    expect((object1 * 2.5).x, x1 * 2.5);
    expect((object1 * 2.5).y, y1 * 2.5);
    expect((object1 * 2.5).z, z1 * 2.5);
    expect((object1 / 3.3).x, x1 / 3.3);
    expect((object1 / 3.3).y, y1 / 3.3);
    expect((object1 / 3.3).z, z1 / 3.3);
  });

  test('test: Vector3, rotation1', () {
    final rotateXp03 = Matrix4.rotationX(0.3);
    final rotateYp04 = Matrix4.rotationY(0.4);
    final rotateZp05 = Matrix4.rotationZ(0.5);
    final rotateXn03 = Matrix4.rotationX(-0.3);
    final rotateYn04 = Matrix4.rotationY(-0.4);
    final rotateZn05 = Matrix4.rotationZ(-0.5);
    expect(rotateXp03.transformed3(object1).x, x1);
    expect(rotateXp03.transformed3(object1).y, y1 * cos(0.3) - z1 * sin(0.3));
    expect(rotateXp03.transformed3(object1).z, y1 * sin(0.3) + z1 * cos(0.3));
    expect(rotateYp04.transformed3(object1).x, z1 * sin(0.4) + x1 * cos(0.4));
    expect(rotateYp04.transformed3(object1).y, y1);
    expect(rotateYp04.transformed3(object1).z, z1 * cos(0.4) - x1 * sin(0.4));
    expect(rotateZp05.transformed3(object1).x, x1 * cos(0.5) - y1 * sin(0.5));
    expect(rotateZp05.transformed3(object1).y, x1 * sin(0.5) + y1 * cos(0.5));
    expect(rotateZp05.transformed3(object1).z, z1);
    expect(rotateXn03.transformed3(object2).x, x2);
    expect(rotateXn03.transformed3(object2).y, y2 * cos(-0.3) - z2 * sin(-0.3));
    expect(rotateXn03.transformed3(object2).z, y2 * sin(-0.3) + z2 * cos(-0.3));
    expect(rotateYn04.transformed3(object2).x, z2 * sin(-0.4) + x2 * cos(-0.4));
    expect(rotateYn04.transformed3(object2).y, y2);
    expect(rotateYn04.transformed3(object2).z, z2 * cos(-0.4) - x2 * sin(-0.4));
    expect(rotateZn05.transformed3(object2).x, x2 * cos(-0.5) - y2 * sin(-0.5));
    expect(rotateZn05.transformed3(object2).y, x2 * sin(-0.5) + y2 * cos(-0.5));
    expect(rotateZn05.transformed3(object2).z, z2);
  });

  final rotateXp03 = Matrix4.rotationX(0.3);
  final rotateYp04 = Matrix4.rotationY(0.4);
  final rotateZp05 = Matrix4.rotationZ(0.5);
  final rotateXYZ = Matrix4.rotationZ(0.5)..rotateY(0.4)..rotateX(0.3);
  final object4 = rotateZp05.transformed3(rotateYp04.transformed3(rotateXp03.transformed3(object1))) -
      rotateXYZ.transformed3(object1);

  test('test: Vector3, rotation2', () {
    expect((object4.x * 1e10).roundToDouble(), 0);
    expect((object4.y * 1e10).roundToDouble(), 0);
    expect((object4.z * 1e10).roundToDouble(), 0);
  });

  final projection1 = GraphicalProjection(Vector3(1, 1, 1));
  const angleX = -2.356194490192345;
  const angleY = 0.6154797087;
  test('test: ThreeDimensionsProjection', () {
    expect(projection1.distance, sqrt(3));
    expect(((projection1.angleX - angleX) * 1e10).roundToDouble(), 0);
    expect(((projection1.angleY - angleY) * 1e10).roundToDouble(), 0);
    expect(projection1.angleZ, 0);
  });
}
