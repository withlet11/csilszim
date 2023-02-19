/*
 * location_setting_view.dart
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

import '../utilities/sexagesimal_angle.dart';

/// A widget of page for setting the observation location.
class LocationSettingView extends StatefulWidget {
  const LocationSettingView({super.key});

  @override
  State<LocationSettingView> createState() => _LocationSettingViewState();
}

class _LocationSettingViewState extends State<LocationSettingView> {
  DmsAngle? _latitude, _longitude;

  final _latDegFieldController = TextEditingController();
  final _latMinFieldController = TextEditingController();
  final _latSecFieldController = TextEditingController();
  final _longDegFieldController = TextEditingController();
  final _longMinFieldController = TextEditingController();
  final _longSecFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _latDegFieldController.dispose();
    _latMinFieldController.dispose();
    _latSecFieldController.dispose();
    _longDegFieldController.dispose();
    _longMinFieldController.dispose();
    _longSecFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const checkTwoDigitWithSign = r'^[+-]?[0-9]?[0-9]$';
    const checkThreeDigitWithSign = r'^[+-]?[0-9]?[0-9]?[0-9]$';
    const checkTwoDigitWithoutSign = r'^[0-9]?[0-9]$';
    // Initial values are set in the latitude field and the longitude field at
    // the first time.
    if (_latitude == null || _longitude == null) {
      List<DmsAngle> args =
          ModalRoute.of(context)?.settings.arguments as List<DmsAngle>;
      if (args.length == 2) {
        _latitude = args[0];
        _longitude = args[1];
        if (_latitude != null && _longitude != null) {
          _latDegFieldController.text = _latitude!.deg.toString();
          _latMinFieldController.text = _latitude!.min.toString();
          _latSecFieldController.text = _latitude!.sec.toString();
          _longDegFieldController.text = _longitude!.deg.toString();
          _longMinFieldController.text = _longitude!.min.toString();
          _longSecFieldController.text = _longitude!.sec.toString();
        }
      }
    }

    return Theme(
        data: ThemeData.dark(),
        child: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, <DmsAngle>[
                _latitude ?? const DmsAngle(),
                _longitude ?? const DmsAngle()
              ]);
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Location Setting"),
              ),
              body: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: _latDegFieldController,
                            textAlign: TextAlign.end,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: false),
                            decoration: const InputDecoration(
                              // hintText: "+45",
                              labelText: "latitude",
                              suffix: Text('°'),
                            ),
                            maxLength: 3,
                            validator: validatorTwoDigitWithSign,
                            onChanged: (String value) {
                              if (RegExp(checkTwoDigitWithSign)
                                  .hasMatch(value)) {
                                setState(() {
                                  final latDeg = int.tryParse(value);
                                  if (latDeg != null &&
                                      latDeg >= -90 &&
                                      latDeg <= 90) {
                                    _latitude = DmsAngle(
                                        latDeg.isNegative,
                                        latDeg.abs(),
                                        _latitude?.min ?? 0,
                                        _latitude?.sec ?? 0);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                              controller: _latMinFieldController,
                              textAlign: TextAlign.end,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: false, decimal: false),
                              decoration: const InputDecoration(
                                // hintText: "45",
                                labelText: ' ',
                                suffix: Text('′'),
                              ),
                              maxLength: 2,
                              validator: validatorTwoDigitWithoutSign,
                              onChanged: (String value) {
                                if (RegExp(checkTwoDigitWithoutSign)
                                    .hasMatch(value)) {
                                  setState(() {
                                    final latMin = int.tryParse(value);
                                    if (latMin != null &&
                                        latMin >= 0 &&
                                        latMin < 60) {
                                      _latitude = DmsAngle(
                                          _latitude?.isNegative ?? false,
                                          _latitude?.deg ?? 0,
                                          latMin,
                                          _latitude?.sec ?? 0);
                                    }
                                  });
                                }
                              }),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                              controller: _latSecFieldController,
                              textAlign: TextAlign.end,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: false, decimal: false),
                              decoration: const InputDecoration(
                                // hintText: "45",
                                labelText: ' ',
                                suffix: Text('″'),
                              ),
                              maxLength: 2,
                              validator: validatorTwoDigitWithoutSign,
                              onChanged: (String value) {
                                if (RegExp(checkTwoDigitWithoutSign)
                                    .hasMatch(value)) {
                                  setState(() {
                                    final latSec = int.tryParse(value);
                                    if (latSec != null &&
                                        latSec >= 0 &&
                                        latSec < 60) {
                                      _latitude = DmsAngle(
                                          _latitude?.isNegative ?? false,
                                          _latitude?.deg ?? 0,
                                          _latitude?.min ?? 0,
                                          latSec);
                                    }
                                  });
                                }
                              }),
                        ),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _longDegFieldController,
                          textAlign: TextAlign.end,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: false),
                          decoration: const InputDecoration(
                            // hintText: "+123",
                            labelText: "longitude",
                            suffix: Text('°'),
                          ),
                          maxLength: 4,
                          validator: validatorThreeDigitWithSign,
                          onChanged: (String value) {
                            if (RegExp(checkThreeDigitWithSign)
                                .hasMatch(value)) {
                              setState(() {
                                final longDeg = int.tryParse(value);
                                if (longDeg != null &&
                                    longDeg >= -180 &&
                                    longDeg <= 180) {
                                  _longitude = DmsAngle(
                                      longDeg.isNegative,
                                      longDeg,
                                      _longitude?.min ?? 0,
                                      _longitude?.sec ?? 0);
                                }
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _longMinFieldController,
                          textAlign: TextAlign.end,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: const InputDecoration(
                            // hintText: "12",
                            labelText: ' ',
                            suffix: Text('′'),
                          ),
                          maxLength: 2,
                          validator: validatorTwoDigitWithoutSign,
                          onChanged: (String value) {
                            if (RegExp(checkTwoDigitWithoutSign)
                                .hasMatch(value)) {
                              setState(() {
                                final longMin = int.tryParse(value);
                                if (longMin != null &&
                                    longMin >= 0 &&
                                    longMin < 60) {
                                  _longitude = DmsAngle(
                                      _longitude?.isNegative ?? false,
                                      _longitude?.deg ?? 0,
                                      longMin,
                                      _longitude?.sec ?? 0);
                                }
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _longSecFieldController,
                          textAlign: TextAlign.end,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: const InputDecoration(
                            // hintText: "00",
                            labelText: ' ',
                            suffix: Text('″'),
                          ),
                          maxLength: 2,
                          validator: validatorTwoDigitWithoutSign,
                          onChanged: (String value) {
                            if (RegExp(checkTwoDigitWithoutSign)
                                .hasMatch(value)) {
                              setState(() {
                                final longSec = int.tryParse(value);
                                if (longSec != null &&
                                    longSec >= 0 &&
                                    longSec < 60) {
                                  _longitude = DmsAngle(
                                      _longitude?.isNegative ?? false,
                                      _longitude?.deg ?? 0,
                                      _longitude?.min ?? 0,
                                      longSec);
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }

  String? validatorThreeDigitWithSign(String? value) {
    const checkThreeDigitWithSign = r'^[+-]?[0-9]?[0-9]?[0-9]$';
    if (value == null || value.isEmpty) {
      return 'Please enter a number.';
    } else if (!RegExp(checkThreeDigitWithSign).hasMatch(value)) {
      return 'This in not a number!';
    } else {
      var number = int.tryParse(value);
      if (number == null || number < -180 || number > 180) {
        return 'This is out of range!';
      } else {
        return null;
      }
    }
  }

  String? validatorTwoDigitWithSign(String? value) {
    const checkTwoDigitWithSign = r'^[+-]?[0-9]?[0-9]$';
    if (value == null || value.isEmpty) {
      return 'Please enter a number.';
    } else if (!RegExp(checkTwoDigitWithSign).hasMatch(value)) {
      return 'This is not a number!';
    } else {
      var number = int.tryParse(value);
      if (number == null || number < -90 || number > 90) {
        return 'This is out of range!';
      } else {
        return null;
      }
    }
  }

  String? validatorTwoDigitWithoutSign(String? value) {
    const checkTwoDigitWithoutSign = r'^[0-9]?[0-9]$';
    if (value == null || value.isEmpty) {
      return 'Please enter a number.';
    } else if (!RegExp(checkTwoDigitWithoutSign).hasMatch(value)) {
      return 'This in not a number!';
    } else {
      var number = int.tryParse(value);
      if (number == null || number < 0 || number >= 60) {
        return 'This is out of range!';
      } else {
        return null;
      }
    }
  }
}
