import 'package:csilszim/astronomical/astronomical_object/planet.dart';
import 'package:csilszim/astronomical/orbit_calculation/vsop87/earth.dart';
import 'package:csilszim/astronomical/orbit_calculation/vsop87/saturn.dart';
import 'package:csilszim/astronomical/time_model.dart';
import 'package:csilszim/constants.dart';
import 'package:csilszim/utilities/offset_3d.dart';
import 'package:test/test.dart';

void main() {
  final start = DateTime(2009, 9, 5, 12);
  final time = TimeModel.fromLocalTime(start);
  final earth = Vsop87Earth(time.jd, const Offset3D(0, 0, 0));
  for (int i = 0; i < 30; ++i) {
    final time = TimeModel.fromLocalTime(
        start.add(const Duration(/*days: 365, hours: 6*/hours: 1) * i));
    earth.forceUpdate(time.jd, const Offset3D(0, 0, 0));
    final saturn = Vsop87Saturn(time.jd, earth.heliocentric);
    final geocentric = saturn.geocentric;
    print("year: ${earth.jd}, ring: ${saturnRingAngle(geocentric)}");
    print("x: ${saturn.heliocentric.dx}, y: ${saturn.heliocentric.dy}, z: ${saturn.heliocentric.dz}");
    print("dec: ${saturn.toEquatorial().dec * radInDeg}, ra: ${saturn.toEquatorial().ra * radInHour}");
  }
  test('test: Offset3D, constructor', () {
    expect(1, 1);
    expect(0, 0);
  });
}