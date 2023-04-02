/*
 * main.dart
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'astronomical/star_catalogue.dart';
import 'clock_view/clock_view.dart';
import 'configs.dart';
import 'momentary_sky_view/momentary_sky_view.dart';
import 'object_list_view/object_list_view.dart';
import 'orbit_view/orbit_view.dart';
import 'provider/language_select_provider.dart';
import 'provider/location_provider.dart';
import 'provider/view_select_provider.dart';
import 'setting_view/location_setting_view.dart';
import 'setting_view/setting_drawer.dart';
import 'utilities/language_selection.dart';
import 'utilities/sexagesimal_angle.dart';
import 'whole_night_sky_view/whole_night_sky_view.dart';

const _keyMomentarySkyView = 'key_MomentarySkyView';
const _keyOrbitView = 'key_OrbitView';
const _keyWholeNightSkyView = 'key_WholeNightSkyView';
const _keyIsSouth = 'isSouth';
const _keyLatDeg = 'latDeg';
const _keyLatMin = 'latMin';
const _keyLatSec = 'latSec';
const _keyLongNeg = 'longNeg';
const _keyLongDeg = 'longDeg';
const _keyLongMin = 'longMin';
const _keyLongSec = 'longSec';
const _keyLang = 'lang';
const _messageLoading = 'Loading...';
const _messageError = 'Error';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageSelectProvider);
    final languageSelection = LanguageSelection();
    final localeList = languageSelection.localeList();

    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,
      supportedLocales: localeList,
      theme: ThemeData(
        brightness: Brightness.dark,
        // primaryColor: Colors.lightBlue[800],
      ),
      debugShowCheckedModeBanner: false,
      title: appName,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<StarCatalogue> starCatalogue;

  @override
  void initState() {
    super.initState();
    starCatalogue = StarCatalogue.make();
    loadLocationData();
  }

  @override
  Widget build(BuildContext context) {
    final locationData = ref.watch(locationProvider);
    final viewSelect = ref.watch(viewSelectProvider);

    return FutureBuilder<StarCatalogue>(
        future: starCatalogue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(_messageError));
          } else if (snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(title: const Text(appName), actions: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      tooltip: AppLocalizations.of(context)!.locationSetting,
                      onPressed: () async {
                        final lat =
                            DmsAngle.fromDegrees(locationData.latInDegrees());
                        final long =
                            DmsAngle.fromDegrees(locationData.longInDegrees());
                        final newOne =
                            await pushAndPopLocationData([lat, long]);
                        saveLocationData(newOne);
                      })
                ]),
                drawer: const SettingDrawer(),
                body: viewSelect == View.clock
                    ? const ClockView()
                    : viewSelect == View.momentary
                        ? MomentarySkyView(
                            key: const PageStorageKey<String>(
                                _keyMomentarySkyView),
                            starCatalogue: snapshot.data as StarCatalogue,
                          )
                        : viewSelect == View.orbit
                            ? const OrbitView(
                                key: PageStorageKey<String>(_keyOrbitView))
                            : viewSelect == View.wholeNight
                                ? WholeNightSkyView(
                                    key: const PageStorageKey<String>(
                                        _keyWholeNightSkyView),
                                    starCatalogue:
                                        snapshot.data as StarCatalogue,
                                  )
                                : ObjectListView(
                                    starCatalogue:
                                        snapshot.data as StarCatalogue));
          } else {
            return Theme(
                data: ThemeData.dark(),
                child: Scaffold(
                    body: Center(
                        child: Text(
                  _messageLoading,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Colors.grey),
                ))));
          }
        });
  }

  Future<void> loadLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    final isSouth = prefs.getBool(_keyIsSouth) ?? defaultLatNeg;
    final latDeg = prefs.getInt(_keyLatDeg) ?? defaultLatDeg;
    final latMin = prefs.getInt(_keyLatMin) ?? defaultLatMin;
    final latSec = prefs.getInt(_keyLatSec) ?? defaultLatSec;
    final isWest = prefs.getBool(_keyLongNeg) ?? defaultLongNeg;
    final longDeg = prefs.getInt(_keyLongDeg) ?? defaultLongDeg;
    final longMin = prefs.getInt(_keyLongMin) ?? defaultLongMin;
    final longSec = prefs.getInt(_keyLongSec) ?? defaultLongSec;
    final lang = prefs.getString(_keyLang) ?? 'en';

    setState(() {
      ref.read(languageSelectProvider.notifier).state = Locale(lang);
      ref.read(locationProvider.notifier).setLocation(
          lat: DmsAngle(isSouth, latDeg, latMin, latSec),
          long: DmsAngle(isWest, longDeg, longMin, longSec));
    });
  }

  void saveLocationData(List<DmsAngle> location) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyIsSouth, location[0].isNegative);
    prefs.setInt(_keyLatDeg, location[0].deg);
    prefs.setInt(_keyLatMin, location[0].min);
    prefs.setInt(_keyLatSec, location[0].sec);
    prefs.setBool(_keyLongNeg, location[1].isNegative);
    prefs.setInt(_keyLongDeg, location[1].deg);
    prefs.setInt(_keyLongMin, location[1].min);
    prefs.setInt(_keyLongSec, location[1].sec);
    setState(() {});
  }

  Future<List<DmsAngle>> pushAndPopLocationData(List<DmsAngle> location) async {
    RouteSettings settings = RouteSettings(arguments: location);
    await Navigator.push(
        context,
        MaterialPageRoute(
          settings: settings,
          builder: (context) => const LocationSettingView(),
        )).then((result) {
      location = result as List<DmsAngle>;
      ref
          .read(locationProvider.notifier)
          .setLocation(lat: location[0], long: location[1]);
    });
    return location;
  }
}
