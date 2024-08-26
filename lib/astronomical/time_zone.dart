/*
 * time_zone.dart
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

import '../utilities/sexagesimal_angle.dart';

class TimeZone {
  final List<String> countryCode;
  final DmsAngle lat;
  final DmsAngle long;
  final String name;

  const TimeZone(
      {required this.countryCode,
      required this.lat,
      required this.long,
      required this.name});

  static const areaList = [
    'Africa',
    'America',
    'Antarctica',
    'Asia',
    'Atlantic',
    'Australia',
    'Europe',
    'Indian',
    'Pacific',
  ];

  static const list = [
    TimeZone(
        countryCode: ['ZA', 'LS', 'SZ'],
        lat: DmsAngle(true, 26, 15, 0),
        long: DmsAngle(false, 28, 0, 0),
        name: 'Africa/Johannesburg'),
    TimeZone(
        countryCode: ['WS'],
        lat: DmsAngle(true, 13, 50, 0),
        long: DmsAngle(true, 171, 44, 0),
        name: 'Pacific/Apia'),
    TimeZone(
        countryCode: ['VU'],
        lat: DmsAngle(true, 17, 40, 0),
        long: DmsAngle(false, 168, 25, 0),
        name: 'Pacific/Efate'),
    TimeZone(
        countryCode: ['VN'],
        lat: DmsAngle(false, 10, 45, 0),
        long: DmsAngle(false, 106, 40, 0),
        name: 'Asia/Ho_Chi_Minh'),
    TimeZone(
        countryCode: ['VE'],
        lat: DmsAngle(false, 10, 30, 0),
        long: DmsAngle(true, 66, 56, 0),
        name: 'America/Caracas'),
    TimeZone(
        countryCode: ['UZ'],
        lat: DmsAngle(false, 41, 20, 0),
        long: DmsAngle(false, 69, 18, 0),
        name: 'Asia/Tashkent'),
    TimeZone(
        countryCode: ['UZ'],
        lat: DmsAngle(false, 39, 40, 0),
        long: DmsAngle(false, 66, 48, 0),
        name: 'Asia/Samarkand'),
    TimeZone(
        countryCode: ['UY'],
        lat: DmsAngle(true, 34, 54, 33),
        long: DmsAngle(true, 56, 12, 45),
        name: 'America/Montevideo'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 21, 18, 25),
        long: DmsAngle(true, 157, 51, 30),
        name: 'Pacific/Honolulu'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 51, 52, 48),
        long: DmsAngle(true, 176, 39, 29),
        name: 'America/Adak'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 64, 30, 4),
        long: DmsAngle(true, 165, 24, 23),
        name: 'America/Nome'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 59, 32, 49),
        long: DmsAngle(true, 139, 43, 38),
        name: 'America/Yakutat'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 55, 7, 37),
        long: DmsAngle(true, 131, 34, 35),
        name: 'America/Metlakatla'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 57, 10, 35),
        long: DmsAngle(true, 135, 18, 7),
        name: 'America/Sitka'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 58, 18, 7),
        long: DmsAngle(true, 134, 25, 11),
        name: 'America/Juneau'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 61, 13, 5),
        long: DmsAngle(true, 149, 54, 1),
        name: 'America/Anchorage'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 34, 3, 8),
        long: DmsAngle(true, 118, 14, 34),
        name: 'America/Los_Angeles'),
    TimeZone(
        countryCode: ['US', 'CA'],
        lat: DmsAngle(false, 33, 26, 54),
        long: DmsAngle(true, 112, 4, 24),
        name: 'America/Phoenix'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 43, 36, 49),
        long: DmsAngle(true, 116, 12, 9),
        name: 'America/Boise'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 39, 44, 21),
        long: DmsAngle(true, 104, 59, 3),
        name: 'America/Denver'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 47, 15, 51),
        long: DmsAngle(true, 101, 46, 40),
        name: 'America/North_Dakota/Beulah'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 46, 50, 42),
        long: DmsAngle(true, 101, 24, 39),
        name: 'America/North_Dakota/New_Salem'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 47, 6, 59),
        long: DmsAngle(true, 101, 17, 57),
        name: 'America/North_Dakota/Center'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 45, 6, 28),
        long: DmsAngle(true, 87, 36, 51),
        name: 'America/Menominee'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 41, 17, 45),
        long: DmsAngle(true, 86, 37, 30),
        name: 'America/Indiana/Knox'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 37, 57, 11),
        long: DmsAngle(true, 86, 45, 41),
        name: 'America/Indiana/Tell_City'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 41, 51, 0),
        long: DmsAngle(true, 87, 39, 0),
        name: 'America/Chicago'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 38, 44, 52),
        long: DmsAngle(true, 85, 4, 2),
        name: 'America/Indiana/Vevay'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 38, 29, 31),
        long: DmsAngle(true, 87, 16, 43),
        name: 'America/Indiana/Petersburg'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 38, 22, 32),
        long: DmsAngle(true, 86, 20, 41),
        name: 'America/Indiana/Marengo'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 41, 3, 5),
        long: DmsAngle(true, 86, 36, 11),
        name: 'America/Indiana/Winamac'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 38, 40, 38),
        long: DmsAngle(true, 87, 31, 43),
        name: 'America/Indiana/Vincennes'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 39, 46, 6),
        long: DmsAngle(true, 86, 9, 29),
        name: 'America/Indiana/Indianapolis'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 36, 49, 47),
        long: DmsAngle(true, 84, 50, 57),
        name: 'America/Kentucky/Monticello'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 38, 15, 15),
        long: DmsAngle(true, 85, 45, 34),
        name: 'America/Kentucky/Louisville'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 42, 19, 53),
        long: DmsAngle(true, 83, 2, 45),
        name: 'America/Detroit'),
    TimeZone(
        countryCode: ['US'],
        lat: DmsAngle(false, 40, 42, 51),
        long: DmsAngle(true, 74, 0, 23),
        name: 'America/New_York'),
    TimeZone(
        countryCode: ['UA'],
        lat: DmsAngle(false, 50, 26, 0),
        long: DmsAngle(false, 30, 31, 0),
        name: 'Europe/Kyiv'),
    TimeZone(
        countryCode: ['TW'],
        lat: DmsAngle(false, 25, 3, 0),
        long: DmsAngle(false, 121, 30, 0),
        name: 'Asia/Taipei'),
    TimeZone(
        countryCode: ['TR'],
        lat: DmsAngle(false, 41, 1, 0),
        long: DmsAngle(false, 28, 58, 0),
        name: 'Europe/Istanbul'),
    TimeZone(
        countryCode: ['TO'],
        lat: DmsAngle(true, 21, 8, 0),
        long: DmsAngle(true, 175, 12, 0),
        name: 'Pacific/Tongatapu'),
    TimeZone(
        countryCode: ['TN'],
        lat: DmsAngle(false, 36, 48, 0),
        long: DmsAngle(false, 10, 11, 0),
        name: 'Africa/Tunis'),
    TimeZone(
        countryCode: ['TM'],
        lat: DmsAngle(false, 37, 57, 0),
        long: DmsAngle(false, 58, 23, 0),
        name: 'Asia/Ashgabat'),
    TimeZone(
        countryCode: ['TL'],
        lat: DmsAngle(true, 8, 33, 0),
        long: DmsAngle(false, 125, 35, 0),
        name: 'Asia/Dili'),
    TimeZone(
        countryCode: ['TK'],
        lat: DmsAngle(true, 9, 22, 0),
        long: DmsAngle(true, 171, 14, 0),
        name: 'Pacific/Fakaofo'),
    TimeZone(
        countryCode: ['TJ'],
        lat: DmsAngle(false, 38, 35, 0),
        long: DmsAngle(false, 68, 48, 0),
        name: 'Asia/Dushanbe'),
    TimeZone(
        countryCode: ['TH', 'CX', 'KH', 'LA', 'VN'],
        lat: DmsAngle(false, 13, 45, 0),
        long: DmsAngle(false, 100, 31, 0),
        name: 'Asia/Bangkok'),
    TimeZone(
        countryCode: ['TD'],
        lat: DmsAngle(false, 12, 7, 0),
        long: DmsAngle(false, 15, 3, 0),
        name: 'Africa/Ndjamena'),
    TimeZone(
        countryCode: ['TC'],
        lat: DmsAngle(false, 21, 28, 0),
        long: DmsAngle(true, 71, 8, 0),
        name: 'America/Grand_Turk'),
    TimeZone(
        countryCode: ['SY'],
        lat: DmsAngle(false, 33, 30, 0),
        long: DmsAngle(false, 36, 18, 0),
        name: 'Asia/Damascus'),
    TimeZone(
        countryCode: ['SV'],
        lat: DmsAngle(false, 13, 42, 0),
        long: DmsAngle(true, 89, 12, 0),
        name: 'America/El_Salvador'),
    TimeZone(
        countryCode: ['ST'],
        lat: DmsAngle(false, 0, 20, 0),
        long: DmsAngle(false, 6, 44, 0),
        name: 'Africa/Sao_Tome'),
    TimeZone(
        countryCode: ['SS'],
        lat: DmsAngle(false, 4, 51, 0),
        long: DmsAngle(false, 31, 37, 0),
        name: 'Africa/Juba'),
    TimeZone(
        countryCode: ['SR'],
        lat: DmsAngle(false, 5, 50, 0),
        long: DmsAngle(true, 55, 10, 0),
        name: 'America/Paramaribo'),
    TimeZone(
        countryCode: ['SG', 'MY'],
        lat: DmsAngle(false, 1, 17, 0),
        long: DmsAngle(false, 103, 51, 0),
        name: 'Asia/Singapore'),
    TimeZone(
        countryCode: ['SD'],
        lat: DmsAngle(false, 15, 36, 0),
        long: DmsAngle(false, 32, 32, 0),
        name: 'Africa/Khartoum'),
    TimeZone(
        countryCode: ['SB', 'FM'],
        lat: DmsAngle(true, 9, 32, 0),
        long: DmsAngle(false, 160, 12, 0),
        name: 'Pacific/Guadalcanal'),
    TimeZone(
        countryCode: ['SA', 'AQ', 'KW', 'YE'],
        lat: DmsAngle(false, 24, 38, 0),
        long: DmsAngle(false, 46, 43, 0),
        name: 'Asia/Riyadh'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 64, 45, 0),
        long: DmsAngle(false, 177, 29, 0),
        name: 'Asia/Anadyr'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 53, 1, 0),
        long: DmsAngle(false, 158, 39, 0),
        name: 'Asia/Kamchatka'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 67, 28, 0),
        long: DmsAngle(false, 153, 43, 0),
        name: 'Asia/Srednekolymsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 46, 58, 0),
        long: DmsAngle(false, 142, 42, 0),
        name: 'Asia/Sakhalin'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 59, 34, 0),
        long: DmsAngle(false, 150, 48, 0),
        name: 'Asia/Magadan'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 64, 33, 37),
        long: DmsAngle(false, 143, 13, 36),
        name: 'Asia/Ust-Nera'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 43, 10, 0),
        long: DmsAngle(false, 131, 56, 0),
        name: 'Asia/Vladivostok'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 62, 39, 23),
        long: DmsAngle(false, 135, 33, 14),
        name: 'Asia/Khandyga'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 62, 0, 0),
        long: DmsAngle(false, 129, 40, 0),
        name: 'Asia/Yakutsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 52, 3, 0),
        long: DmsAngle(false, 113, 28, 0),
        name: 'Asia/Chita'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 52, 16, 0),
        long: DmsAngle(false, 104, 20, 0),
        name: 'Asia/Irkutsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 56, 1, 0),
        long: DmsAngle(false, 92, 50, 0),
        name: 'Asia/Krasnoyarsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 53, 45, 0),
        long: DmsAngle(false, 87, 7, 0),
        name: 'Asia/Novokuznetsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 56, 30, 0),
        long: DmsAngle(false, 84, 58, 0),
        name: 'Asia/Tomsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 53, 22, 0),
        long: DmsAngle(false, 83, 45, 0),
        name: 'Asia/Barnaul'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 55, 2, 0),
        long: DmsAngle(false, 82, 55, 0),
        name: 'Asia/Novosibirsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 55, 0, 0),
        long: DmsAngle(false, 73, 24, 0),
        name: 'Asia/Omsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 56, 51, 0),
        long: DmsAngle(false, 60, 36, 0),
        name: 'Asia/Yekaterinburg'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 53, 12, 0),
        long: DmsAngle(false, 50, 9, 0),
        name: 'Europe/Samara'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 54, 20, 0),
        long: DmsAngle(false, 48, 24, 0),
        name: 'Europe/Ulyanovsk'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 51, 34, 0),
        long: DmsAngle(false, 46, 2, 0),
        name: 'Europe/Saratov'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 46, 21, 0),
        long: DmsAngle(false, 48, 3, 0),
        name: 'Europe/Astrakhan'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 48, 44, 0),
        long: DmsAngle(false, 44, 25, 0),
        name: 'Europe/Volgograd'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 58, 36, 0),
        long: DmsAngle(false, 49, 39, 0),
        name: 'Europe/Kirov'),
    TimeZone(
        countryCode: ['RU', 'UA'],
        lat: DmsAngle(false, 44, 57, 0),
        long: DmsAngle(false, 34, 6, 0),
        name: 'Europe/Simferopol'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 55, 45, 21),
        long: DmsAngle(false, 37, 37, 4),
        name: 'Europe/Moscow'),
    TimeZone(
        countryCode: ['RU'],
        lat: DmsAngle(false, 54, 43, 0),
        long: DmsAngle(false, 20, 30, 0),
        name: 'Europe/Kaliningrad'),
    TimeZone(
        countryCode: ['RS', 'BA', 'HR', 'ME', 'MK', 'SI'],
        lat: DmsAngle(false, 44, 50, 0),
        long: DmsAngle(false, 20, 30, 0),
        name: 'Europe/Belgrade'),
    TimeZone(
        countryCode: ['RO'],
        lat: DmsAngle(false, 44, 26, 0),
        long: DmsAngle(false, 26, 6, 0),
        name: 'Europe/Bucharest'),
    TimeZone(
        countryCode: ['QA', 'BH'],
        lat: DmsAngle(false, 25, 17, 0),
        long: DmsAngle(false, 51, 32, 0),
        name: 'Asia/Qatar'),
    TimeZone(
        countryCode: ['PY'],
        lat: DmsAngle(true, 25, 16, 0),
        long: DmsAngle(true, 57, 40, 0),
        name: 'America/Asuncion'),
    TimeZone(
        countryCode: ['PW'],
        lat: DmsAngle(false, 7, 20, 0),
        long: DmsAngle(false, 134, 29, 0),
        name: 'Pacific/Palau'),
    TimeZone(
        countryCode: ['PT'],
        lat: DmsAngle(false, 37, 44, 0),
        long: DmsAngle(true, 25, 40, 0),
        name: 'Atlantic/Azores'),
    TimeZone(
        countryCode: ['PT'],
        lat: DmsAngle(false, 32, 38, 0),
        long: DmsAngle(true, 16, 54, 0),
        name: 'Atlantic/Madeira'),
    TimeZone(
        countryCode: ['PT'],
        lat: DmsAngle(false, 38, 43, 0),
        long: DmsAngle(true, 9, 8, 0),
        name: 'Europe/Lisbon'),
    TimeZone(
        countryCode: ['PS'],
        lat: DmsAngle(false, 31, 32, 0),
        long: DmsAngle(false, 35, 5, 42),
        name: 'Asia/Hebron'),
    TimeZone(
        countryCode: ['PS'],
        lat: DmsAngle(false, 31, 30, 0),
        long: DmsAngle(false, 34, 28, 0),
        name: 'Asia/Gaza'),
    TimeZone(
        countryCode: [
          'PR',
          'AG',
          'CA',
          'AI',
          'AW',
          'BL',
          'BQ',
          'CW',
          'DM',
          'GD',
          'GP',
          'KN',
          'LC',
          'MF',
          'MS',
          'SX',
          'TT',
          'VC',
          'VG',
          'VI'
        ],
        lat: DmsAngle(false, 18, 28, 6),
        long: DmsAngle(true, 66, 6, 22),
        name: 'America/Puerto_Rico'),
    TimeZone(
        countryCode: ['PN'],
        lat: DmsAngle(true, 25, 4, 0),
        long: DmsAngle(true, 130, 5, 0),
        name: 'Pacific/Pitcairn'),
    TimeZone(
        countryCode: ['PM'],
        lat: DmsAngle(false, 47, 3, 0),
        long: DmsAngle(true, 56, 20, 0),
        name: 'America/Miquelon'),
    TimeZone(
        countryCode: ['PL'],
        lat: DmsAngle(false, 52, 15, 0),
        long: DmsAngle(false, 21, 0, 0),
        name: 'Europe/Warsaw'),
    TimeZone(
        countryCode: ['PK'],
        lat: DmsAngle(false, 24, 52, 0),
        long: DmsAngle(false, 67, 3, 0),
        name: 'Asia/Karachi'),
    TimeZone(
        countryCode: ['PH'],
        lat: DmsAngle(false, 14, 35, 0),
        long: DmsAngle(false, 121, 0, 0),
        name: 'Asia/Manila'),
    TimeZone(
        countryCode: ['PG'],
        lat: DmsAngle(true, 6, 13, 0),
        long: DmsAngle(false, 155, 34, 0),
        name: 'Pacific/Bougainville'),
    TimeZone(
        countryCode: ['PG', 'AQ', 'FM'],
        lat: DmsAngle(true, 9, 30, 0),
        long: DmsAngle(false, 147, 10, 0),
        name: 'Pacific/Port_Moresby'),
    TimeZone(
        countryCode: ['PF'],
        lat: DmsAngle(true, 23, 8, 0),
        long: DmsAngle(true, 134, 57, 0),
        name: 'Pacific/Gambier'),
    TimeZone(
        countryCode: ['PF'],
        lat: DmsAngle(true, 9, 0, 0),
        long: DmsAngle(true, 139, 30, 0),
        name: 'Pacific/Marquesas'),
    TimeZone(
        countryCode: ['PF'],
        lat: DmsAngle(true, 17, 32, 0),
        long: DmsAngle(true, 149, 34, 0),
        name: 'Pacific/Tahiti'),
    TimeZone(
        countryCode: ['PE'],
        lat: DmsAngle(true, 12, 3, 0),
        long: DmsAngle(true, 77, 3, 0),
        name: 'America/Lima'),
    TimeZone(
        countryCode: ['PA', 'CA', 'KY'],
        lat: DmsAngle(false, 8, 58, 0),
        long: DmsAngle(true, 79, 32, 0),
        name: 'America/Panama'),
    TimeZone(
        countryCode: ['NZ'],
        lat: DmsAngle(true, 43, 57, 0),
        long: DmsAngle(true, 176, 33, 0),
        name: 'Pacific/Chatham'),
    TimeZone(
        countryCode: ['NZ', 'AQ'],
        lat: DmsAngle(true, 36, 52, 0),
        long: DmsAngle(false, 174, 46, 0),
        name: 'Pacific/Auckland'),
    TimeZone(
        countryCode: ['NU'],
        lat: DmsAngle(true, 19, 1, 0),
        long: DmsAngle(true, 169, 55, 0),
        name: 'Pacific/Niue'),
    TimeZone(
        countryCode: ['NR'],
        lat: DmsAngle(true, 0, 31, 0),
        long: DmsAngle(false, 166, 55, 0),
        name: 'Pacific/Nauru'),
    TimeZone(
        countryCode: ['NP'],
        lat: DmsAngle(false, 27, 43, 0),
        long: DmsAngle(false, 85, 19, 0),
        name: 'Asia/Kathmandu'),
    TimeZone(
        countryCode: ['NI'],
        lat: DmsAngle(false, 12, 9, 0),
        long: DmsAngle(true, 86, 17, 0),
        name: 'America/Managua'),
    TimeZone(
        countryCode: [
          'NG',
          'AO',
          'BJ',
          'CD',
          'CF',
          'CG',
          'CM',
          'GA',
          'GQ',
          'NE'
        ],
        lat: DmsAngle(false, 6, 27, 0),
        long: DmsAngle(false, 3, 24, 0),
        name: 'Africa/Lagos'),
    TimeZone(
        countryCode: ['NF'],
        lat: DmsAngle(true, 29, 3, 0),
        long: DmsAngle(false, 167, 58, 0),
        name: 'Pacific/Norfolk'),
    TimeZone(
        countryCode: ['NC'],
        lat: DmsAngle(true, 22, 16, 0),
        long: DmsAngle(false, 166, 27, 0),
        name: 'Pacific/Noumea'),
    TimeZone(
        countryCode: ['NA'],
        lat: DmsAngle(true, 22, 34, 0),
        long: DmsAngle(false, 17, 6, 0),
        name: 'Africa/Windhoek'),
    TimeZone(
        countryCode: ['MZ', 'BI', 'BW', 'CD', 'MW', 'RW', 'ZM', 'ZW'],
        lat: DmsAngle(true, 25, 58, 0),
        long: DmsAngle(false, 32, 35, 0),
        name: 'Africa/Maputo'),
    TimeZone(
        countryCode: ['MY', 'BN'],
        lat: DmsAngle(false, 1, 33, 0),
        long: DmsAngle(false, 110, 20, 0),
        name: 'Asia/Kuching'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 32, 32, 0),
        long: DmsAngle(true, 117, 1, 0),
        name: 'America/Tijuana'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 29, 4, 0),
        long: DmsAngle(true, 110, 58, 0),
        name: 'America/Hermosillo'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 20, 48, 0),
        long: DmsAngle(true, 105, 15, 0),
        name: 'America/Bahia_Banderas'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 23, 13, 0),
        long: DmsAngle(true, 106, 25, 0),
        name: 'America/Mazatlan'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 29, 34, 0),
        long: DmsAngle(true, 104, 25, 0),
        name: 'America/Ojinaga'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 31, 44, 0),
        long: DmsAngle(true, 106, 29, 0),
        name: 'America/Ciudad_Juarez'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 28, 38, 0),
        long: DmsAngle(true, 106, 5, 0),
        name: 'America/Chihuahua'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 25, 50, 0),
        long: DmsAngle(true, 97, 30, 0),
        name: 'America/Matamoros'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 25, 40, 0),
        long: DmsAngle(true, 100, 19, 0),
        name: 'America/Monterrey'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 20, 58, 0),
        long: DmsAngle(true, 89, 37, 0),
        name: 'America/Merida'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 21, 5, 0),
        long: DmsAngle(true, 86, 46, 0),
        name: 'America/Cancun'),
    TimeZone(
        countryCode: ['MX'],
        lat: DmsAngle(false, 19, 24, 0),
        long: DmsAngle(true, 99, 9, 0),
        name: 'America/Mexico_City'),
    TimeZone(
        countryCode: ['MV', 'TF'],
        lat: DmsAngle(false, 4, 10, 0),
        long: DmsAngle(false, 73, 30, 0),
        name: 'Indian/Maldives'),
    TimeZone(
        countryCode: ['MU'],
        lat: DmsAngle(true, 20, 10, 0),
        long: DmsAngle(false, 57, 30, 0),
        name: 'Indian/Mauritius'),
    TimeZone(
        countryCode: ['MT'],
        lat: DmsAngle(false, 35, 54, 0),
        long: DmsAngle(false, 14, 31, 0),
        name: 'Europe/Malta'),
    TimeZone(
        countryCode: ['MQ'],
        lat: DmsAngle(false, 14, 36, 0),
        long: DmsAngle(true, 61, 5, 0),
        name: 'America/Martinique'),
    TimeZone(
        countryCode: ['MO'],
        lat: DmsAngle(false, 22, 11, 50),
        long: DmsAngle(false, 113, 32, 30),
        name: 'Asia/Macau'),
    TimeZone(
        countryCode: ['MN'],
        lat: DmsAngle(false, 48, 4, 0),
        long: DmsAngle(false, 114, 30, 0),
        name: 'Asia/Choibalsan'),
    TimeZone(
        countryCode: ['MN'],
        lat: DmsAngle(false, 48, 1, 0),
        long: DmsAngle(false, 91, 39, 0),
        name: 'Asia/Hovd'),
    TimeZone(
        countryCode: ['MN'],
        lat: DmsAngle(false, 47, 55, 0),
        long: DmsAngle(false, 106, 53, 0),
        name: 'Asia/Ulaanbaatar'),
    TimeZone(
        countryCode: ['MM', 'CC'],
        lat: DmsAngle(false, 16, 47, 0),
        long: DmsAngle(false, 96, 10, 0),
        name: 'Asia/Yangon'),
    TimeZone(
        countryCode: ['MH'],
        lat: DmsAngle(false, 9, 5, 0),
        long: DmsAngle(false, 167, 20, 0),
        name: 'Pacific/Kwajalein'),
    TimeZone(
        countryCode: ['MD'],
        lat: DmsAngle(false, 47, 0, 0),
        long: DmsAngle(false, 28, 50, 0),
        name: 'Europe/Chisinau'),
    TimeZone(
        countryCode: ['MA'],
        lat: DmsAngle(false, 33, 39, 0),
        long: DmsAngle(true, 7, 35, 0),
        name: 'Africa/Casablanca'),
    TimeZone(
        countryCode: ['LY'],
        lat: DmsAngle(false, 32, 54, 0),
        long: DmsAngle(false, 13, 11, 0),
        name: 'Africa/Tripoli'),
    TimeZone(
        countryCode: ['LV'],
        lat: DmsAngle(false, 56, 57, 0),
        long: DmsAngle(false, 24, 6, 0),
        name: 'Europe/Riga'),
    TimeZone(
        countryCode: ['LT'],
        lat: DmsAngle(false, 54, 41, 0),
        long: DmsAngle(false, 25, 19, 0),
        name: 'Europe/Vilnius'),
    TimeZone(
        countryCode: ['LR'],
        lat: DmsAngle(false, 6, 18, 0),
        long: DmsAngle(true, 10, 47, 0),
        name: 'Africa/Monrovia'),
    TimeZone(
        countryCode: ['LK'],
        lat: DmsAngle(false, 6, 56, 0),
        long: DmsAngle(false, 79, 51, 0),
        name: 'Asia/Colombo'),
    TimeZone(
        countryCode: ['LB'],
        lat: DmsAngle(false, 33, 53, 0),
        long: DmsAngle(false, 35, 30, 0),
        name: 'Asia/Beirut'),
    TimeZone(
        countryCode: ['KZ'],
        lat: DmsAngle(false, 51, 13, 0),
        long: DmsAngle(false, 51, 21, 0),
        name: 'Asia/Oral'),
    TimeZone(
        countryCode: ['KZ'],
        lat: DmsAngle(false, 47, 7, 0),
        long: DmsAngle(false, 51, 56, 0),
        name: 'Asia/Atyrau'),
    TimeZone(
        countryCode: ['KZ'],
        lat: DmsAngle(false, 44, 31, 0),
        long: DmsAngle(false, 50, 16, 0),
        name: 'Asia/Aqtau'),
    TimeZone(
        countryCode: ['KZ'],
        lat: DmsAngle(false, 50, 17, 0),
        long: DmsAngle(false, 57, 10, 0),
        name: 'Asia/Aqtobe'),
    TimeZone(
        countryCode: ['KZ'],
        lat: DmsAngle(false, 53, 12, 0),
        long: DmsAngle(false, 63, 37, 0),
        name: 'Asia/Qostanay'),
    TimeZone(
        countryCode: ['KZ'],
        lat: DmsAngle(false, 44, 48, 0),
        long: DmsAngle(false, 65, 28, 0),
        name: 'Asia/Qyzylorda'),
    TimeZone(
        countryCode: ['KZ'],
        lat: DmsAngle(false, 43, 15, 0),
        long: DmsAngle(false, 76, 57, 0),
        name: 'Asia/Almaty'),
    TimeZone(
        countryCode: ['KR'],
        lat: DmsAngle(false, 37, 33, 0),
        long: DmsAngle(false, 126, 58, 0),
        name: 'Asia/Seoul'),
    TimeZone(
        countryCode: ['KP'],
        lat: DmsAngle(false, 39, 1, 0),
        long: DmsAngle(false, 125, 45, 0),
        name: 'Asia/Pyongyang'),
    TimeZone(
        countryCode: ['KI'],
        lat: DmsAngle(false, 1, 52, 0),
        long: DmsAngle(true, 157, 20, 0),
        name: 'Pacific/Kiritimati'),
    TimeZone(
        countryCode: ['KI'],
        lat: DmsAngle(true, 2, 47, 0),
        long: DmsAngle(true, 171, 43, 0),
        name: 'Pacific/Kanton'),
    TimeZone(
        countryCode: ['KI', 'MH', 'TV', 'UM', 'WF'],
        lat: DmsAngle(false, 1, 25, 0),
        long: DmsAngle(false, 173, 0, 0),
        name: 'Pacific/Tarawa'),
    TimeZone(
        countryCode: ['KG'],
        lat: DmsAngle(false, 42, 54, 0),
        long: DmsAngle(false, 74, 36, 0),
        name: 'Asia/Bishkek'),
    TimeZone(
        countryCode: [
          'KE',
          'DJ',
          'ER',
          'ET',
          'KM',
          'MG',
          'SO',
          'TZ',
          'UG',
          'YT'
        ],
        lat: DmsAngle(true, 1, 17, 0),
        long: DmsAngle(false, 36, 49, 0),
        name: 'Africa/Nairobi'),
    TimeZone(
        countryCode: ['JP'],
        lat: DmsAngle(false, 35, 39, 16),
        long: DmsAngle(false, 139, 44, 41),
        name: 'Asia/Tokyo'),
    TimeZone(
        countryCode: ['JO'],
        lat: DmsAngle(false, 31, 57, 0),
        long: DmsAngle(false, 35, 56, 0),
        name: 'Asia/Amman'),
    TimeZone(
        countryCode: ['JM'],
        lat: DmsAngle(false, 17, 58, 5),
        long: DmsAngle(true, 76, 47, 36),
        name: 'America/Jamaica'),
    TimeZone(
        countryCode: ['IT', 'SM', 'VA'],
        lat: DmsAngle(false, 41, 54, 0),
        long: DmsAngle(false, 12, 29, 0),
        name: 'Europe/Rome'),
    TimeZone(
        countryCode: ['IR'],
        lat: DmsAngle(false, 35, 40, 0),
        long: DmsAngle(false, 51, 26, 0),
        name: 'Asia/Tehran'),
    TimeZone(
        countryCode: ['IQ'],
        lat: DmsAngle(false, 33, 21, 0),
        long: DmsAngle(false, 44, 25, 0),
        name: 'Asia/Baghdad'),
    TimeZone(
        countryCode: ['IO'],
        lat: DmsAngle(true, 7, 20, 0),
        long: DmsAngle(false, 72, 25, 0),
        name: 'Indian/Chagos'),
    TimeZone(
        countryCode: ['IN'],
        lat: DmsAngle(false, 22, 32, 0),
        long: DmsAngle(false, 88, 22, 0),
        name: 'Asia/Kolkata'),
    TimeZone(
        countryCode: ['IL'],
        lat: DmsAngle(false, 31, 46, 50),
        long: DmsAngle(false, 35, 13, 26),
        name: 'Asia/Jerusalem'),
    TimeZone(
        countryCode: ['IE'],
        lat: DmsAngle(false, 53, 20, 0),
        long: DmsAngle(true, 6, 15, 0),
        name: 'Europe/Dublin'),
    TimeZone(
        countryCode: ['ID'],
        lat: DmsAngle(true, 2, 32, 0),
        long: DmsAngle(false, 140, 42, 0),
        name: 'Asia/Jayapura'),
    TimeZone(
        countryCode: ['ID'],
        lat: DmsAngle(true, 5, 7, 0),
        long: DmsAngle(false, 119, 24, 0),
        name: 'Asia/Makassar'),
    TimeZone(
        countryCode: ['ID'],
        lat: DmsAngle(true, 0, 2, 0),
        long: DmsAngle(false, 109, 20, 0),
        name: 'Asia/Pontianak'),
    TimeZone(
        countryCode: ['ID'],
        lat: DmsAngle(true, 6, 10, 0),
        long: DmsAngle(false, 106, 48, 0),
        name: 'Asia/Jakarta'),
    TimeZone(
        countryCode: ['HU'],
        lat: DmsAngle(false, 47, 30, 0),
        long: DmsAngle(false, 19, 5, 0),
        name: 'Europe/Budapest'),
    TimeZone(
        countryCode: ['HT'],
        lat: DmsAngle(false, 18, 32, 0),
        long: DmsAngle(true, 72, 20, 0),
        name: 'America/Port-au-Prince'),
    TimeZone(
        countryCode: ['HN'],
        lat: DmsAngle(false, 14, 6, 0),
        long: DmsAngle(true, 87, 13, 0),
        name: 'America/Tegucigalpa'),
    TimeZone(
        countryCode: ['HK'],
        lat: DmsAngle(false, 22, 17, 0),
        long: DmsAngle(false, 114, 9, 0),
        name: 'Asia/Hong_Kong'),
    TimeZone(
        countryCode: ['GY'],
        lat: DmsAngle(false, 6, 48, 0),
        long: DmsAngle(true, 58, 10, 0),
        name: 'America/Guyana'),
    TimeZone(
        countryCode: ['GW'],
        lat: DmsAngle(false, 11, 51, 0),
        long: DmsAngle(true, 15, 35, 0),
        name: 'Africa/Bissau'),
    TimeZone(
        countryCode: ['GU', 'MP'],
        lat: DmsAngle(false, 13, 28, 0),
        long: DmsAngle(false, 144, 45, 0),
        name: 'Pacific/Guam'),
    TimeZone(
        countryCode: ['GT'],
        lat: DmsAngle(false, 14, 38, 0),
        long: DmsAngle(true, 90, 31, 0),
        name: 'America/Guatemala'),
    TimeZone(
        countryCode: ['GS'],
        lat: DmsAngle(true, 54, 16, 0),
        long: DmsAngle(true, 36, 32, 0),
        name: 'Atlantic/South_Georgia'),
    TimeZone(
        countryCode: ['GR'],
        lat: DmsAngle(false, 37, 58, 0),
        long: DmsAngle(false, 23, 43, 0),
        name: 'Europe/Athens'),
    TimeZone(
        countryCode: ['GL'],
        lat: DmsAngle(false, 76, 34, 0),
        long: DmsAngle(true, 68, 47, 0),
        name: 'America/Thule'),
    TimeZone(
        countryCode: ['GL'],
        lat: DmsAngle(false, 70, 29, 0),
        long: DmsAngle(true, 21, 58, 0),
        name: 'America/Scoresbysund'),
    TimeZone(
        countryCode: ['GL'],
        lat: DmsAngle(false, 76, 46, 0),
        long: DmsAngle(true, 18, 40, 0),
        name: 'America/Danmarkshavn'),
    TimeZone(
        countryCode: ['GL'],
        lat: DmsAngle(false, 64, 11, 0),
        long: DmsAngle(true, 51, 44, 0),
        name: 'America/Nuuk'),
    TimeZone(
        countryCode: ['GI'],
        lat: DmsAngle(false, 36, 8, 0),
        long: DmsAngle(true, 5, 21, 0),
        name: 'Europe/Gibraltar'),
    TimeZone(
        countryCode: ['GF'],
        lat: DmsAngle(false, 4, 56, 0),
        long: DmsAngle(true, 52, 20, 0),
        name: 'America/Cayenne'),
    TimeZone(
        countryCode: ['GE'],
        lat: DmsAngle(false, 41, 43, 0),
        long: DmsAngle(false, 44, 49, 0),
        name: 'Asia/Tbilisi'),
    TimeZone(
        countryCode: ['GB', 'GG', 'IM', 'JE'],
        lat: DmsAngle(false, 51, 30, 30),
        long: DmsAngle(true, 0, 7, 31),
        name: 'Europe/London'),
    TimeZone(
        countryCode: ['FR', 'MC'],
        lat: DmsAngle(false, 48, 52, 0),
        long: DmsAngle(false, 2, 20, 0),
        name: 'Europe/Paris'),
    TimeZone(
        countryCode: ['FO'],
        lat: DmsAngle(false, 62, 1, 0),
        long: DmsAngle(true, 6, 46, 0),
        name: 'Atlantic/Faroe'),
    TimeZone(
        countryCode: ['FM'],
        lat: DmsAngle(false, 5, 19, 0),
        long: DmsAngle(false, 162, 59, 0),
        name: 'Pacific/Kosrae'),
    TimeZone(
        countryCode: ['FK'],
        lat: DmsAngle(true, 51, 42, 0),
        long: DmsAngle(true, 57, 51, 0),
        name: 'Atlantic/Stanley'),
    TimeZone(
        countryCode: ['FJ'],
        lat: DmsAngle(true, 18, 8, 0),
        long: DmsAngle(false, 178, 25, 0),
        name: 'Pacific/Fiji'),
    TimeZone(
        countryCode: ['FI', 'AX'],
        lat: DmsAngle(false, 60, 10, 0),
        long: DmsAngle(false, 24, 58, 0),
        name: 'Europe/Helsinki'),
    TimeZone(
        countryCode: ['ES'],
        lat: DmsAngle(false, 28, 6, 0),
        long: DmsAngle(true, 15, 24, 0),
        name: 'Atlantic/Canary'),
    TimeZone(
        countryCode: ['ES'],
        lat: DmsAngle(false, 35, 53, 0),
        long: DmsAngle(true, 5, 19, 0),
        name: 'Africa/Ceuta'),
    TimeZone(
        countryCode: ['ES'],
        lat: DmsAngle(false, 40, 24, 0),
        long: DmsAngle(true, 3, 41, 0),
        name: 'Europe/Madrid'),
    TimeZone(
        countryCode: ['EH'],
        lat: DmsAngle(false, 27, 9, 0),
        long: DmsAngle(true, 13, 12, 0),
        name: 'Africa/El_Aaiun'),
    TimeZone(
        countryCode: ['EG'],
        lat: DmsAngle(false, 30, 3, 0),
        long: DmsAngle(false, 31, 15, 0),
        name: 'Africa/Cairo'),
    TimeZone(
        countryCode: ['EE'],
        lat: DmsAngle(false, 59, 25, 0),
        long: DmsAngle(false, 24, 45, 0),
        name: 'Europe/Tallinn'),
    TimeZone(
        countryCode: ['EC'],
        lat: DmsAngle(true, 0, 54, 0),
        long: DmsAngle(true, 89, 36, 0),
        name: 'Pacific/Galapagos'),
    TimeZone(
        countryCode: ['EC'],
        lat: DmsAngle(true, 2, 10, 0),
        long: DmsAngle(true, 79, 50, 0),
        name: 'America/Guayaquil'),
    TimeZone(
        countryCode: ['DZ'],
        lat: DmsAngle(false, 36, 47, 0),
        long: DmsAngle(false, 3, 3, 0),
        name: 'Africa/Algiers'),
    TimeZone(
        countryCode: ['DO'],
        lat: DmsAngle(false, 18, 28, 0),
        long: DmsAngle(true, 69, 54, 0),
        name: 'America/Santo_Domingo'),
    TimeZone(
        countryCode: ['DE', 'DK', 'NO', 'SE', 'SJ'],
        lat: DmsAngle(false, 52, 30, 0),
        long: DmsAngle(false, 13, 22, 0),
        name: 'Europe/Berlin'),
    TimeZone(
        countryCode: ['CZ', 'SK'],
        lat: DmsAngle(false, 50, 5, 0),
        long: DmsAngle(false, 14, 26, 0),
        name: 'Europe/Prague'),
    TimeZone(
        countryCode: ['CY'],
        lat: DmsAngle(false, 35, 7, 0),
        long: DmsAngle(false, 33, 57, 0),
        name: 'Asia/Famagusta'),
    TimeZone(
        countryCode: ['CY'],
        lat: DmsAngle(false, 35, 10, 0),
        long: DmsAngle(false, 33, 22, 0),
        name: 'Asia/Nicosia'),
    TimeZone(
        countryCode: ['CV'],
        lat: DmsAngle(false, 14, 55, 0),
        long: DmsAngle(true, 23, 31, 0),
        name: 'Atlantic/Cape_Verde'),
    TimeZone(
        countryCode: ['CU'],
        lat: DmsAngle(false, 23, 8, 0),
        long: DmsAngle(true, 82, 22, 0),
        name: 'America/Havana'),
    TimeZone(
        countryCode: ['CR'],
        lat: DmsAngle(false, 9, 56, 0),
        long: DmsAngle(true, 84, 5, 0),
        name: 'America/Costa_Rica'),
    TimeZone(
        countryCode: ['CO'],
        lat: DmsAngle(false, 4, 36, 0),
        long: DmsAngle(true, 74, 5, 0),
        name: 'America/Bogota'),
    TimeZone(
        countryCode: ['CN', 'AQ'],
        lat: DmsAngle(false, 43, 48, 0),
        long: DmsAngle(false, 87, 35, 0),
        name: 'Asia/Urumqi'),
    TimeZone(
        countryCode: ['CN'],
        lat: DmsAngle(false, 31, 14, 0),
        long: DmsAngle(false, 121, 28, 0),
        name: 'Asia/Shanghai'),
    TimeZone(
        countryCode: ['CL'],
        lat: DmsAngle(true, 27, 9, 0),
        long: DmsAngle(true, 109, 26, 0),
        name: 'Pacific/Easter'),
    TimeZone(
        countryCode: ['CL'],
        lat: DmsAngle(true, 53, 9, 0),
        long: DmsAngle(true, 70, 55, 0),
        name: 'America/Punta_Arenas'),
    TimeZone(
        countryCode: ['CL'],
        lat: DmsAngle(true, 33, 27, 0),
        long: DmsAngle(true, 70, 40, 0),
        name: 'America/Santiago'),
    TimeZone(
        countryCode: ['CK'],
        lat: DmsAngle(true, 21, 14, 0),
        long: DmsAngle(true, 159, 46, 0),
        name: 'Pacific/Rarotonga'),
    TimeZone(
        countryCode: [
          'CI',
          'BF',
          'GH',
          'GM',
          'GN',
          'IS',
          'ML',
          'MR',
          'SH',
          'SL',
          'SN',
          'TG'
        ],
        lat: DmsAngle(false, 5, 19, 0),
        long: DmsAngle(true, 4, 2, 0),
        name: 'Africa/Abidjan'),
    TimeZone(
        countryCode: ['CH', 'DE', 'LI'],
        lat: DmsAngle(false, 47, 23, 0),
        long: DmsAngle(false, 8, 32, 0),
        name: 'Europe/Zurich'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 49, 16, 0),
        long: DmsAngle(true, 123, 7, 0),
        name: 'America/Vancouver'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 64, 4, 0),
        long: DmsAngle(true, 139, 25, 0),
        name: 'America/Dawson'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 60, 43, 0),
        long: DmsAngle(true, 135, 3, 0),
        name: 'America/Whitehorse'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 58, 48, 0),
        long: DmsAngle(true, 122, 42, 0),
        name: 'America/Fort_Nelson'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 55, 46, 0),
        long: DmsAngle(true, 120, 14, 0),
        name: 'America/Dawson_Creek'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 68, 20, 59),
        long: DmsAngle(true, 133, 43, 0),
        name: 'America/Inuvik'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 69, 6, 50),
        long: DmsAngle(true, 105, 3, 10),
        name: 'America/Cambridge_Bay'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 53, 33, 0),
        long: DmsAngle(true, 113, 28, 0),
        name: 'America/Edmonton'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 50, 17, 0),
        long: DmsAngle(true, 107, 50, 0),
        name: 'America/Swift_Current'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 50, 24, 0),
        long: DmsAngle(true, 104, 39, 0),
        name: 'America/Regina'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 62, 49, 0),
        long: DmsAngle(true, 92, 4, 59),
        name: 'America/Rankin_Inlet'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 74, 41, 44),
        long: DmsAngle(true, 94, 49, 45),
        name: 'America/Resolute'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 49, 53, 0),
        long: DmsAngle(true, 97, 9, 0),
        name: 'America/Winnipeg'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 63, 44, 0),
        long: DmsAngle(true, 68, 28, 0),
        name: 'America/Iqaluit'),
    TimeZone(
        countryCode: ['CA', 'BS'],
        lat: DmsAngle(false, 43, 39, 0),
        long: DmsAngle(true, 79, 23, 0),
        name: 'America/Toronto'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 53, 20, 0),
        long: DmsAngle(true, 60, 25, 0),
        name: 'America/Goose_Bay'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 46, 6, 0),
        long: DmsAngle(true, 64, 47, 0),
        name: 'America/Moncton'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 46, 12, 0),
        long: DmsAngle(true, 59, 57, 0),
        name: 'America/Glace_Bay'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 44, 39, 0),
        long: DmsAngle(true, 63, 36, 0),
        name: 'America/Halifax'),
    TimeZone(
        countryCode: ['CA'],
        lat: DmsAngle(false, 47, 34, 0),
        long: DmsAngle(true, 52, 43, 0),
        name: 'America/St_Johns'),
    TimeZone(
        countryCode: ['BZ'],
        lat: DmsAngle(false, 17, 30, 0),
        long: DmsAngle(true, 88, 12, 0),
        name: 'America/Belize'),
    TimeZone(
        countryCode: ['BY'],
        lat: DmsAngle(false, 53, 54, 0),
        long: DmsAngle(false, 27, 34, 0),
        name: 'Europe/Minsk'),
    TimeZone(
        countryCode: ['BT'],
        lat: DmsAngle(false, 27, 28, 0),
        long: DmsAngle(false, 89, 39, 0),
        name: 'Asia/Thimphu'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 9, 58, 0),
        long: DmsAngle(true, 67, 48, 0),
        name: 'America/Rio_Branco'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 6, 40, 0),
        long: DmsAngle(true, 69, 52, 0),
        name: 'America/Eirunepe'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 3, 8, 0),
        long: DmsAngle(true, 60, 1, 0),
        name: 'America/Manaus'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(false, 2, 49, 0),
        long: DmsAngle(true, 60, 40, 0),
        name: 'America/Boa_Vista'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 8, 46, 0),
        long: DmsAngle(true, 63, 54, 0),
        name: 'America/Porto_Velho'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 2, 26, 0),
        long: DmsAngle(true, 54, 52, 0),
        name: 'America/Santarem'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 15, 35, 0),
        long: DmsAngle(true, 56, 5, 0),
        name: 'America/Cuiaba'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 20, 27, 0),
        long: DmsAngle(true, 54, 37, 0),
        name: 'America/Campo_Grande'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 23, 32, 0),
        long: DmsAngle(true, 46, 37, 0),
        name: 'America/Sao_Paulo'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 12, 59, 0),
        long: DmsAngle(true, 38, 31, 0),
        name: 'America/Bahia'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 9, 40, 0),
        long: DmsAngle(true, 35, 43, 0),
        name: 'America/Maceio'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 7, 12, 0),
        long: DmsAngle(true, 48, 12, 0),
        name: 'America/Araguaina'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 8, 3, 0),
        long: DmsAngle(true, 34, 54, 0),
        name: 'America/Recife'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 3, 43, 0),
        long: DmsAngle(true, 38, 30, 0),
        name: 'America/Fortaleza'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 1, 27, 0),
        long: DmsAngle(true, 48, 29, 0),
        name: 'America/Belem'),
    TimeZone(
        countryCode: ['BR'],
        lat: DmsAngle(true, 3, 51, 0),
        long: DmsAngle(true, 32, 25, 0),
        name: 'America/Noronha'),
    TimeZone(
        countryCode: ['BO'],
        lat: DmsAngle(true, 16, 30, 0),
        long: DmsAngle(true, 68, 9, 0),
        name: 'America/La_Paz'),
    TimeZone(
        countryCode: ['BM'],
        lat: DmsAngle(false, 32, 17, 0),
        long: DmsAngle(true, 64, 46, 0),
        name: 'Atlantic/Bermuda'),
    TimeZone(
        countryCode: ['BG'],
        lat: DmsAngle(false, 42, 41, 0),
        long: DmsAngle(false, 23, 19, 0),
        name: 'Europe/Sofia'),
    TimeZone(
        countryCode: ['BE', 'LU', 'NL'],
        lat: DmsAngle(false, 50, 50, 0),
        long: DmsAngle(false, 4, 20, 0),
        name: 'Europe/Brussels'),
    TimeZone(
        countryCode: ['BD'],
        lat: DmsAngle(false, 23, 43, 0),
        long: DmsAngle(false, 90, 25, 0),
        name: 'Asia/Dhaka'),
    TimeZone(
        countryCode: ['BB'],
        lat: DmsAngle(false, 13, 6, 0),
        long: DmsAngle(true, 59, 37, 0),
        name: 'America/Barbados'),
    TimeZone(
        countryCode: ['AZ'],
        lat: DmsAngle(false, 40, 23, 0),
        long: DmsAngle(false, 49, 51, 0),
        name: 'Asia/Baku'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 31, 43, 0),
        long: DmsAngle(false, 128, 52, 0),
        name: 'Australia/Eucla'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 31, 57, 0),
        long: DmsAngle(false, 115, 51, 0),
        name: 'Australia/Perth'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 12, 28, 0),
        long: DmsAngle(false, 130, 50, 0),
        name: 'Australia/Darwin'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 34, 55, 0),
        long: DmsAngle(false, 138, 35, 0),
        name: 'Australia/Adelaide'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 20, 16, 0),
        long: DmsAngle(false, 149, 0, 0),
        name: 'Australia/Lindeman'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 27, 28, 0),
        long: DmsAngle(false, 153, 2, 0),
        name: 'Australia/Brisbane'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 31, 57, 0),
        long: DmsAngle(false, 141, 27, 0),
        name: 'Australia/Broken_Hill'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 33, 52, 0),
        long: DmsAngle(false, 151, 13, 0),
        name: 'Australia/Sydney'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 37, 49, 0),
        long: DmsAngle(false, 144, 58, 0),
        name: 'Australia/Melbourne'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 42, 53, 0),
        long: DmsAngle(false, 147, 19, 0),
        name: 'Australia/Hobart'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 54, 30, 0),
        long: DmsAngle(false, 158, 57, 0),
        name: 'Antarctica/Macquarie'),
    TimeZone(
        countryCode: ['AU'],
        lat: DmsAngle(true, 31, 33, 0),
        long: DmsAngle(false, 159, 5, 0),
        name: 'Australia/Lord_Howe'),
    TimeZone(
        countryCode: ['AT'],
        lat: DmsAngle(false, 48, 13, 0),
        long: DmsAngle(false, 16, 20, 0),
        name: 'Europe/Vienna'),
    TimeZone(
        countryCode: ['AS', 'UM'],
        lat: DmsAngle(true, 14, 16, 0),
        long: DmsAngle(true, 170, 42, 0),
        name: 'Pacific/Pago_Pago'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 54, 48, 0),
        long: DmsAngle(true, 68, 18, 0),
        name: 'America/Argentina/Ushuaia'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 51, 38, 0),
        long: DmsAngle(true, 69, 13, 0),
        name: 'America/Argentina/Rio_Gallegos'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 33, 19, 0),
        long: DmsAngle(true, 66, 21, 0),
        name: 'America/Argentina/San_Luis'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 32, 53, 0),
        long: DmsAngle(true, 68, 49, 0),
        name: 'America/Argentina/Mendoza'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 31, 32, 0),
        long: DmsAngle(true, 68, 31, 0),
        name: 'America/Argentina/San_Juan'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 29, 26, 0),
        long: DmsAngle(true, 66, 51, 0),
        name: 'America/Argentina/La_Rioja'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 28, 28, 0),
        long: DmsAngle(true, 65, 47, 0),
        name: 'America/Argentina/Catamarca'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 26, 49, 0),
        long: DmsAngle(true, 65, 13, 0),
        name: 'America/Argentina/Tucuman'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 24, 11, 0),
        long: DmsAngle(true, 65, 18, 0),
        name: 'America/Argentina/Jujuy'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 24, 47, 0),
        long: DmsAngle(true, 65, 25, 0),
        name: 'America/Argentina/Salta'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 31, 24, 0),
        long: DmsAngle(true, 64, 11, 0),
        name: 'America/Argentina/Cordoba'),
    TimeZone(
        countryCode: ['AR'],
        lat: DmsAngle(true, 34, 36, 0),
        long: DmsAngle(true, 58, 27, 0),
        name: 'America/Argentina/Buenos_Aires'),
    TimeZone(
        countryCode: ['AQ'],
        lat: DmsAngle(true, 72, 0, 41),
        long: DmsAngle(false, 2, 32, 6),
        name: 'Antarctica/Troll'),
    TimeZone(
        countryCode: ['AQ'],
        lat: DmsAngle(true, 67, 34, 0),
        long: DmsAngle(true, 68, 8, 0),
        name: 'Antarctica/Rothera'),
    TimeZone(
        countryCode: ['AQ'],
        lat: DmsAngle(true, 64, 48, 0),
        long: DmsAngle(true, 64, 6, 0),
        name: 'Antarctica/Palmer'),
    TimeZone(
        countryCode: ['AQ'],
        lat: DmsAngle(true, 67, 36, 0),
        long: DmsAngle(false, 62, 53, 0),
        name: 'Antarctica/Mawson'),
    TimeZone(
        countryCode: ['AQ'],
        lat: DmsAngle(true, 68, 35, 0),
        long: DmsAngle(false, 77, 58, 0),
        name: 'Antarctica/Davis'),
    TimeZone(
        countryCode: ['AQ'],
        lat: DmsAngle(true, 66, 17, 0),
        long: DmsAngle(false, 110, 31, 0),
        name: 'Antarctica/Casey'),
    TimeZone(
        countryCode: ['AM'],
        lat: DmsAngle(false, 40, 11, 0),
        long: DmsAngle(false, 44, 30, 0),
        name: 'Asia/Yerevan'),
    TimeZone(
        countryCode: ['AL'],
        lat: DmsAngle(false, 41, 20, 0),
        long: DmsAngle(false, 19, 50, 0),
        name: 'Europe/Tirane'),
    TimeZone(
        countryCode: ['AF'],
        lat: DmsAngle(false, 34, 31, 0),
        long: DmsAngle(false, 69, 12, 0),
        name: 'Asia/Kabul'),
    TimeZone(
        countryCode: ['AE', 'OM', 'RE', 'SC', 'TF'],
        lat: DmsAngle(false, 25, 18, 0),
        long: DmsAngle(false, 55, 18, 0),
        name: 'Asia/Dubai'),
    TimeZone(
        countryCode: ['AD'],
        lat: DmsAngle(false, 42, 30, 0),
        long: DmsAngle(false, 1, 31, 0),
        name: 'Europe/Andorra')
  ];
}
