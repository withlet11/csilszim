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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../configs.dart';
import '../constants.dart';
import '../utilities/sexagesimal_angle.dart';

const _checkThreeDigit = r'^[0-9]?[0-9]?[0-9]$';
const _checkTwoDigit = r'^[0-9]?[0-9]$';

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

  late FocusNode _latNegFieldFocusNode;
  late FocusNode _latPosFieldFocusNode;
  late FocusNode _latDegFieldFocusNode;
  late FocusNode _latMinFieldFocusNode;
  late FocusNode _latSecFieldFocusNode;
  late FocusNode _longNegFieldFocusNode;
  late FocusNode _longPosFieldFocusNode;
  late FocusNode _longDegFieldFocusNode;
  late FocusNode _longMinFieldFocusNode;
  late FocusNode _longSecFieldFocusNode;

  @override
  void initState() {
    super.initState();

    _latNegFieldFocusNode = FocusNode();
    _latPosFieldFocusNode = FocusNode();
    _latDegFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_latDegFieldFocusNode.hasFocus) {
          _latDegFieldController.selection = TextSelection(
              baseOffset: 0, extentOffset: _latDegFieldController.text.length);
        } else {
          final latDeg = int.tryParse(_latDegFieldController.text);
          if (latDeg == null || latDeg < 0) {
            setState(() {
              _latitude = (_latitude ?? DmsAngle.zero).copyWith(deg: 0);
              _latDegFieldController.text = '0';
            });
          } else if (latDeg < 90) {
            _latitude = (_latitude ?? DmsAngle.zero).copyWith(deg: latDeg);
          } else {
            setState(() {
              _latitude = DmsAngle(_latitude?.isNegative ?? false, 90);
              _latDegFieldController.text = '90';
              _latMinFieldController.text = '0';
              _latSecFieldController.text = '0';
            });
          }
        }
      });
    _latMinFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_latMinFieldFocusNode.hasFocus) {
          _latMinFieldController.selection = TextSelection(
              baseOffset: 0, extentOffset: _latMinFieldController.text.length);
        } else if (_latDegFieldController.text == '90') {
          setState(() {
            _latitude = DmsAngle(_latitude?.isNegative ?? false, 90);
            _latMinFieldController.text = '0';
            _latSecFieldController.text = '0';
          });
        } else {
          final latMin = int.tryParse(_latMinFieldController.text);
          if (latMin == null || latMin < 0 || latMin > 59) {
            setState(() {
              _latitude = (_latitude ?? DmsAngle.zero).copyWith(min: 0);
              _latMinFieldController.text = '0';
            });
          } else {
            _latitude = (_latitude ?? DmsAngle.zero).copyWith(min: latMin);
          }
        }
      });

    _latSecFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_latSecFieldFocusNode.hasFocus) {
          _latSecFieldController.selection = TextSelection(
              baseOffset: 0, extentOffset: _latSecFieldController.text.length);
        } else if (_latDegFieldController.text == '90') {
          setState(() {
            _latitude = DmsAngle(_latitude?.isNegative ?? false, 90);
            _latMinFieldController.text = '0';
            _latSecFieldController.text = '0';
          });
        } else {
          final latSec = int.tryParse(_latSecFieldController.text);
          if (latSec == null || latSec < 0 || latSec > 59) {
            setState(() {
              _latitude = (_latitude ?? DmsAngle.zero).copyWith(sec: 0);
              _latSecFieldController.text = '0';
            });
          } else {
            _latitude = (_latitude ?? DmsAngle.zero).copyWith(sec: latSec);
          }
        }
      });

    _longNegFieldFocusNode = FocusNode();

    _longPosFieldFocusNode = FocusNode();

    _longDegFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_longDegFieldFocusNode.hasFocus) {
          _longDegFieldController.selection = TextSelection(
              baseOffset: 0, extentOffset: _longDegFieldController.text.length);
        } else {
          final longDeg = int.tryParse(_longDegFieldController.text);
          if (longDeg == null || longDeg < 0) {
            setState(() {
              _longitude = (_longitude ?? DmsAngle.zero).copyWith(deg: 0);
              _longDegFieldController.text = '0';
            });
          } else if (longDeg < 180) {
            _longitude = (_longitude ?? DmsAngle.zero).copyWith(deg: longDeg);
          } else {
            setState(() {
              _longitude = DmsAngle(_longitude?.isNegative ?? false, 180);
              _longMinFieldController.text = '0';
              _longSecFieldController.text = '0';
            });
          }
        }
      });
    _longMinFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_longMinFieldFocusNode.hasFocus) {
          _longMinFieldController.selection = TextSelection(
              baseOffset: 0, extentOffset: _longMinFieldController.text.length);
        } else if (_longDegFieldController.text == '180') {
          setState(() {
            _longitude = (_longitude ?? DmsAngle.zero).copyWith(min: 0, sec: 0);
            _longMinFieldController.text = '0';
            _longSecFieldController.text = '0';
          });
        } else {
          final longMin = int.tryParse(_longMinFieldController.text);
          if (longMin == null || longMin < 0 || longMin > 59) {
            setState(() {
              _longitude = (_longitude ?? DmsAngle.zero).copyWith(min: 0);
              _longMinFieldController.text = '0';
            });
          } else {
            _longitude = (_longitude ?? DmsAngle.zero).copyWith(min: longMin);
          }
        }
      });
    _longSecFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_longSecFieldFocusNode.hasFocus) {
          _longSecFieldController.selection = TextSelection(
              baseOffset: 0, extentOffset: _longSecFieldController.text.length);
        } else if (_longDegFieldController.text == '180') {
          setState(() {
            _longitude = (_longitude ?? DmsAngle.zero).copyWith(min: 0, sec: 0);
            _longMinFieldController.text = '0';
            _longSecFieldController.text = '0';
          });
        } else {
          final longSec = int.tryParse(_longSecFieldController.text);
          if (longSec == null || longSec < 0 || longSec > 59) {
            setState(() {
              _longitude = (_longitude ?? DmsAngle.zero).copyWith(sec: 0);
              _longSecFieldController.text = '0';
            });
          } else {
            _longitude = (_longitude ?? DmsAngle.zero).copyWith(sec: longSec);
          }
        }
      });
  }

  @override
  void dispose() {
    _latNegFieldFocusNode.dispose();
    _latPosFieldFocusNode.dispose();
    _latDegFieldFocusNode.dispose();
    _latMinFieldFocusNode.dispose();
    _latSecFieldFocusNode.dispose();
    _longNegFieldFocusNode.dispose();
    _longPosFieldFocusNode.dispose();
    _longDegFieldFocusNode.dispose();
    _longMinFieldFocusNode.dispose();
    _longSecFieldFocusNode.dispose();

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
              _latitude ??
                  const DmsAngle(defaultLatNeg, defaultLatDeg, defaultLatMin,
                      defaultLatSec),
              _longitude ??
                  const DmsAngle(defaultLongNeg, defaultLongDeg, defaultLongMin,
                      defaultLongSec)
            ]);
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.locationSetting),
            ),
            body: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(AppLocalizations.of(context)!.latitude,
                              textAlign: TextAlign.right),
                        ),
                      ),
                      CustomToggleButtons(
                        focusNode: [
                          _latNegFieldFocusNode,
                          _latPosFieldFocusNode
                        ],
                        value: _latitude?.isNegative ?? false,
                        negativeLabel: 'N',
                        positiveLabel: 'S',
                        onPressed: (int index) {
                          setState(() {
                            _latitude = (_latitude ?? DmsAngle.zero)
                                .copyWith(isNegative: index == 1);
                          });
                        },
                      ),
                      SizedBox(
                          width: 50,
                          child: CustomTextFormField(
                            controller: _latDegFieldController,
                            focusNode: _latDegFieldFocusNode,
                            nextNode: _latMinFieldFocusNode,
                            validator: validatorTwoDigitUnder90,
                            maxLength: 2,
                            unitSign: degSign,
                          )),
                      SizedBox(
                          width: 50,
                          child: CustomTextFormField(
                            controller: _latMinFieldController,
                            focusNode: _latMinFieldFocusNode,
                            nextNode: _latSecFieldFocusNode,
                            validator: validatorTwoDigitUnder60,
                            maxLength: 2,
                            unitSign: minSign,
                          )),
                      SizedBox(
                        width: 50,
                        child: CustomTextFormField(
                          controller: _latSecFieldController,
                          focusNode: _latSecFieldFocusNode,
                          nextNode: _longNegFieldFocusNode,
                          validator: validatorTwoDigitUnder60,
                          maxLength: 2,
                          unitSign: secSign,
                        ),
                      ),
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 80,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text(AppLocalizations.of(context)!.longitude,
                            textAlign: TextAlign.right),
                      ),
                    ),
                    CustomToggleButtons(
                      focusNode: [
                        _longNegFieldFocusNode,
                        _longPosFieldFocusNode
                      ],
                      value: _longitude?.isNegative ?? false,
                      negativeLabel: 'E',
                      positiveLabel: 'W',
                      onPressed: (int index) {
                        setState(() {
                          _longitude = (_longitude ?? DmsAngle.zero)
                              .copyWith(isNegative: index == 1);
                        });
                      },
                    ),
                    SizedBox(
                        width: 50,
                        child: CustomTextFormField(
                          controller: _longDegFieldController,
                          focusNode: _longDegFieldFocusNode,
                          nextNode: _longMinFieldFocusNode,
                          validator: validatorThreeDigit,
                          maxLength: 3,
                          unitSign: degSign,
                        )),
                    SizedBox(
                        width: 50,
                        child: CustomTextFormField(
                          controller: _longMinFieldController,
                          focusNode: _longMinFieldFocusNode,
                          nextNode: _longSecFieldFocusNode,
                          validator: validatorTwoDigitUnder60,
                          maxLength: 2,
                          unitSign: minSign,
                        )),
                    SizedBox(
                        width: 50,
                        child: CustomTextFormField(
                          controller: _longSecFieldController,
                          focusNode: _longSecFieldFocusNode,
                          nextNode: _latNegFieldFocusNode,
                          validator: validatorTwoDigitUnder60,
                          maxLength: 2,
                          unitSign: secSign,
                        )),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  String? validatorThreeDigit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a number.';
    } else if (!RegExp(_checkThreeDigit).hasMatch(value)) {
      return 'Not a number!';
    } else {
      var number = int.tryParse(value);
      if (number == null || number < 0 || number > 180) {
        return 'max 180';
      } else {
        return null;
      }
    }
  }

  String? validatorTwoDigitUnder90(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a number.';
    } else if (!RegExp(_checkTwoDigit).hasMatch(value)) {
      return 'Not a number!';
    } else {
      var number = int.tryParse(value);
      if (number == null || number < 0 || number > 90) {
        return 'max 90';
      } else {
        return null;
      }
    }
  }

  String? validatorTwoDigitUnder60(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a number.';
    } else if (!RegExp(_checkTwoDigit).hasMatch(value)) {
      return 'Not a number!';
    } else {
      var number = int.tryParse(value);
      if (number == null || number < 0 || number >= 60) {
        return 'max 60';
      } else {
        return null;
      }
    }
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextNode;
  final String? Function(String?) validator;
  final int maxLength;
  final String unitSign;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.nextNode,
    required this.validator,
    required this.maxLength,
    required this.unitSign,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.next,
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.end,
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      decoration: InputDecoration(suffix: Text(unitSign), counterText: ''),
      maxLength: maxLength,
      // validator: validator,
      onChanged: (String text) {
        if (text.length == maxLength) {
          nextNode.requestFocus();
        }
      },
      onTap: () => controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length),
    );
  }
}

class CustomToggleButtons extends StatelessWidget {
  final List<FocusNode> focusNode;
  final bool value;
  final String negativeLabel;
  final String positiveLabel;
  final void Function(int) onPressed;

  const CustomToggleButtons({
    super.key,
    required this.focusNode,
    required this.value,
    required this.negativeLabel,
    required this.positiveLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      focusNodes: focusNode,
      direction: Axis.horizontal,
      constraints: const BoxConstraints(minHeight: 10, minWidth: 20),
      borderWidth: 0.5,
      selectedColor: Colors.white,
      selectedBorderColor: Colors.white,
      color: Colors.grey,
      borderColor: Colors.grey,
      isSelected: [!value, value],
      onPressed: onPressed,
      children: [
        Text(negativeLabel, style: const TextStyle(fontSize: 18.0)),
        Text(positiveLabel, style: const TextStyle(fontSize: 18.0))
      ],
    );
  }
}
