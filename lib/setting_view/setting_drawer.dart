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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/display_setting_provider.dart';
import '../provider/view_select_provider.dart';

/// A widget of page for setting the observation location.
class SettingDrawer extends ConsumerStatefulWidget {
  const SettingDrawer({super.key});

  @override
  ConsumerState<SettingDrawer> createState() => _SettingDrawerState();
}

class _SettingDrawerState extends ConsumerState<SettingDrawer> {
  @override
  Widget build(BuildContext context) {
    final displaySetting = ref.watch(displaySettingProvider);
    final viewSelect = ref.watch(viewSelectProvider);
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor),
            child: const Text('Settings'),
          ),
          ListTile(
            title: const Text('Clock'),
            tileColor: viewSelect == View.clock ? Colors.tealAccent : null,
            onTap: () {
              ref.read(viewSelectProvider.notifier).state = View.clock;
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Sky'),
            tileColor: viewSelect == View.sky ? Colors.tealAccent : null,
            onTap: () {
              ref.read(viewSelectProvider.notifier).state = View.sky;
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Orbit'),
            tileColor: viewSelect == View.orbit ? Colors.tealAccent : null,
            onTap: () {
              ref.read(viewSelectProvider.notifier).state = View.orbit;
              Navigator.pop(context);
            },
          ),
          SwitchListTile(
            title: const Text('Horizontal coordinate grid'),
            value: displaySetting.isHorizontalGridVisible,
            onChanged: (bool? value) {
              setState(() {
                if (value != null) {
                  ref
                      .read(displaySettingProvider.notifier)
                      .horizontalGridVisibility = value;
                }
              });
            },
          ),
          SwitchListTile(
            title: const Text('Equatorial coordinate grid'),
            value: displaySetting.isEquatorialGridVisible,
            onChanged: (bool? value) {
              setState(() {
                if (value != null) {
                  ref
                      .read(displaySettingProvider.notifier)
                      .equatorialGridVisibility = value;
                }
              });
            },
          ),
          SwitchListTile(
            title: const Text('Constellation line'),
            value: displaySetting.isConstellationLineVisible,
            onChanged: (bool? value) {
              setState(() {
                if (value != null) {
                  ref
                      .read(displaySettingProvider.notifier)
                      .constellationLineVisibility = value;
                }
              });
            },
          ),
          SwitchListTile(
            title: const Text('Constellation name'),
            value: displaySetting.isConstellationNameVisible,
            onChanged: (bool? value) {
              setState(() {
                if (value != null) {
                  ref
                      .read(displaySettingProvider.notifier)
                      .constellationNameVisibility = value;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
