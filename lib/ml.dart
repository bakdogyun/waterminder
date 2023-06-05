import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class Model {
  final amountModel = 'assets/amount.tflite';
  final timeModel = 'assets/test.tflite';
  List input = [
    [1],
    [0],
    [0],
    [0],
    [1],
    [1],
    [1],
    [1],
    [1],
    [1],
    [0],
    [1],
    [1],
    [0],
    [1],
    [1],
    [0],
    [1],
    [0],
    [1],
    [1],
    [1],
    [1],
    [1],
  ];

  late Interpreter interpreter;
  Model(String type) {
    _setUp(type);
  }

  void _setUp(String type) async {
    if (type == 'amount') {
      test2();
    } else if (type == 'time') {
      test();
    }
  }

  void test2() async {
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

  void test() async {
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
    var output = List<double>.filled(24, 0);
    //interpreter.run(input, output);

    return output;
  }

  List inferAmount(List input) {
    var output = List<double>.filled(1, 1).reshape([1, 1]);
    interpreter.run(input, output);
    return output;
  }
}
