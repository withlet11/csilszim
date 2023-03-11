/*
 * seasonal_view_setting_provider.dart
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

class SeasonalViewSettingProvider extends StateNotifier<SeasonalViewSettings> {
  SeasonalViewSettingProvider() : super(const SeasonalViewSettings());

  set equatorialGridVisibility(bool visibility) {
    state = state.copyWith(isEquatorialGridVisible: visibility);
  }

  set constellationLineVisibility(bool visibility) {
    state = state.copyWith(isConstellationLineVisible: visibility);
  }

  set constellationNameVisibility(bool visibility) {
    state = state.copyWith(isConstellationNameVisible: visibility);
  }
}

@immutable
class SeasonalViewSettings {
  final bool isEquatorialGridVisible;
  final bool isConstellationLineVisible;
  final bool isConstellationNameVisible;

  const SeasonalViewSettings({
    this.isEquatorialGridVisible = true,
    this.isConstellationLineVisible = true,
    this.isConstellationNameVisible = false,
  });

  SeasonalViewSettings copyWith({
    bool? isEquatorialGridVisible,
    bool? isConstellationLineVisible,
    bool? isConstellationNameVisible,
  }) =>
      SeasonalViewSettings(
        isEquatorialGridVisible:
            isEquatorialGridVisible ?? this.isEquatorialGridVisible,
        isConstellationLineVisible:
            isConstellationLineVisible ?? this.isConstellationLineVisible,
        isConstellationNameVisible:
            isConstellationNameVisible ?? this.isConstellationNameVisible,
      );
}

final seasonalViewSettingProvider =
    StateNotifierProvider<SeasonalViewSettingProvider, SeasonalViewSettings>(
        (ref) {
  return SeasonalViewSettingProvider();
});
