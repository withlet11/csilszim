/*
 * solar_system.dart
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

import 'orbit_calculation/orbital_element.dart';
/*
https://ssd.jpl.nasa.gov/planets/approx_pos.html

Keplerian Elements and Rates
Table 1
Keplerian elements and their rates, with respect to the mean ecliptic and equinox of J2000, valid for the time-interval 1800 AD - 2050 AD.


               a              e               I                L            long.peri.      long.node.
           au, au/Cy     rad, rad/Cy     deg, deg/Cy      deg, deg/Cy      deg, deg/Cy     deg, deg/Cy
-----------------------------------------------------------------------------------------------------------
Mercury   0.38709927      0.20563593      7.00497902      252.25032350     77.45779628     48.33076593
          0.00000037      0.00001906     -0.00594749   149472.67411175      0.16047689     -0.12534081
Venus     0.72333566      0.00677672      3.39467605      181.97909950    131.60246718     76.67984255
          0.00000390     -0.00004107     -0.00078890    58517.81538729      0.00268329     -0.27769418
EM Bary   1.00000261      0.01671123     -0.00001531      100.46457166    102.93768193      0.0
          0.00000562     -0.00004392     -0.01294668    35999.37244981      0.32327364      0.0
Mars      1.52371034      0.09339410      1.84969142       -4.55343205    -23.94362959     49.55953891
          0.00001847      0.00007882     -0.00813131    19140.30268499      0.44441088     -0.29257343
Jupiter   5.20288700      0.04838624      1.30439695       34.39644051     14.72847983    100.47390909
         -0.00011607     -0.00013253     -0.00183714     3034.74612775      0.21252668      0.20469106
Saturn    9.53667594      0.05386179      2.48599187       49.95424423     92.59887831    113.66242448
         -0.00125060     -0.00050991      0.00193609     1222.49362201     -0.41897216     -0.28867794
Uranus   19.18916464      0.04725744      0.77263783      313.23810451    170.95427630     74.01692503
         -0.00196176     -0.00004397     -0.00242939      428.48202785      0.40805281      0.04240589
Neptune  30.06992276      0.00859048      1.77004347      -55.12002969     44.96476227    131.78422574
          0.00026291      0.00005105      0.00035372      218.45945325     -0.32241464     -0.00508664
------------------------------------------------------------------------------------------------------
EM Bary = Earth/Moon Barycenter
 */

class SolarSystem {
  /// A class of orbit elements with mean longitude
  static final planets = {
    'mercury': OrbitalElementWithMeanLongitude(
        a: (double t) => 0.38709927 + 0.00000037 * t,
        e: (double t) => 0.20563593 + 0.00001906 * t,
        i: (double t) => 7.00497902 - 0.00594749 * t,
        l: (double t) => 252.25032350 + 149472.67411175 * t,
        longPeri: (double t) => 77.45779628 + 0.16047689 * t,
        longNode: (double t) => 48.33076593 - 0.12534081 * t),
    'venus': OrbitalElementWithMeanLongitude(
        a: (double t) => 0.72333566 + 0.00000390 * t,
        e: (double t) => 0.00677672 - 0.00004107 * t,
        i: (double t) => 3.39467605 - 0.00078890 * t,
        l: (double t) => 181.97909950 + 58517.81538729 * t,
        longPeri: (double t) => 131.60246718 + 0.00268329 * t,
        longNode: (double t) => 76.67984255 - 0.27769418 * t),
    'earth': OrbitalElementWithMeanLongitude(
        a: (double t) => 1.00000261 + 0.00000562 * t,
        e: (double t) => 0.01671123 - 0.00004392 * t,
        i: (double t) => -0.00001531 - 0.01294668 * t,
        l: (double t) => 100.46457166 + 35999.37244981 * t,
        longPeri: (double t) => 102.93768193 + 0.32327364 * t,
        longNode: (double t) => 0.0 + 0.0 * t),
    'mars': OrbitalElementWithMeanLongitude(
        a: (double t) => 1.52371034 + 0.00001847 * t,
        e: (double t) => 0.09339410 + 0.00007882 * t,
        i: (double t) => 1.84969142 - 0.00813131 * t,
        l: (double t) => -4.55343205 + 19140.30268499 * t,
        longPeri: (double t) => -23.94362959 + 0.44441088 * t,
        longNode: (double t) => 49.55953891 - 0.29257343 * t),
    'jupiter': OrbitalElementWithMeanLongitude(
        a: (double t) => 5.20288700 - 0.00011607 * t,
        e: (double t) => 0.04838624 - 0.00013253 * t,
        i: (double t) => 1.30439695 - 0.00183714 * t,
        l: (double t) => 34.39644051 + 3034.74612775 * t,
        longPeri: (double t) => 14.72847983 + 0.21252668 * t,
        longNode: (double t) => 100.47390909 + 0.20469106 * t),
    'saturn': OrbitalElementWithMeanLongitude(
        a: (double t) => 9.53667594 - 0.00125060 * t,
        e: (double t) => 0.05386179 - 0.00050991 * t,
        i: (double t) => 2.48599187 + 0.00193609 * t,
        l: (double t) => 49.95424423 + 1222.49362201 * t,
        longPeri: (double t) => 92.59887831 - 0.41897216 * t,
        longNode: (double t) => 113.66242448 - 0.28867794 * t),
    'uranus': OrbitalElementWithMeanLongitude(
        a: (double t) => 19.18916464 - 0.00196176 * t,
        e: (double t) => 0.04725744 - 0.00004397 * t,
        i: (double t) => 0.77263783 - 0.00242939 * t,
        l: (double t) => 313.23810451 + 428.48202785 * t,
        longPeri: (double t) => 170.95427630 + 0.40805281 * t,
        longNode: (double t) => 74.01692503 + 0.04240589 * t),
    'neptune': OrbitalElementWithMeanLongitude(
        a: (double t) => 30.06992276 + 0.00026291 * t,
        e: (double t) => 0.00859048 + 0.00005105 * t,
        i: (double t) => 1.77004347 + 0.00035372 * t,
        l: (double t) => -55.12002969 + 218.45945325 * t,
        longPeri: (double t) => 44.96476227 - 0.32241464 * t,
        longNode: (double t) => 131.78422574 - 0.00508664 * t),
  };

  static final dwarfPlanets = {
    'ceres': OrbitalElementWithMeanMotion(
        a: (double t) => 413584014.351947 + 0.148082856990999 * t,
        e: (double t) => 0.107298605591374 - 0.0000000120198222603856 * t,
        i: (double t) => 11.782305750786 - 0.000000484373910411908 * t,
        tp: (double t) =>
            2452155.33370239 +
            0.000422287693029518 * t +
            1681.23133223247 * ((t - 2452350) ~/ 1681.23133223247),
        n: (double t) => 0.00000248159961949641 - 1.32841567817051E-15 * t,
        p: (double t) => -141.930299608497 + 0.0000875010767260137 * t,
        longNode: (double t) => 180.865343168561 - 0.0000409185674687272 * t),
    'pluto': OrbitalElementWithMeanMotion(
        a: (double t) => 5936109348.80781 - 7.96898499877203 * t,
        e: (double t) => 0.270625948257788 - 0.00000000870557323835501 * t,
        i: (double t) => 17.5970260013943 - 0.000000185365574310984 * t,
        tp: (double t) => 2448772.91433344 - 0.000394794796106099 * t,
        n: (double t) => 0.0000000457034747929794 + 6.74791508226093E-17 * t,
        p: (double t) => 97.3197846878656 + 0.00000671603857575789 * t,
        longNode: (double t) => 108.450803891514 + 0.000000758055914867182 * t),
    'eris': OrbitalElementWithMeanMotion(
        a: (double t) => 10037735525.6893 + 48.130570531904 * t,
        e: (double t) => 0.427543225197047 + 0.0000000041275203889238 * t,
        i: (double t) => 44.2828351256134 - 0.000000119352965264619 * t,
        tp: (double t) =>
            2555039.99992356 +
            -0.00376347701579471 * t +
            204304.378252318 * ((t - 2443509.5) ~/ 204304.378252318),
        n: (double t) => 0.0000000207527370773512 - 1.46035233407192E-16 * t,
        p: (double t) => 160.303285614715 - 0.00000371569236101165 * t,
        longNode: (double t) => 36.2071117484117 - 0.000000093705301513182 * t),
    'haumea': OrbitalElementWithMeanMotion(
        a: (double t) => 6526592426.43398 - 29.2795678842616 * t,
        e: (double t) => 0.179866795774475 + 0.00000000599068849353148 * t,
        i: (double t) => 28.1082683904377 + 0.0000000401856314040534 * t,
        tp: (double t) =>
            2513824.458571 +
            -0.00551715582470304 * t +
            103523.368971305 * ((t - 2448988.5) ~/ 103523.368971305),
        n: (double t) => 0.0000000395723197557672 + 2.76345968698448E-16 * t,
        p: (double t) => 266.198684688094 - 0.0000107104383808848 * t,
        longNode: (double t) =>
            122.049347002599 - 0.0000000421146479907754 * t),
    'makemake': OrbitalElementWithMeanMotion(
        a: (double t) => 7170706875.95335 - 145.320038757208 * t,
        e: (double t) => 0.229530883430302 - 0.0000000283354374741878 * t,
        i: (double t) => 28.7383384785065 + 0.000000108399116140748 * t,
        tp: (double t) =>
            2535236.6605278 +
            -0.00613849960027377 * t +
            112295.205907611 * ((t - 2463963.5) ~/ 112295.205907611),
        n: (double t) => 0.0000000342159296641432 + 1.17887172335553E-15 * t,
        p: (double t) => 323.080286374457 - 0.0000109459102996137 * t,
        longNode: (double t) => 79.7507885528252 - 0.000000126063226475941 * t),
  };
}
