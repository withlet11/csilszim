/*
 * star_size_on_screen.dart
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

import 'dart:math';

/// Calculates the radius of objects on the canvas with the logistic function.
///
/// [midPoint] should be calculated with [calculateMidPointOfMagnitude] once.
/// Don't calculate [midPoint] every time.
double radiusOfObject(double magnitude, double midPoint) {
  const l = 24.0;

  // r = log(sqrt((1/100)^(1/5))) ∵ magnitude 1 star is exactly 100 times
  // brighter than a magnitude 6 star, and the radius is proportional to the
  // square root of the area.
  const r = -2 * (1 / 5) * (1 / 2) / log10e;
  return l / (1 + exp(-r * (magnitude - midPoint)));
}

/// Calculates the magnitude of the faintest star that is drawn.
double faintestMagnitude(double radius, double midPoint) {
  // Same parameters with radiusOfObject()
  const l = 24.0;
  const r = -2 * (1 / 5) * (1 / 2) / log10e;
  return -log(l / radius - 1) / r + midPoint;
}

/// Calculates the mid point of the logistic function.
double calculateMidPointOfMagnitude(double magnitude, double scale) =>
    magnitude + log(scale) * 1.5;
