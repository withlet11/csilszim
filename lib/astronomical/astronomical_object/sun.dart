/*
 * sun.dart
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

import 'package:csilszim/astronomical/astronomical_object/astronomical_object.dart';

import '../../utilities/offset_3d.dart';
import '../coordinate_system/ecliptic_coordinate.dart';
import '../coordinate_system/equatorial_coordinate.dart';
import 'celestial_id.dart';

class Sun implements AstronomicalObject {
  static const name = 'Sun';
  static const id = CelestialId.sun;
  var jd = 0.0;
  static const magnitude = -26.74;

  @override
  var heliocentric = Offset3D.zero;
  @override
  var geocentric = Offset3D.zero;

  void update(double jd, Offset3D earthPosition) {
    this.jd = jd;
    geocentric = -earthPosition;
  }

  @override
  Equatorial get equatorial {
    final ecliptic = Ecliptic.fromXyz(geocentric!);
    return ecliptic.toEquatorial();
  }
}
