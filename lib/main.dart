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

// import 'dart:html';

import 'package:csilszim/provider/view_select_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'astronomical/star_catalogue.dart';
import 'clock_view/clock_view.dart';
import 'orbit_view/orbit_view.dart';
import 'setting_view/location_setting_view.dart';
import 'setting_view/setting_drawer.dart';
import 'provider/location_provider.dart';
import 'sky_view/sky_view.dart';

import 'utilities/sexagesimal_angle.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Csilszim',
      home: HomePage(title: 'Csilszim'),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

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
            return const Center(child: Text('Error'));
          } else if (snapshot.hasData) {
            return MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        tooltip: 'Location Setting',
                        onPressed: () async {
                          final lat =
                              DmsAngle.fromDegrees(locationData.latInDegrees());
                          final long = DmsAngle.fromDegrees(
                              locationData.longInDegrees());
                          final newOne =
                              await pushAndPopLocationData([lat, long]);
                          saveLocationData(newOne);
                        },
                      )
                    ],
                  ),
                  drawer: const SettingDrawer(),
                  body: //  TabBarView(
                      // physics: const NeverScrollableScrollPhysics(),
                      // children: <Widget>[
                      viewSelect == View.clock
                          ? const ClockView()
                          : viewSelect == View.sky
                              ? SkyView(
                                  key: const PageStorageKey<String>(
                                      "key_SkyView"),
                                  starCatalogue: snapshot.data as StarCatalogue,
                                )
                              : const OrbitView(
                                  key:
                                      PageStorageKey<String>('key_OrbitView'))),
            );
          } else {
            return Theme(
              data: ThemeData.dark(),
              child: Scaffold(
                  body: Center(
                child: Text(
                  'Loading...',
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.copyWith(color: Colors.grey),
                ),
              )),
            );
          }
        });
  }

  Future<void> loadLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    final isSouth = prefs.getBool('isSouth') ?? false;
    final latDeg = prefs.getInt('latDeg') ?? 45;
    final latMin = prefs.getInt('latMin') ?? 0;
    final latSec = prefs.getInt('latSec') ?? 0;
    final longDeg = prefs.getInt('longDeg') ?? 0;
    final longMin = prefs.getInt('longMin') ?? 0;
    final longSec = prefs.getInt('longSec') ?? 0;

    setState(() {
      ref.read(locationProvider.notifier).setLocation(
          lat: DmsAngle(isSouth, latDeg, latMin, latSec),
          long: DmsAngle(false, longDeg, longMin, longSec));
    });
  }

  void saveLocationData(List<DmsAngle> location) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSouth', location[0].isNegative);
    prefs.setInt('latDeg', location[0].deg);
    prefs.setInt('latMin', location[0].min);
    prefs.setInt('latSec', location[0].sec);
    prefs.setInt('longDeg', location[1].deg);
    prefs.setInt('longMin', location[1].min);
    prefs.setInt('longSec', location[1].sec);
    setState(() {});
  }

  Future<List<DmsAngle>> pushAndPopLocationData(List<DmsAngle> location) async {
    RouteSettings settings = RouteSettings(arguments: location);
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: settings,
        builder: (context) => const LocationSettingView(),
      ),
    ).then((result) {
      location = result as List<DmsAngle>;
      ref
          .read(locationProvider.notifier)
          .setLocation(lat: location[0], long: location[1]);
    });
    return location;
  }
}
