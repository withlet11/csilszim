import 'package:csilszim/utilities/sexagesimal_angle.dart';
import 'package:test/test.dart';

void main() {
  test('test: DmsAngle - positive', () {
    const object = DmsAngle(false, 11, 00, 00);
    expect(object.toDmsWithoutSign(), '11°00′00″');
    expect(object.toDmsWithSign(), '+11°00′00″');
    expect(object.toDmsWithNS(), '11°00′00″ N');
    expect(object.toDmsWithEW(), '11°00′00″ E');
    expect(object.toDegrees(), 11);
  });

  test('test: DmsAngle - negative', () {
    const object = DmsAngle(true, 11, 00, 00);
    expect(object.toDmsWithoutSign(), '349°00′00″');
    expect(object.toDmsWithSign(), '-11°00′00″');
    expect(object.toDmsWithNS(), '11°00′00″ S');
    expect(object.toDmsWithEW(), '11°00′00″ W');
    expect(object.toDegrees(), -11);
  });

  test('test: DmsAngle - positive', () {
    const object = DmsAngle(false, 12, 30, 30);
    expect(object.toDmsWithoutSign(), '12°30′30″');
    expect(object.toDmsWithSign(), '+12°30′30″');
    expect(object.toDmsWithNS(), '12°30′30″ N');
    expect(object.toDmsWithEW(), '12°30′30″ E');
    expect(object.toDegrees(), 12 + (30 + 30 / 60) / 60);
  });

  test('test: DmsAngle - negative', () {
    const object = DmsAngle(true, 12, 30, 30);
    expect(object.toDmsWithoutSign(), '347°29′30″');
    expect(object.toDmsWithSign(), '-12°30′30″');
    expect(object.toDmsWithNS(), '12°30′30″ S');
    expect(object.toDmsWithEW(), '12°30′30″ W');
    expect(object.toDegrees(), -12 - (30 + 30 / 60) / 60);
  });

  test('test: DmsAngle - positive', () {
    const object = DmsAngle(false, 0, 30, 30);
    expect(object.toDmsWithoutSign(), '0°30′30″');
    expect(object.toDmsWithSign(), '+00°30′30″');
    expect(object.toDmsWithNS(), '0°30′30″ N');
    expect(object.toDmsWithEW(), '0°30′30″ E');
    expect(object.toDegrees(), (30 + 30 / 60) / 60);
  });

  test('test: DmsAngle - negative', () {
    const object = DmsAngle(true, 0, 30, 30);
    expect(object.toDmsWithoutSign(), '359°29′30″');
    expect(object.toDmsWithSign(), '-00°30′30″');
    expect(object.toDmsWithNS(), '0°30′30″ S');
    expect(object.toDmsWithEW(), '0°30′30″ W');
    expect(object.toDegrees(), -(30 + 30 / 60) / 60);
  });

  test('test: HmsAngle', () {
    const object = HmsAngle(12, 30, 30);
    expect(object.toHms(), '12h30m30s');
  });
}
