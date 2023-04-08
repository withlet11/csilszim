/*
 * whole_night_sky_view_setting_provider.dart
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'configs.dart';

class WholeNightSkyViewSettingProvider
    extends StateNotifier<WholeNightSkyViewSettings> {
  WholeNightSkyViewSettingProvider() : super(const WholeNightSkyViewSettings());

  set equatorialGridVisibility(bool visibility) {
    state = state.copyWith(isEquatorialGridVisible: visibility);
  }

  set constellationLineVisibility(bool visibility) {
    state = state.copyWith(isConstellationLineVisible: visibility);
  }

  set constellationNameVisibility(bool visibility) {
    state = state.copyWith(isConstellationNameVisible: visibility);
  }

  set planetVisibility(bool visibility) {
    state = state.copyWith(isPlanetVisible: visibility);
  }

  set messierObjectVisibility(bool visibility) {
    state = state.copyWith(isMessierObjectVisible: visibility);
  }

  set fovVisibility(bool visibility) {
    state = state.copyWith(isFovVisible: visibility);
  }

  set tfov(double angle) {
    state = state.copyWith(tfov: angle);
  }
}

@immutable
class WholeNightSkyViewSettings {
  final bool isEquatorialGridVisible;
  final bool isConstellationLineVisible;
  final bool isConstellationNameVisible;
  final bool isPlanetVisible;
  final bool isMessierObjectVisible;
  final bool isFovVisible;
  final double tfov;

  const WholeNightSkyViewSettings({
    this.isEquatorialGridVisible = true,
    this.isConstellationLineVisible = true,
    this.isConstellationNameVisible = false,
    this.isPlanetVisible = true,
    this.isMessierObjectVisible = true,
    this.isFovVisible = true,
    this.tfov = defaultTfov,
  });

  WholeNightSkyViewSettings copyWith({
    bool? isEquatorialGridVisible,
    bool? isConstellationLineVisible,
    bool? isConstellationNameVisible,
    bool? isPlanetVisible,
    bool? isMessierObjectVisible,
    bool? isFovVisible,
    double? tfov,
  }) =>
      WholeNightSkyViewSettings(
        isEquatorialGridVisible:
            isEquatorialGridVisible ?? this.isEquatorialGridVisible,
        isConstellationLineVisible:
            isConstellationLineVisible ?? this.isConstellationLineVisible,
        isConstellationNameVisible:
            isConstellationNameVisible ?? this.isConstellationNameVisible,
        isPlanetVisible: isPlanetVisible ?? this.isPlanetVisible,
        isMessierObjectVisible:
            isMessierObjectVisible ?? this.isMessierObjectVisible,
        isFovVisible: isFovVisible ?? this.isFovVisible,
        tfov: tfov ?? this.tfov,
      );
}

final wholeNightSkyViewSettingProvider = StateNotifierProvider<
    WholeNightSkyViewSettingProvider, WholeNightSkyViewSettings>((ref) {
  return WholeNightSkyViewSettingProvider();
});
