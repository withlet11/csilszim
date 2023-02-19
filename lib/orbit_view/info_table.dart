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

import '../astronomical/time_model.dart';
import 'configs.dart';

class InfoTable extends StatelessWidget {
  final TimeModel timeModel;

  const InfoTable({super.key, required this.timeModel});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Date and Time: ${timeModel.utc.toIso8601String()}'),
          legend('Sun', Colors.orange),
          legend('Mercury', planetColor['mercury']!),
          legend('Venus', planetColor['venus']!),
          legend('Earth', planetColor['earth']!),
          legend('Mars', planetColor['mars']!),
          legend('Jupiter', planetColor['jupiter']!),
          legend('Saturn', planetColor['saturn']!),
          legend('Uranus', planetColor['uranus']!),
          legend('Neptune', planetColor['neptune']!),
          legend('Ceres', dwarfPlanetColor['ceres']!),
          legend('Pluto', dwarfPlanetColor['pluto']!),
          legend('Eris', dwarfPlanetColor['eris']!),
          legend('Haumea', dwarfPlanetColor['haumea']!),
          legend('Makemake', dwarfPlanetColor['makemake']!),
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
