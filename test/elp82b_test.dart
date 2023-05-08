import 'package:csilszim/astronomical/orbit_calculation/elp82b2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test: 2047-10-17 PREC=0', () async {
    final elp82b2 = await Elp82b2.make(prec: 0);
    final result = elp82b2.calculate(2469000.5);
    expect(result.dx - -361602.98536 < 0.01, true);
    expect(result.dy - 44996.99510 < 0.01, true);
    expect(result.dz - -30696.65316 < 0.01, true);
  });

  test('test: 2047-10-17 PREC=4.85e-11″', () async {
    final elp82b2 = await Elp82b2.make(prec: 4.85e-11);
    final result = elp82b2.calculate(2469000.5);
    expect(result.dx - -361602.98481 < 0.01, true);
    expect(result.dy - 44996.99625 < 0.01, true);
    expect(result.dz - -30696.65152 < 0.01, true);
  });

  test('test: 1993-01-13 PREC=0', () async {
    final elp82b2 = await Elp82b2.make(prec: 0);
    final result = elp82b2.calculate(2449000.5);
    expect(result.dx - -363132.34248 < 0.01, true);
    expect(result.dy - 35863.65378 < 0.01, true);
    expect(result.dz - -33196.00409 < 0.01, true);
  });

  test('test: 1993-01-13 PREC=4.85e-11″', () async {
    final elp82b2 = await Elp82b2.make(prec: 4.85e-11);
    final result = elp82b2.calculate(2449000.5);
    expect(result.dx - -363132.34305 < 0.01, true);
    expect(result.dy - 35863.65187 < 0.01, true);
    expect(result.dz - -33196.00375 < 0.01, true);
  });

  test('test: 1938-04-12 PREC=0', () async {
    final elp82b2 = await Elp82b2.make(prec: 0);
    final result = elp82b2.calculate(2429000.5);
    expect(result.dx - -371577.58161 < 0.01, true);
    expect(result.dy - 75271.14315 < 0.01, true);
    expect(result.dz - -32227.94618 < 0.01, true);
  });

  test('test: 1938-04-12 PREC=4.85e-11″', () async {
    final elp82b2 = await Elp82b2.make(prec: 4.85e-11);
    final result = elp82b2.calculate(2429000.5);
    expect(result.dx - -371577.58019 < 0.01, true);
    expect(result.dy - 75271.14665 < 0.01, true);
    expect(result.dz - -32227.94680 < 0.01, true);
  });

  test('test: 1883-07-09 PREC=0', () async {
    final elp82b2 = await Elp82b2.make(prec: 0.0);
    final result = elp82b2.calculate(2409000.5);
    expect(result.dx - -373869.15893 < 0.01, true);
    expect(result.dy - 127406.79129 < 0.01, true);
    expect(result.dz - -30037.79225 < 0.01, true);
  });

  test('test: 1883-07-09 PREC=4.85e-11″', () async {
    final elp82b2 = await Elp82b2.make(prec: 4.85e-11);
    final result = elp82b2.calculate(2409000.5);
    expect(result.dx - -373896.15545 < 0.01, true);
    expect(result.dy - 127406.79153 < 0.01, true);
    expect(result.dz - -30037.79289 < 0.01, true);
  });

  test('test: 1828-10-05 PREC=0', () async {
    final elp82b2 = await Elp82b2.make(prec: 0.0);
    final result = elp82b2.calculate(2389000.5);
    expect(result.dx - -346331.77361 < 0.01, true);
    expect(result.dy - 206365.40364 < 0.01, true);
    expect(result.dz - -28502.11732 < 0.01, true);
  });

  test('test: 1828-10-05 PREC=4.85e-11″', () async {
    final elp82b2 = await Elp82b2.make(prec: 4.85e-11);
    final result = elp82b2.calculate(2389000.5);
    expect(result.dx - -346331.77862 < 0.01, true);
    expect(result.dy - 206365.40382 < 0.01, true);
    expect(result.dz - -28502.11773 < 0.01, true);
  });
}
