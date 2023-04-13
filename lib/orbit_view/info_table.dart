/*
 * info_table.dart
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

import '../astronomical/astronomical_object/celestial_id.dart';
import '../astronomical/time_model.dart';
import 'configs.dart';
import 'orbitViewSettingProvider.dart';

class InfoTable extends ConsumerWidget {
  final TimeModel timeModel;

  const InfoTable({super.key, required this.timeModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(orbitViewSettingProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Text('Date and Time: ${timeModel.utc.toIso8601String()}'),
      legend(AppLocalizations.of(context)!.sun, Colors.orange),
      if (settings.isMercuryVisible)
        legend(AppLocalizations.of(context)!.mercury, planetColor[CelestialId.mercury]!),
      if (settings.isVenusVisible)
        legend(AppLocalizations.of(context)!.venus, planetColor[CelestialId.venus]!),
      if (settings.isEarthVisible)
        legend(AppLocalizations.of(context)!.earth, planetColor[CelestialId.earth]!),
      if (settings.isMarsVisible)
        legend(AppLocalizations.of(context)!.mars, planetColor[CelestialId.mars]!),
      if (settings.isJupiterVisible)
        legend(AppLocalizations.of(context)!.jupiter, planetColor[CelestialId.jupiter]!),
      if (settings.isSaturnVisible)
        legend(AppLocalizations.of(context)!.saturn, planetColor[CelestialId.saturn]!),
      if (settings.isUranusVisible)
        legend(AppLocalizations.of(context)!.uranus, planetColor[CelestialId.uranus]!),
      if (settings.isNeptuneVisible)
        legend(AppLocalizations.of(context)!.neptune, planetColor[CelestialId.neptune]!),
      if (settings.isCeresVisible)
        legend(AppLocalizations.of(context)!.ceres, dwarfPlanetColor[CelestialId.ceres]!),
      if (settings.isPlutoVisible)
        legend(AppLocalizations.of(context)!.pluto, dwarfPlanetColor[CelestialId.pluto]!),
      if (settings.isErisVisible)
        legend(AppLocalizations.of(context)!.eris, dwarfPlanetColor[CelestialId.eris]!),
      if (settings.isHaumeaVisible)
        legend(
            AppLocalizations.of(context)!.haumea, dwarfPlanetColor[CelestialId.haumea]!),
      if (settings.isMakemakeVisible)
        legend(AppLocalizations.of(context)!.makemake,
            dwarfPlanetColor[CelestialId.makemake]!),
      if (settings.isHalleyVisible)
        legend(AppLocalizations.of(context)!.halley, cometColor[CelestialId.halley]!),
      if (settings.isEnckeVisible)
        legend(AppLocalizations.of(context)!.encke, cometColor[CelestialId.encke]!),
      if (settings.isFayeVisible)
        legend(AppLocalizations.of(context)!.faye, cometColor[CelestialId.faye]!),
      if (settings.isDArrestVisible)
        legend(AppLocalizations.of(context)!.dArrest, cometColor[CelestialId.dArrest]!),
      if (settings.isPonsWinneckeVisible)
        legend(AppLocalizations.of(context)!.ponsWinnecke,
            cometColor[CelestialId.ponsWinnecke]!),
      if (settings.isTuttleVisible)
        legend(AppLocalizations.of(context)!.tuttle, cometColor[CelestialId.tuttle]!),
      if (settings.isTempel1Visible)
        legend(AppLocalizations.of(context)!.tempel1, cometColor[CelestialId.tempel1]!),
      if (settings.isTempel2Visible)
        legend(AppLocalizations.of(context)!.tempel2, cometColor[CelestialId.tempel2]!),
    ]);
  }

  Widget legend(String name, Color color) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            )),
        Text(name)
      ],
    );
  }
}
