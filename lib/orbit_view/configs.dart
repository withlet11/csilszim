/*
 * configs.dart
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

const oneYear = 365.25;
const initialZoom = 50.0;
const initialInterval = oneYear;
const initialRepetition = 10;
const zoomingRate1 = 1.2589254117941673; // pow(10, 0.1)
const zoomingRate2 = 1.01157945426; // pow(10, 0.001)

const backgroundColor = Color(0xff192029);

const planetColor = {
  'mercury': Color(0xffffd7a0),
  'venus': Color(0xfffaaf3c),
  'earth': Color(0xff37aae1),
  'mars': Color(0xffff5050),
  'jupiter': Color(0xffb9beb4),
  'saturn': Color(0xffc8a05f),
  'uranus': Color(0xffa0c8fa),
  'neptune': Color(0xff3232e1),
};

const dwarfPlanetColor = {
  'ceres': Color(0xffffd7a0),
  'pluto': Color(0xfffaaf3c),
  'eris': Color(0xff37aae1),
  'haumea': Color(0xffff5050),
  'makemake': Color(0xffb9beb4),
};

