/*
 * setting_drawer.dart
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../configs.dart';
import '../orbit_view/orbitViewSettingProvider.dart';
import '../provider/language_select_provider.dart';
import '../momentary_sky_view/momentary_sky_view_setting_provider.dart';
import '../provider/view_select_provider.dart';
import '../whole_night_sky_view/whole_night_sky_view_setting_provider.dart';
import '../utilities/language_selection.dart';

const _keyLang = 'lang';

/// A widget of page for setting the observation location.
class SettingDrawer extends ConsumerStatefulWidget {
  const SettingDrawer({super.key});

  @override
  ConsumerState<SettingDrawer> createState() => _SettingDrawerState();
}

class _SettingDrawerState extends ConsumerState<SettingDrawer> {
  @override
  Widget build(BuildContext context) {
    final displaySetting = ref.watch(momentarySkyViewSettingProvider);
    final wholeNightSkyViewSetting =
        ref.watch(wholeNightSkyViewSettingProvider);
    final orbitViewSetting = ref.watch(orbitViewSettingProvider);
    final viewSelect = ref.watch(viewSelectProvider);
    final languageSelect = ref.watch(languageSelectProvider);
    final appLocalization = AppLocalizations.of(context)!;
    final viewList = {
      appLocalization.clock: View.clock,
      appLocalization.momentarySkyView: View.momentary,
      appLocalization.wholeNightSkyView: View.wholeNight,
      appLocalization.orbit: View.orbit,
      appLocalization.objectList: View.objectList
    };
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Column(
            children: [
              const Text(appName, style: TextStyle(fontSize: 24.0)),
              Text(appLocalization.shortIntroduction,
                  style: const TextStyle(fontSize: 12.0)),
              Theme(
                data: Theme.of(context).copyWith(canvasColor: null),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        items: [
                      for (final e in LanguageSelection().languageMap.entries)
                        DropdownMenuItem<String>(
                            value: e.key, child: Text(e.value)),
                    ],
                        onChanged: (String? value) {
                          if (value != null) {
                            ref.read(languageSelectProvider.notifier).state =
                                Locale(value);
                            saveLanguageData(value);
                          }
                        },
                        value: languageSelect.languageCode)),
              )
            ],
          )),
          for (final entry in viewList.entries)
            RadioListTile<View>(
              title: Text(entry.key),
              value: entry.value,
              groupValue: viewSelect,
              onChanged: (View? value) {
                if (value != null) {
                  ref.read(viewSelectProvider.notifier).state = value;
                }
              },
            ),
          const Divider(),
          if (viewSelect == View.momentary)
            SwitchListTile(
              title: Text(appLocalization.azimuthalGrid),
              value: displaySetting.isHorizontalGridVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(momentarySkyViewSettingProvider.notifier)
                        .horizontalGridVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.momentary)
            SwitchListTile(
              title: Text(appLocalization.equatorialGrid),
              value: displaySetting.isEquatorialGridVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(momentarySkyViewSettingProvider.notifier)
                        .equatorialGridVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.momentary)
            SwitchListTile(
              title: Text(appLocalization.constellationLines),
              value: displaySetting.isConstellationLineVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(momentarySkyViewSettingProvider.notifier)
                        .constellationLineVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.momentary)
            SwitchListTile(
              title: Text(appLocalization.constellationLabels),
              value: displaySetting.isConstellationNameVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(momentarySkyViewSettingProvider.notifier)
                        .constellationNameVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.wholeNight)
            SwitchListTile(
              title: Text(appLocalization.equatorialGrid),
              value: wholeNightSkyViewSetting.isEquatorialGridVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(wholeNightSkyViewSettingProvider.notifier)
                        .equatorialGridVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.wholeNight)
            SwitchListTile(
              title: Text(appLocalization.constellationLines),
              value: wholeNightSkyViewSetting.isConstellationLineVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(wholeNightSkyViewSettingProvider.notifier)
                        .constellationLineVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.wholeNight)
            SwitchListTile(
              title: Text(appLocalization.constellationLabels),
              value: wholeNightSkyViewSetting.isConstellationNameVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(wholeNightSkyViewSettingProvider.notifier)
                        .constellationNameVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.wholeNight)
            SwitchListTile(
              title: Text(appLocalization.planets),
              value: wholeNightSkyViewSetting.isPlanetVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(wholeNightSkyViewSettingProvider.notifier)
                        .planetVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.wholeNight)
            SwitchListTile(
              title: Text(appLocalization.messierObjects),
              value: wholeNightSkyViewSetting.isMessierObjectVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(wholeNightSkyViewSettingProvider.notifier)
                        .messierObjectVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == View.orbit)
            ExpansionTile(
              title: Text(appLocalization.planets),
              children: [
                CheckboxListTile(
                  title: Text(appLocalization.mercury),
                  value: orbitViewSetting.isMercuryVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .mercuryVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.venus),
                  value: orbitViewSetting.isVenusVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .venusVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.earth),
                  value: orbitViewSetting.isEarthVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .earthVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.mars),
                  value: orbitViewSetting.isMarsVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .marsVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.jupiter),
                  value: orbitViewSetting.isJupiterVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .jupiterVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.saturn),
                  value: orbitViewSetting.isSaturnVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .saturnVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.uranus),
                  value: orbitViewSetting.isUranusVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .uranusVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.neptune),
                  value: orbitViewSetting.isNeptuneVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .neptuneVisibility = value;
                      }
                    });
                  },
                ),
              ],
            ),
          if (viewSelect == View.orbit)
            ExpansionTile(
              title: Text(appLocalization.dwarfPlanets),
              children: [
                CheckboxListTile(
                  title: Text(appLocalization.ceres),
                  value: orbitViewSetting.isCeresVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .ceresVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.pluto),
                  value: orbitViewSetting.isPlutoVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .plutoVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.eris),
                  value: orbitViewSetting.isErisVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .erisVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.haumea),
                  value: orbitViewSetting.isHaumeaVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .haumeaVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.makemake),
                  value: orbitViewSetting.isMakemakeVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .makemakeVisibility = value;
                      }
                    });
                  },
                ),
              ],
            ),
          if (viewSelect == View.orbit)
            ExpansionTile(
              title: Text(appLocalization.comets),
              children: [
                CheckboxListTile(
                  title: Text(appLocalization.halley),
                  value: orbitViewSetting.isHalleyVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .halleyVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.encke),
                  value: orbitViewSetting.isEnckeVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .enckeVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.faye),
                  value: orbitViewSetting.isFayeVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .fayeVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.dArrest),
                  value: orbitViewSetting.isDArrestVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .dArrestVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.ponsWinnecke),
                  value: orbitViewSetting.isPonsWinneckeVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .ponsWinneckeVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.tuttle),
                  value: orbitViewSetting.isTuttleVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .tuttleVisibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.tempel1),
                  value: orbitViewSetting.isTempel1Visible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .tempel1Visibility = value;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(appLocalization.tempel2),
                  value: orbitViewSetting.isTempel2Visible,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        ref
                            .read(orbitViewSettingProvider.notifier)
                            .tempel2Visibility = value;
                      }
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  void saveLanguageData(String language) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyLang, language);
  }
}
