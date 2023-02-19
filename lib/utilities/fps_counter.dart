/*
 * fps_counter.dart
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

class FpsCounter {
  int _previousMicroSeconds;
  int _frameCount;
  int _previousFps;

  FpsCounter()
      : _previousMicroSeconds = DateTime.now().microsecondsSinceEpoch,
        _frameCount = 0,
        _previousFps = 0;

  int countFps() {
    if (_frameCount < 10) {
      ++_frameCount;
    } else {
     final currentMicroseconds = DateTime.now().microsecondsSinceEpoch;
      _previousFps =
          _frameCount * 1e6 ~/ (currentMicroseconds - _previousMicroSeconds);
      _previousMicroSeconds = currentMicroseconds;
      _frameCount = 0;
    }
    return _previousFps;
  }
}
