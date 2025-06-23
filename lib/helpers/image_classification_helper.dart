import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:ouidou_rtlite_demo/ressources/assets_models.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'isolate_inference.dart';

class ImageClassificationHelper {
  String modelPath = AssetsModels.mobileNetV3.path;
  String labelPath = AssetsModels.mobileNetV3.labelPath;

  late final Interpreter interpreter;
  List<String>? _labels;
  late final IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  Future<void> initHelper() async {
    await _loadLabels();
    await _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  Future<void> _loadModel() async {
    final options = InterpreterOptions()..addDelegate(XNNPackDelegate());

    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    inputTensor = interpreter.getInputTensor(0);
    outputTensor = interpreter.getOutputTensor(0);
  }

  Future<void> _loadLabels() async {
    final labelsRaw = await rootBundle.loadString(labelPath);
    _labels = labelsRaw.split('\n');
  }

  Future<Map<String, double>> inferenceImage(img.Image image) async {
    var isolateModel = InferenceModel(image, interpreter.address, _labels!,
        inputTensor.shape, outputTensor.shape);
    return _inference(isolateModel);
  }

  Future<Map<String, double>> _inference(InferenceModel inferenceModel) async {
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort
        .send(inferenceModel..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }
}
