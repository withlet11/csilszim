/*
 * elp82b2.dart
 *
 * LUNAR SOLUTION ELP2000-82B
 * by Chapront-Touze M., Chapront J.
 * ftp://ftp.imcce.fr/pub/ephem/moon/elp82b
 *
 * I (Yasuhiro Yamakawa) have just taken the Fortran code and data
 * obtained from above and used it to create this piece of software.
 *
 * I can neither allow nor forbid the usage of ELP2000-82B.
 * The copyright notice below covers not the works of
 * Chapront-Touze M. and Chapront J., but just my work,
 * that is the compilation and rearrangement of
 * the Fortran code and data obtained from above
 * into the software supplied in this file.
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
 *
 * My implementation of ELP2000-82B has the following modifications compared to
 * the original Fortran code:
 * 1) fundamentally rearrange the series into optimized instructions
 *    for fast calculation of the results
 *
 */

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

const _pis2 = pi / 2.0;
const _rad = 648000.0 / pi;
const _deg = pi / 180.0;
const _c1 = 60.0;
const _c2 = 3600.0;

const _ath = 384747.9806743165;

// Lunar arguments.
const _w01 = 1732559343.73604 / _rad;
const _w = [
  [
    (218 + 18 / _c1 + 59.95571 / _c2) * _deg,
    _w01, // 1732559343.73604 / _rad,
    -5.8883 / _rad,
    0.6604e-2 / _rad,
    -0.3169e-4 / _rad
  ],
  [
    (83 + 21 / _c1 + 11.67475 / _c2) * _deg,
    14643420.2632 / _rad,
    -38.2776 / _rad,
    -0.45047e-1 / _rad,
    0.21301e-3 / _rad
  ],
  [
    (125 + 2 / _c1 + 40.39816 / _c2) * _deg,
    -6967919.3622 / _rad,
    6.3622 / _rad,
    0.7625e-2 / _rad,
    -0.3586e-4 / _rad
  ]
];

const _eart0 = (100 + 27 / _c1 + 59.22059 / _c2) * _deg;
const _eart1 = 129597742.2758 / _rad;

final _numReg = RegExp(r'-?\d+(\.\d+)?');

class Elp82b2 {
  var prec0 = -1.0;

// dimension nterm(3,12),nrang(3,12),zone(6)
  final nterm = [for (var i = 0; i < 3; ++i) List<int>.filled(12, 0)];
  final nrang = [for (var i = 0; i < 3; ++i) List<int>.filled(12, 0)];

  // dimension pc1(6,1023),pc2(6,918),pc3(6,704)
  final pc1 = [for (var i = 0; i < 6; ++i) List<double>.filled(1023, 0.0)];
  final pc2 = [for (var i = 0; i < 6; ++i) List<double>.filled(918, 0.0)];
  final pc3 = [for (var i = 0; i < 6; ++i) List<double>.filled(704, 0.0)];

  // Perturbations
  final per1 = [for (var i = 0; i < 3; ++i) List<double>.filled(19537, 0.0)];
  final per2 = [for (var i = 0; i < 3; ++i) List<double>.filled(6766, 0.0)];
  final per3 = [for (var i = 0; i < 3; ++i) List<double>.filled(8924, 0.0)];

  Elp82b2._internal();

  static Future<Elp82b2> make({required double prec}) async {
    final temp = Elp82b2._internal();
    await temp._setPrecision(prec);
    return temp;
  }

  Vector3 calculate(double tjj) {
    const sc = 36525.0;
    const dj2000 = 2451545.0;
    const a0 = 384747.9806448954;

    // Precession matrix.
    const p1 = 0.10180391e-4;
    const p2 = 0.47020439e-6;
    const p3 = -0.5417367e-9;
    const p4 = -0.2507948e-11;
    const p5 = 0.463486e-14;
    const q1 = -0.113469002e-3;
    const q2 = 0.12372674e-6;
    const q3 = 0.1265417e-8;
    const q4 = -0.1371808e-11;
    const q5 = -0.320334e-14;

    final t = List<double>.filled(5, 1.0);
    t[1] = (tjj - dj2000) / sc;
    t[2] = t[1] * t[1];
    t[3] = t[2] * t[1];
    t[4] = t[3] * t[1];

    final r = List<double>.filled(3, 0.0);

    // Substitution of time
    for (var iv = 0; iv < 3; ++iv) {
      final (List<List<double>> pc, per) =
          switch (iv) { 0 => (pc1, per1), 1 => (pc2, per2), _ => (pc3, per3) };
      for (var itab = 0; itab < 12; ++itab) {
        for (var nt = 0; nt < nterm[iv][itab]; ++nt) {
          double x, y;
          if (itab == 0) {
            x = pc[0][nt];
            y = pc[1][nt];
            for (var k = 0; k < 4; ++k) {
              y += pc[k + 2][nt] * t[k + 1];
            }
          } else {
            final j = nrang[iv][itab - 1] + nt;
            x = per[0][j];
            y = per[1][j] + per[2][j] * t[1];
            switch (itab) {
              case 2 || 4 || 6 || 8:
                x *= t[1];
              case 11:
                x *= t[2];
            }
          }

          r[iv] += x * sin(y);
        }
      }
    }

    // Change of coordinates
    r[0] = r[0] / _rad +
        _w[0][0] +
        _w[0][1] * t[1] +
        _w[0][2] * t[2] +
        _w[0][3] * t[3] +
        _w[0][4] * t[4];
    r[1] /= _rad;
    r[2] *= a0 / _ath;

    final x0 = r[2] * cos(r[1]);
    final x1 = x0 * cos(r[0]);
    final x2 = x0 * sin(r[0]);
    final x3 = r[2] * sin(r[1]);

    final pw = (p1 + p2 * t[1] + p3 * t[2] + p4 * t[3] + p5 * t[4]) * t[1];
    final qw = (q1 + q2 * t[1] + q3 * t[2] + q4 * t[3] + q5 * t[4]) * t[1];
    final ra = 2.0 * sqrt(1.0 - pw * pw - qw * qw);
    final pwqw = 2.0 * pw * qw;
    final pw2 = 1.0 - 2 * pw * pw;
    final qw2 = 1.0 - 2 * qw * qw;
    final pwra = pw * ra;
    final qwra = qw * ra;

    final x = pw2 * x1 + pwqw * x2 + pwra * x3;
    final y = pwqw * x1 + qw2 * x2 - qwra * x3;
    final z = -pwra * x1 + qwra * x2 + (pw2 + qw2 - 1.0) * x3;
    return Vector3(x, y, z);
  }

  Future<void> _setPrecision(double prec) async {
    if (prec == prec0) return;

    // Precession constant.
    const precess = 5029.0966 / _rad;

    const eart = [
      _eart0, // (100 + 27 / _c1 + 59.22059 / _c2) * _deg,
      _eart1, // 129597742.2758 / _rad,
      -0.0202 / _rad,
      0.9e-5 / _rad,
      0.15e-6 / _rad
    ];

    const peri = [
      (102 + 56 / _c1 + 14.42753 / _c2) * _deg,
      1161.2283 / _rad,
      0.5327 / _rad,
      -0.138e-3 / _rad,
      0.0
    ];

    // Delaunay's arguments.
    final del = [for (var i = 0; i < 4; ++i) List<double>.filled(5, 0.0)];
    for (var i = 0; i < 5; ++i) {
      del[0][i] = _w[0][i] - eart[i];
      del[3][i] = _w[0][i] - _w[2][i];
      del[2][i] = _w[0][i] - _w[1][i];
      del[1][i] = eart[i] - peri[i];
    }
    del[0][0] += pi;

    final zeta = [_w[0][0], _w[0][1] + precess];

    final coef = List<double>.filled(7, 0.0);
    final ilu = List<int>.filled(4, 0);
    final ipla = List<int>.filled(11, 0);

    final zone = List<double>.filled(11, 0.0);

    // Reading files
    prec0 = prec;
    final pre = [prec * _rad - 1.0e-12, prec * _rad - 1.0e-12, prec * _ath];

    for (var ific = 1; ific <= 36; ++ific) {
      var ir = 0;
      var itab = (ific - 1) ~/ 3;
      var iv = (ific - 1) % 3;

      String filename = 'assets/elp82b/ELP$ific';
      String text = await rootBundle.loadString(filename);
      if (ific <= 3) {
        // Files : Main problem.
        for (final line in text.split('\n').sublist(1)) {
          if (line.isEmpty) break;
          ir = setMainProblem(line, ir, ific, iv, del, pre, coef, ilu, zone);
        }
      } else if (ific >= 10 && ific <= 21) {
        for (final line in text.split('\n').sublist(1)) {
          if (line.isEmpty) break;
          ir = setPlanetaryPerturbations(
              line, ir, ific, itab, iv, del, pre, ipla, zone);
        }
      } else {
        for (final line in text.split('\n').sublist(1)) {
          if (line.isEmpty) break;
          ir = setTidesRelativitySolarEccentricity(
              line, ir, itab, iv, del, zeta, pre, ilu, zone);
        }
      }

      nterm[iv][itab] = ir - 1;
      nrang[iv][itab] = itab == 0 ? 0 : nrang[iv][itab - 1] + nterm[iv][itab];
    }
  }

  int setMainProblem(
      String line,
      int ir,
      int ific,
      int iv,
      List<List<double>> del,
      List<double> pre,
      List<double> coef,
      List<int> ilu,
      List<double> zone) {
    // Parameters
    const am = 0.074801329518;
    const alpha = 0.002571881335;
    const dtasm = 2.0 * alpha / (3.0 * am);

    // Corrections of the constants (fit to DE200/LE200).
    const delnu = 0.55604 / _rad / _w01;
    const dele = 0.01789 / _rad;
    const delg = -0.08066 / _rad;
    const delnp = -0.06424 / _rad / _w01;
    const delep = -0.12879 / _rad;

    final values = _numReg.allMatches(line).toList().iterator;
    for (var i = 0; i < 4; ++i) {
      values.moveNext();
      ilu[i] = int.parse(values.current.group(0)!);
    }
    for (var i = 0; i < 7; ++i) {
      values.moveNext();
      coef[i] = double.parse(values.current.group(0)!);
    }

    var xx = coef[0];
    if (xx.abs() < pre[iv]) return ir;

    final tgv = coef[1] + dtasm * coef[5];
    if (ific == 3) coef[0] -= 2.0 * coef[0] * delnu / 3.0;
    xx = coef[0] +
        tgv * (delnp - am * delnu) +
        coef[2] * delg +
        coef[3] * dele +
        coef[4] * delep;
    zone[0] = xx;
    for (var k = 0; k < 5; ++k) {
      var y = 0.0;
      for (var i = 0; i < 4; ++i) {
        y += ilu[i] * del[i][k];
      }
      zone[k + 1] = y;
    }
    if (iv == 2) zone[1] += _pis2;
    final pc = switch (iv) { 0 => pc1, 1 => pc2, _ => pc3 };
    for (var i = 0; i < 6; ++i) {
      pc[i][ir] = zone[i];
    }
    return ir + 1;
  }

  int setTidesRelativitySolarEccentricity(
      String line,
      int ir,
      int itab,
      int iv,
      List<List<double>> del,
      List<double> zeta,
      List<double> pre,
      List<int> ilu,
      List<double> zone) {
    final values = _numReg.allMatches(line).toList().iterator;
    values.moveNext();
    final iz = int.parse(values.current.group(0)!);
    for (var i = 0; i < 4; ++i) {
      values.moveNext();
      ilu[i] = int.parse(values.current.group(0)!);
    }
    values.moveNext();
    final pha = double.parse(values.current.group(0)!);
    values.moveNext();
    final xx = double.parse(values.current.group(0)!);
    if (xx < pre[iv]) return ir;

    zone[0] = xx;
    for (var k = 0; k < 2; ++k) {
      var y = k == 0 ? pha * _deg : 0.0;
      y += iz * zeta[k];
      for (var i = 0; i < 4; ++i) {
        y += ilu[i] * del[i][k];
      }
      zone[k + 1] = y;
    }
    final j = nrang[iv][itab - 1] + ir;
    final per = switch (iv) { 0 => per1, 1 => per2, _ => per3 };
    for (var i = 0; i < 3; ++i) {
      per[i][j] = zone[i];
    }
    return ir + 1;
  }

  int setPlanetaryPerturbations(
      String line,
      int ir,
      int ific,
      int itab,
      int iv,
      List<List<double>> del,
      List<double> pre,
      List<int> ipla,
      List<double> zone) {
    final values = _numReg.allMatches(line).toList().iterator;
    for (var i = 0; i < 11; ++i) {
      values.moveNext();
      ipla[i] = int.parse(values.current.group(0)!);
    }
    values.moveNext();
    final pha = double.parse(values.current.group(0)!);
    values.moveNext();
    final xx = double.parse(values.current.group(0)!);
    if (xx < pre[iv]) return ir;

    // Planetary arguments.
    const p = [
      [(252 + 15 / _c1 + 3.25986 / _c2) * _deg, 538101628.68898 / _rad],
      [(181 + 58 / _c1 + 47.28305 / _c2) * _deg, 210664136.43355 / _rad],
      [_eart0, _eart1],
      [(355 + 25 / _c1 + 59.78866 / _c2) * _deg, 68905077.59284 / _rad],
      [(34 + 21 / _c1 + 5.34212 / _c2) * _deg, 10925660.42861 / _rad],
      [(50 + 4 / _c1 + 38.89694 / _c2) * _deg, 4399609.65932 / _rad],
      [(314 + 3 / _c1 + 18.01841 / _c2) * _deg, 1542481.19393 / _rad],
      [(304 + 20 / _c1 + 55.19575 / _c2) * _deg, 786550.32074 / _rad]
    ];

    zone[0] = xx;
    if (ific < 16) {
      for (var k = 0; k < 2; ++k) {
        var y = k == 0 ? pha * _deg : 0.0;
        y += ipla[8] * del[0][k] + ipla[9] * del[2][k] + ipla[10] * del[3][k];
        for (var i = 0; i < 8; ++i) {
          y += ipla[i] * p[i][k];
        }
        zone[k + 1] = y;
      }
    } else {
      for (var k = 0; k < 2; ++k) {
        var y = k == 0 ? pha * _deg : 0.0;
        for (var i = 0; i < 4; ++i) {
          y += ipla[i + 7] * del[i][k];
        }
        for (var i = 0; i < 7; ++i) {
          y += ipla[i] * p[i][k];
        }
        zone[k + 1] = y;
      }
    }
    final j = nrang[iv][itab - 1] + ir;
    final per = switch (iv) { 0 => per1, 1 => per2, _ => per3 };
    for (var i = 0; i < 3; ++i) {
      per[i][j] = zone[i];
    }
    return ir + 1;
  }
}
