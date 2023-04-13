import 'package:csilszim/astronomical/astronomical_object/planet.dart';
import 'package:csilszim/astronomical/time_model.dart';
import 'package:csilszim/constants.dart';
import 'package:csilszim/utilities/offset_3d.dart';
import 'package:test/test.dart';

void main() {
  final start = DateTime(2009, 9, 5, 12);
  final time = TimeModel.fromLocalTime(start);
  final earth = PlanetEarth();
  earth.forceUpdateWithVsop87(time.jd, Offset3D.zero);
  for (int i = 0; i < 30; ++i) {
    final time = TimeModel.fromLocalTime(
        start.add(const Duration(/*days: 365, hours: 6*/hours: 1) * i));
    earth.forceUpdateWithVsop87(time.jd, Offset3D.zero);
    final saturn = PlanetSaturn();
    saturn.forceUpdateWithVsop87(time.jd, earth.heliocentric!);
    print("year: ${earth.jd}, ring: ${saturn.saturnRingAngle()}");
    print("x: ${saturn.heliocentric!.dx}, y: ${saturn.heliocentric!.dy}, z: ${saturn.heliocentric!.dz}");
    print("dec: ${saturn.equatorial.dec * radInDeg}, ra: ${saturn.equatorial.ra * radInHour}");
  }
  test('test: Offset3D, constructor', () {
    expect(1, 1);
    expect(0, 0);
  });
}