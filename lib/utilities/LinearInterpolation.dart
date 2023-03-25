/*
 * linear_interpolation.dart
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

/// Calculations values with linear interpolation
///
/// xList is required to be sorted with descending
class LinearInterpolation {
  final List<double> xList;

  const LinearInterpolation(this.xList);

  // Linear interpolation (LERP: Linear intERPolation)
  double lerp(List<double> yList, double x) {
    final index = xList.indexWhere((value) => value <= x);
    switch (index) {
      case -1:
        return yList.last;
      case 0:
        return yList.first;
      default:
        final x0 = xList[index - 1];
        final x1 = xList[index];
        final y0 = yList[index - 1];
        final y1 = yList[index];
        final m = (x - x1) / (x0 - x1);
        final n = 1 - m;
        return m * y0 + n * y1;
    }
  }

  double closest(List<double> yList, double x) {
    final index = xList.indexWhere((value) => value >= x);
    switch (index) {
      case -1:
        return yList.last;
      case 0:
        return yList.first;
      default:
        final x0 = xList[index - 1];
        final x1 = xList[index];
        return (x - x0 < x1 - x) ? yList[index - 1] : yList[index];
    }
  }
}
