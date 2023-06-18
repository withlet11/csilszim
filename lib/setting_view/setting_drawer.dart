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
import '../constants.dart';
import '../orbit_view/orbit_view_setting_provider.dart';
import '../provider/language_select_provider.dart';
import '../momentary_sky_view/momentary_sky_view_setting_provider.dart';
import '../provider/base_settings_provider.dart';
import '../provider/view_select_provider.dart' as csilszim;
import '../whole_night_sky_view/configs.dart';
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
    final baseSettings = ref.watch(baseSettingsProvider);
    final displaySetting = ref.watch(momentarySkyViewSettingProvider);
    final momentarySkyViewSetting = ref.watch(momentarySkyViewSettingProvider);
    final wholeNightSkyViewSetting =
        ref.watch(wholeNightSkyViewSettingProvider);
    final orbitViewSetting = ref.watch(orbitViewSettingProvider);
    final viewSelect = ref.watch(csilszim.viewSelectProvider);
    final languageSelect = ref.watch(languageSelectProvider);
    final appLocalization = AppLocalizations.of(context)!;
    final viewList = {
      appLocalization.clock: csilszim.View.clock,
      appLocalization.momentarySkyView: csilszim.View.momentary,
      appLocalization.wholeNightSkyView: csilszim.View.wholeNight,
      appLocalization.orbit: csilszim.View.orbit,
      appLocalization.objectList: csilszim.View.objectList
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language),
                  DropdownButtonHideUnderline(
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.my_location),
                  Column(
                    children: [
                      Text(
                          '${appLocalization.latitude} ${baseSettings.lat.toDmsWithNS()}'),
                      Text(
                          '${appLocalization.longitude} ${baseSettings.long.toDmsWithEW()}'),
                    ],
                  )
                ],
              ),
            ],
          )),
          for (final entry in viewList.entries)
            RadioListTile<csilszim.View>(
              title: Text(entry.key),
              value: entry.value,
              groupValue: viewSelect,
              onChanged: (csilszim.View? value) {
                if (value != null) {
                  ref.read(csilszim.viewSelectProvider.notifier).state = value;
                }
              },
            ),
          const Divider(),
          if (viewSelect == csilszim.View.momentary)
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
          if (viewSelect == csilszim.View.momentary)
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
          if (viewSelect == csilszim.View.momentary)
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
          if (viewSelect == csilszim.View.momentary)
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
          if (viewSelect == csilszim.View.momentary)
            SwitchListTile(
              title: Text(appLocalization.messierObjects),
              value: momentarySkyViewSetting.isMessierObjectVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(momentarySkyViewSettingProvider.notifier)
                        .messierObjectVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == csilszim.View.momentary)
            SwitchListTile(
              title: Text('${appLocalization.fov} '
                  '(${momentarySkyViewSetting.trueFov.toStringAsFixed(1)}$degSign)'),
              value: momentarySkyViewSetting.isFovVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(momentarySkyViewSettingProvider.notifier)
                        .fovVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == csilszim.View.momentary)
            ListTile(
              title: Slider(
                label: momentarySkyViewSetting.trueFov.toStringAsFixed(1),
                min: minimumTfov,
                max: maximumTfov,
                value: momentarySkyViewSetting.trueFov,
                onChanged: momentarySkyViewSetting.isFovVisible
                    ? (double? value) {
                        setState(() {
                          if (value != null) {
                            ref
                                .read(momentarySkyViewSettingProvider.notifier)
                                .trueFov = value;
                          }
                        });
                      }
                    : null,
              ),
            ),
          if (viewSelect == csilszim.View.wholeNight)
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
          if (viewSelect == csilszim.View.wholeNight)
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
          if (viewSelect == csilszim.View.wholeNight)
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
          if (viewSelect == csilszim.View.wholeNight)
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
          if (viewSelect == csilszim.View.wholeNight)
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
          if (viewSelect == csilszim.View.wholeNight)
            SwitchListTile(
              title: Text('${appLocalization.fov} '
                  '(${wholeNightSkyViewSetting.trueFov.toStringAsFixed(1)}$degSign)'),
              value: wholeNightSkyViewSetting.isFovVisible,
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    ref
                        .read(wholeNightSkyViewSettingProvider.notifier)
                        .fovVisibility = value;
                  }
                });
              },
            ),
          if (viewSelect == csilszim.View.wholeNight)
            ListTile(
              title: Slider(
                label: wholeNightSkyViewSetting.trueFov.toStringAsFixed(1),
                min: minimumTfov,
                max: maximumTfov,
                value: wholeNightSkyViewSetting.trueFov,
                onChanged: wholeNightSkyViewSetting.isFovVisible
                    ? (double? value) {
                        setState(() {
                          if (value != null) {
                            ref
                                .read(wholeNightSkyViewSettingProvider.notifier)
                                .trueFov = value;
                          }
                        });
                      }
                    : null,
              ),
            ),
          if (viewSelect == csilszim.View.orbit)
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
          if (viewSelect == csilszim.View.orbit)
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
          if (viewSelect == csilszim.View.orbit)
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
          const Divider(),
          ListTile(
            title: TextButton(
              child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Licenses', textAlign: TextAlign.left)),
              onPressed: () => showLicensePage(
                  context: context,
                  applicationIcon: Image.asset('assets/images/icon.png',
                      height: 64.0, width: 64.0),
                  applicationName: appName,
                  applicationVersion: applicationVersion,
                  applicationLegalese: applicationLegalese),
            ),
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
