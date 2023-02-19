import 'dart:math';

import 'package:csilszim/orbit_view/graphical_projection/graphical_projection.dart';
import 'package:csilszim/utilities/offset_3d.dart';
import 'package:test/test.dart';

void main() {
  const double x1 = 1.5;
  const double y1 = 2.8;
  const double z1 = 9.5;
  const object1 = Offset3D(x1, y1, z1);

  const double x2 = -3.5;
  const double y2 = -50;
  const double z2 = -100.2;
  const object2 = Offset3D(x2, y2, z2);

  double direction1 = pi / 6;
  double direction2 = pi / 4;
  const double distance = 2;
  final object3 = Offset3D.fromDirection(direction1, direction2, distance);

  test('test: Offset3D, constructor', () {
    expect(object1.dx, x1);
    expect(object1.dy, y1);
    expect(object1.dz, z1);
    expect(object2.dx, x2);
    expect(object2.dy, y2);
    expect(object2.dz, z2);
    expect((object3.dx).toStringAsPrecision(14),
        (sqrt(3 / 2)).toStringAsPrecision(14));
    expect((object3.dy).toStringAsPrecision(14),
        (sqrt(0.5)).toStringAsPrecision(14));
    expect(
        (object3.dz).toStringAsPrecision(14), (sqrt(2)).toStringAsPrecision(14));
  });

  test('test: Offset3D, addition, subtraction, multiplication, division', () {
    expect((object1 + object2).dx, x1 + x2);
    expect((object1 + object2).dy, y1 + y2);
    expect((object1 + object2).dz, z1 + z2);
    expect((object1 - object2).dx, x1 - x2);
    expect((object1 - object2).dy, y1 - y2);
    expect((object1 - object2).dz, z1 - z2);
    expect((object1 * 2.5).dx, x1 * 2.5);
    expect((object1 * 2.5).dy, y1 * 2.5);
    expect((object1 * 2.5).dz, z1 * 2.5);
    expect((object1 / 3.3).dx, x1 / 3.3);
    expect((object1 / 3.3).dy, y1 / 3.3);
    expect((object1 / 3.3).dz, z1 / 3.3);
  });

  test('test: Offset3D, rotation1', () {
    expect((object1.rotateX(0.3)).dx, x1);
    expect((object1.rotateX(0.3)).dy, y1 * cos(0.3) - z1 * sin(0.3));
    expect((object1.rotateX(0.3)).dz, y1 * sin(0.3) + z1 * cos(0.3));
    expect((object1.rotateY(0.4)).dx, z1 * sin(0.4) + x1 * cos(0.4));
    expect((object1.rotateY(0.4)).dy, y1);
    expect((object1.rotateY(0.4)).dz, z1 * cos(0.4) - x1 * sin(0.4));
    expect((object1.rotateZ(0.5)).dx, x1 * cos(0.5) - y1 * sin(0.5));
    expect((object1.rotateZ(0.5)).dy, x1 * sin(0.5) + y1 * cos(0.5));
    expect((object1.rotateZ(0.5)).dz, z1);
    expect((object2.rotateX(-0.3)).dx, x2);
    expect((object2.rotateX(-0.3)).dy, y2 * cos(-0.3) - z2 * sin(-0.3));
    expect((object2.rotateX(-0.3)).dz, y2 * sin(-0.3) + z2 * cos(-0.3));
    expect((object2.rotateY(-0.4)).dx, z2 * sin(-0.4) + x2 * cos(-0.4));
    expect((object2.rotateY(-0.4)).dy, y2);
    expect((object2.rotateY(-0.4)).dz, z2 * cos(-0.4) - x2 * sin(-0.4));
    expect((object2.rotateZ(-0.5)).dx, x2 * cos(-0.5) - y2 * sin(-0.5));
    expect((object2.rotateZ(-0.5)).dy, x2 * sin(-0.5) + y2 * cos(-0.5));
    expect((object2.rotateZ(-0.5)).dz, z2);
  });

  final object4 = object1.rotateX(0.3).rotateY(0.4).rotateZ(0.5) -
      object1.rotateXYZ(0.3, 0.4, 0.5);

  test('test: Offset3D, rotation2', () {
    expect((object4.dx * 1e10).roundToDouble(), 0);
    expect((object4.dy * 1e10).roundToDouble(), 0);
    expect((object4.dz * 1e10).roundToDouble(), 0);
  });

  final projection1 = GraphicalProjection(const Offset3D(1, 1, 1));
  const angleX = -2.356194490192345;
  const angleY = 0.6154797087;
  test('test: ThreeDimensionsProjection', () {
    expect(projection1.distance, sqrt(3));
    expect(((projection1.angleX - angleX) * 1e10).roundToDouble(), 0);
    expect(((projection1.angleY - angleY) * 1e10).roundToDouble(), 0);
    expect(projection1.angleZ, 0);
  });
}
