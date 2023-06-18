/*
 * base_settings_provider.dart
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../astronomical/coordinate_system/geographic_coordinate.dart';
import '../configs.dart';
import '../utilities/sexagesimal_angle.dart';

enum MapOrientation {
  southUp,
  auto,
  northUp,
}

class BaseSettings {
  final DmsAngle lat;
  final DmsAngle long;
  final double height;
  final MapOrientation mapOrientation;

  const BaseSettings({
    required this.lat,
    required this.long,
    this.height = 0.0,
    this.mapOrientation = MapOrientation.auto,
  });

  Geographic toGeographic() => Geographic.fromDegrees(
      lat: lat.toDegrees(), long: long.toDegrees(), h: height);
}

class BaseSettingsProvider extends StateNotifier<BaseSettings> {
  BaseSettingsProvider(
      [BaseSettings baseSettings = const BaseSettings(
          lat: DmsAngle(
              defaultLatNeg, defaultLatDeg, defaultLatMin, defaultLatSec),
          long: DmsAngle(
              defaultLongNeg, defaultLongDeg, defaultLongMin, defaultLongSec))])
      : super(baseSettings);

  void setLocation({lat = DmsAngle, long = DmsAngle}) {
    state = BaseSettings(lat: lat.toDegrees(), long: long.toDegrees());
  }

  void set(BaseSettings baseSettings) {
    state = baseSettings;
  }
}

final baseSettingsProvider =
    StateNotifierProvider<BaseSettingsProvider, BaseSettings>((ref) {
  return BaseSettingsProvider();
});
