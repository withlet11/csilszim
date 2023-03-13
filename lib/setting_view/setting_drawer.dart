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

import '../provider/language_select_provider.dart';
import '../provider/momentary_sky_view_setting_provider.dart';
import '../provider/view_select_provider.dart';
import '../provider/whole_night_sky_view_setting_provider.dart';
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
    final viewSelect = ref.watch(viewSelectProvider);
    final languageSelect = ref.watch(languageSelectProvider);
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              // decoration: BoxDecoration(
              // color: Theme.of(context).appBarTheme.backgroundColor),
              child: Column(
            children: [
              const Text('Csilszim', style: TextStyle(fontSize: 24.0)),
              Text(AppLocalizations.of(context)!.shortIntroduction,
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
          ListTile(
            title: Text(AppLocalizations.of(context)!.clock),
            tileColor: viewSelect == View.clock ? Colors.tealAccent : null,
            onTap: () {
              ref.read(viewSelectProvider.notifier).state = View.clock;
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.momentarySkyView),
            tileColor: viewSelect == View.momentary ? Colors.tealAccent : null,
            onTap: () {
              ref.read(viewSelectProvider.notifier).state = View.momentary;
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.wholeNightSkyView),
            tileColor: viewSelect == View.wholeNight ? Colors.tealAccent : null,
            onTap: () {
              ref.read(viewSelectProvider.notifier).state = View.wholeNight;
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.orbit),
            tileColor: viewSelect == View.orbit ? Colors.tealAccent : null,
            onTap: () {
              ref.read(viewSelectProvider.notifier).state = View.orbit;
              // Navigator.pop(context);
            },
          ),
          if (viewSelect == View.momentary)
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.azimuthalGrid),
              tileColor: Colors.teal,
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
              title: Text(AppLocalizations.of(context)!.equatorialGrid),
              tileColor: Colors.teal,
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
              title: Text(AppLocalizations.of(context)!.constellationLines),
              tileColor: Colors.teal,
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
              title: Text(AppLocalizations.of(context)!.constellationLabels),
              tileColor: Colors.teal,
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
              title: Text(AppLocalizations.of(context)!.equatorialGrid),
              tileColor: Colors.teal,
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
              title: Text(AppLocalizations.of(context)!.constellationLines),
              tileColor: Colors.teal,
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
              title: Text(AppLocalizations.of(context)!.constellationLabels),
              tileColor: Colors.teal,
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
        ],
      ),
    );
  }

  void saveLanguageData(String language) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyLang, language);
  }
}
