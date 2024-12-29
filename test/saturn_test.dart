import 'package:csilszim/astronomical/astronomical_object/planet.dart';
import 'package:csilszim/astronomical/time_model.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  final start = DateTime(2009, 9, 5, 12);
  final time = TimeModel.fromLocalTime(start);
  final earth = PlanetEarth();
  earth.forceUpdateWithVsop87(time.jd, Vector3.zero());
  for (int i = 0; i < 30; ++i) {
    final time = TimeModel.fromLocalTime(
        start.add(const Duration(/*days: 365, hours: 6*/hours: 1) * i));
    earth.forceUpdateWithVsop87(time.jd, Vector3.zero());
    final saturn = PlanetSaturn();
    saturn.forceUpdateWithVsop87(time.jd, earth.heliocentric!);
    // print("year: ${earth.jd}, ring: ${saturn.saturnRingAngle()}");
    // print("x: ${saturn.heliocentric!.x}, y: ${saturn.heliocentric!.y}, z: ${saturn.heliocentric!.z}");
    // print("dec: ${saturn.equatorial.dec * radInDeg}, ra: ${saturn.equatorial.ra * radInHour}");
  }
  test('test: Vector3, constructor', () {
    expect(1, 1);
    expect(0, 0);
  });
}