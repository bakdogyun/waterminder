import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';

class Model {
  final amountModel = 'assets/amount.tflite';
  final timeModel = 'assets/test.tflite';

  late Interpreter interpreter;
  Model(String type) {
    _setUp(type);
  }

  void _setUp(String type) async {
    if (type == 'amount') {
      setAmount();
    } else if (type == 'time') {
      setTime();
    }
  }

  void setAmount() async {
    final options = InterpreterOptions();

    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    interpreter = await Interpreter.fromAsset(amountModel, options: options);
    print('amount model is ready');
  }

  void setTime() async {
    final options = InterpreterOptions();

    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    interpreter = await Interpreter.fromAsset(timeModel, options: options);
    print('time model is ready');
  }

  List inferTime(List input) {
    var output = List<double>.filled(24, 0).reshape([24, 1]);
    interpreter.run(input, output);
    List<double> outputEnhanced = [];
    var timeList = List<int>.filled(24, 0);
    for (int i = 0; i < 24; i++) {
      outputEnhanced.add(output[i][0]);
    }
    var maxVal = outputEnhanced.reduce(max);
    for (int i = 0; i < 24; i++) {
      outputEnhanced[i] = outputEnhanced[i] / maxVal;
      if (outputEnhanced[i] >= 0.5) {
        timeList[i] = 1;
      }
    }

    return timeList;
  }

  List inferAmount(List input) {
    var output = List<double>.filled(1, 1).reshape([1, 1]);
    interpreter.run(input, output);
    return output;
  }
}
