/*
 * main.dart
 *
 * Copyright 2023-2024 Yasuhiro Yamakawa <withlet11@gmail.com>
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
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'clock_view/clock_view.dart';
import 'configs.dart';
import 'essential_data.dart';
import 'momentary_sky_view/momentary_sky_view.dart';
import 'object_list_view/object_list_view.dart';
import 'orbit_view/orbit_view.dart';
import 'provider/language_select_provider.dart';
import 'provider/base_settings_provider.dart';
import 'provider/view_select_provider.dart' as csilszim;
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
const _keyMapOrientation = 'mapOrientation';
const _keyTzLocation = 'tzLocation';
const _keyUsesLocationCoordinates = 'usesLocationCoordinates';
const _keyUsesLocationTimeZone = 'usesLocationTimeZone';
const _keyLang = 'lang';
const _messageError = 'Error';

void main() {
  tz.initializeTimeZones();
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

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late Future<EssentialData> starCatalogue;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _tabController.animateTo(2);
    starCatalogue = EssentialData.make();
    loadLocationData();
  }

  @override
  Widget build(BuildContext context) {
    final baseSettings = ref.watch(baseSettingsProvider);
    final viewSelect = ref.watch(csilszim.viewSelectProvider);

    return FutureBuilder<EssentialData>(
        future: starCatalogue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(_messageError));
          } else if (snapshot.hasData) {
            final localizations = AppLocalizations.of(context)!;
            return Scaffold(
              appBar: AppBar(
                  title: const Text(appName),
                  actions: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        tooltip: localizations.locationSetting,
                        onPressed: () async {
                          final newOne =
                              await pushAndPopLocationData(baseSettings);
                          saveLocationData(newOne);
                        })
                  ],
                  bottom: viewSelect == csilszim.View.objectList
                      ? TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(text: localizations.messierObjects),
                            Tab(text: localizations.brightestStars),
                          ],
                        )
                      : null),
              drawer: const SettingDrawer(),
              body: switch (viewSelect) {
                csilszim.View.clock => const ClockView(),
                csilszim.View.momentary => MomentarySkyView(
                    key: const PageStorageKey<String>(_keyMomentarySkyView),
                    starCatalogue: snapshot.data as EssentialData,
                  ),
                csilszim.View.orbit =>
                  const OrbitView(key: PageStorageKey<String>(_keyOrbitView)),
                csilszim.View.wholeNight => WholeNightSkyView(
                    key: const PageStorageKey<String>(_keyWholeNightSkyView),
                    starCatalogue: snapshot.data as EssentialData,
                  ),
                _ => ObjectListView(
                    tabController: _tabController,
                    starCatalogue: snapshot.data as EssentialData)
              },
            );
          } else {
            return Theme(
                data: ThemeData.dark(),
                child: Scaffold(
                    backgroundColor: const Color(0xff263e66),
                    body: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo_480x480.png',
                            height: 240.0, width: 240.0),
                        const CircularProgressIndicator()
                      ],
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
    final mapOrientation = MapOrientation
        .values[prefs.getInt(_keyMapOrientation) ?? MapOrientation.auto.index];
    final tzLocation = prefs.getString(_keyTzLocation) ?? '';
    final usesLocationCoordinates =
        prefs.getBool(_keyUsesLocationCoordinates) ?? false;
    final usesLocationTimeZone =
        prefs.getBool(_keyUsesLocationTimeZone) ?? false;
    final baseSettings = BaseSettings(
        lat: DmsAngle(isSouth, latDeg, latMin, latSec),
        long: DmsAngle(isWest, longDeg, longMin, longSec),
        tzLocation: tzLocation.isEmpty ? null : tz.getLocation(tzLocation),
        mapOrientation: mapOrientation,
        usesLocationCoordinates: usesLocationCoordinates,
        usesLocationTimeZone: usesLocationTimeZone);

    final lang = Locale(prefs.getString(_keyLang) ?? 'en');

    setState(() {
      ref.read(languageSelectProvider.notifier).state = lang;
      ref.read(baseSettingsProvider.notifier).set(baseSettings);
    });
  }

  void saveLocationData(BaseSettings baseSettings) async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = baseSettings.lat;
    final longitude = baseSettings.long;
    final mapOrientation = baseSettings.mapOrientation;
    final tzLocation = baseSettings.tzLocation?.name ?? '';
    prefs.setBool(_keyIsSouth, latitude.isNegative);
    prefs.setInt(_keyLatDeg, latitude.deg);
    prefs.setInt(_keyLatMin, latitude.min);
    prefs.setInt(_keyLatSec, latitude.sec);
    prefs.setBool(_keyLongNeg, longitude.isNegative);
    prefs.setInt(_keyLongDeg, longitude.deg);
    prefs.setInt(_keyLongMin, longitude.min);
    prefs.setInt(_keyLongSec, longitude.sec);
    prefs.setInt(_keyMapOrientation, mapOrientation.index);
    prefs.setString(_keyTzLocation, tzLocation);
    prefs.setBool(_keyUsesLocationCoordinates, baseSettings.usesLocationCoordinates);
    prefs.setBool(_keyUsesLocationTimeZone, baseSettings.usesLocationTimeZone);

    setState(() {});
  }

  Future<BaseSettings> pushAndPopLocationData(BaseSettings baseSettings) async {
    RouteSettings settings = RouteSettings(arguments: baseSettings);
    await Navigator.push(
        context,
        MaterialPageRoute(
          settings: settings,
          builder: (context) => const LocationSettingView(),
        )).then((result) {
      baseSettings = result as BaseSettings;
      ref.read(baseSettingsProvider.notifier).set(baseSettings);
    });
    return baseSettings;
  }
}
