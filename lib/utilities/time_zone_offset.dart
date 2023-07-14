/*
 * time_zone_offset.dart
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

import '../constants.dart';

class TimeZoneOffset {
  final Duration offset;

  const TimeZoneOffset(this.offset);

  @override
  String toString() {
    if (offset == Duration.zero) {
      return 'UTC±00:00:00';
    }
    final string = offset.toString();
    if (offset.isNegative) {
      const prefix = 'UTC$minusSign';
      return prefix +
          (string[2] == ':'
              ? '0${string.substring(1, 8)}'
              : string.substring(1, 9));
    } else {
      const prefix = 'UTC+';
      return prefix +
          (string[1] == ':'
              ? '0${string.substring(0, 7)}'
              : string.substring(0, 8));
    }
  }
}
