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

import '../astronomical/time_model.dart';
import 'configs.dart';

class InfoTable extends StatelessWidget {
  final TimeModel timeModel;

  const InfoTable({super.key, required this.timeModel});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Text('Date and Time: ${timeModel.utc.toIso8601String()}'),
      legend(AppLocalizations.of(context)!.sun, Colors.orange),
      legend(AppLocalizations.of(context)!.mercury, planetColor['mercury']!),
      legend(AppLocalizations.of(context)!.venus, planetColor['venus']!),
      legend(AppLocalizations.of(context)!.earth, planetColor['earth']!),
      legend(AppLocalizations.of(context)!.mars, planetColor['mars']!),
      legend(AppLocalizations.of(context)!.jupiter, planetColor['jupiter']!),
      legend(AppLocalizations.of(context)!.saturn, planetColor['saturn']!),
      legend(AppLocalizations.of(context)!.uranus, planetColor['uranus']!),
      legend(AppLocalizations.of(context)!.neptune, planetColor['neptune']!),
      legend(AppLocalizations.of(context)!.ceres, dwarfPlanetColor['ceres']!),
      legend(AppLocalizations.of(context)!.pluto, dwarfPlanetColor['pluto']!),
      legend(AppLocalizations.of(context)!.eris, dwarfPlanetColor['eris']!),
      legend(AppLocalizations.of(context)!.haumea, dwarfPlanetColor['haumea']!),
      legend(AppLocalizations.of(context)!.makemake,
          dwarfPlanetColor['makemake']!),
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
