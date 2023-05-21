/*
 * orbit_view_setting_provider.dart
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

class OrbitViewSettingProvider extends StateNotifier<OrbitViewSettings> {
  OrbitViewSettingProvider() : super(const OrbitViewSettings());

  set mercuryVisibility(bool visibility) {
    state = state.copyWith(isMercuryVisible: visibility);
  }

  set venusVisibility(bool visibility) {
    state = state.copyWith(isVenusVisible: visibility);
  }

  set earthVisibility(bool visibility) {
    state = state.copyWith(isEarthVisible: visibility);
  }

  set marsVisibility(bool visibility) {
    state = state.copyWith(isMarsVisible: visibility);
  }

  set jupiterVisibility(bool visibility) {
    state = state.copyWith(isJupiterVisible: visibility);
  }

  set saturnVisibility(bool visibility) {
    state = state.copyWith(isSaturnVisible: visibility);
  }

  set uranusVisibility(bool visibility) {
    state = state.copyWith(isUranusVisible: visibility);
  }

  set neptuneVisibility(bool visibility) {
    state = state.copyWith(isNeptuneVisible: visibility);
  }

  set ceresVisibility(bool visibility) {
    state = state.copyWith(isCeresVisible: visibility);
  }

  set plutoVisibility(bool visibility) {
    state = state.copyWith(isPlutoVisible: visibility);
  }

  set erisVisibility(bool visibility) {
    state = state.copyWith(isErisVisible: visibility);
  }

  set haumeaVisibility(bool visibility) {
    state = state.copyWith(isHaumeaVisible: visibility);
  }

  set makemakeVisibility(bool visibility) {
    state = state.copyWith(isMakemakeVisible: visibility);
  }

  set halleyVisibility(bool visibility) {
    state = state.copyWith(isHalleyVisible: visibility);
  }

  set enckeVisibility(bool visibility) {
    state = state.copyWith(isEnckeVisible: visibility);
  }

  set fayeVisibility(bool visibility) {
    state = state.copyWith(isFayeVisible: visibility);
  }

  set dArrestVisibility(bool visibility) {
    state = state.copyWith(isDArrestVisible: visibility);
  }

  set ponsWinneckeVisibility(bool visibility) {
    state = state.copyWith(isPonsWinneckeVisible: visibility);
  }

  set tuttleVisibility(bool visibility) {
    state = state.copyWith(isTuttleVisible: visibility);
  }

  set tempel1Visibility(bool visibility) {
    state = state.copyWith(isTempel1Visible: visibility);
  }

  set tempel2Visibility(bool visibility) {
    state = state.copyWith(isTempel2Visible: visibility);
  }
}

@immutable
class OrbitViewSettings {
  final bool isMercuryVisible;
  final bool isVenusVisible;
  final bool isEarthVisible;
  final bool isMarsVisible;
  final bool isJupiterVisible;
  final bool isSaturnVisible;
  final bool isUranusVisible;
  final bool isNeptuneVisible;
  final bool isCeresVisible;
  final bool isPlutoVisible;
  final bool isErisVisible;
  final bool isHaumeaVisible;
  final bool isMakemakeVisible;
  final bool isHalleyVisible;
  final bool isEnckeVisible;
  final bool isFayeVisible;
  final bool isDArrestVisible;
  final bool isPonsWinneckeVisible;
  final bool isTuttleVisible;
  final bool isTempel1Visible;
  final bool isTempel2Visible;

  const OrbitViewSettings({
    this.isMercuryVisible = true,
    this.isVenusVisible = true,
    this.isEarthVisible = true,
    this.isMarsVisible = true,
    this.isJupiterVisible = true,
    this.isSaturnVisible = true,
    this.isUranusVisible = true,
    this.isNeptuneVisible = true,
    this.isCeresVisible = false,
    this.isPlutoVisible = false,
    this.isErisVisible = false,
    this.isHaumeaVisible = false,
    this.isMakemakeVisible = false,
    this.isHalleyVisible = false,
    this.isEnckeVisible = false,
    this.isFayeVisible = false,
    this.isDArrestVisible = false,
    this.isPonsWinneckeVisible = false,
    this.isTuttleVisible = false,
    this.isTempel1Visible = false,
    this.isTempel2Visible = false,
  });

  OrbitViewSettings copyWith({
    bool? isMercuryVisible,
    bool? isVenusVisible,
    bool? isEarthVisible,
    bool? isMarsVisible,
    bool? isJupiterVisible,
    bool? isSaturnVisible,
    bool? isUranusVisible,
    bool? isNeptuneVisible,
    bool? isCeresVisible,
    bool? isPlutoVisible,
    bool? isErisVisible,
    bool? isHaumeaVisible,
    bool? isMakemakeVisible,
    bool? isHalleyVisible,
    bool? isEnckeVisible,
    bool? isFayeVisible,
    bool? isDArrestVisible,
    bool? isPonsWinneckeVisible,
    bool? isTuttleVisible,
    bool? isTempel1Visible,
    bool? isTempel2Visible,
  }) =>
      OrbitViewSettings(
        isMercuryVisible: isMercuryVisible ?? this.isMercuryVisible,
        isVenusVisible: isVenusVisible ?? this.isVenusVisible,
        isEarthVisible: isEarthVisible ?? this.isEarthVisible,
        isMarsVisible: isMarsVisible ?? this.isMarsVisible,
        isJupiterVisible: isJupiterVisible ?? this.isJupiterVisible,
        isSaturnVisible: isSaturnVisible ?? this.isSaturnVisible,
        isUranusVisible: isUranusVisible ?? this.isUranusVisible,
        isNeptuneVisible: isNeptuneVisible ?? this.isNeptuneVisible,
        isCeresVisible: isCeresVisible ?? this.isCeresVisible,
        isPlutoVisible: isPlutoVisible ?? this.isPlutoVisible,
        isErisVisible: isErisVisible ?? this.isErisVisible,
        isHaumeaVisible: isHaumeaVisible ?? this.isHaumeaVisible,
        isMakemakeVisible: isMakemakeVisible ?? this.isMakemakeVisible,
        isHalleyVisible: isHalleyVisible ?? this.isHalleyVisible,
        isEnckeVisible: isEnckeVisible ?? this.isEnckeVisible,
        isFayeVisible: isFayeVisible ?? this.isFayeVisible,
        isDArrestVisible: isDArrestVisible ?? this.isDArrestVisible,
        isPonsWinneckeVisible: isPonsWinneckeVisible ?? this.isPonsWinneckeVisible,
        isTuttleVisible: isTuttleVisible ?? this.isTuttleVisible,
        isTempel1Visible: isTempel1Visible ?? this.isTempel1Visible,
        isTempel2Visible: isTempel2Visible ?? this.isTempel2Visible,
      );
}

final orbitViewSettingProvider =
    StateNotifierProvider<OrbitViewSettingProvider, OrbitViewSettings>((ref) {
  return OrbitViewSettingProvider();
});
