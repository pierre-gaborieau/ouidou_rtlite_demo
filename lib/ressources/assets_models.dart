enum AssetsModels {
  mobileNetV3,
}

extension GetName on AssetsModels {
  String get name {
    switch (this) {
      case AssetsModels.mobileNetV3:
        return 'MobileNet V3';
    }
  }
}

extension GetPath on AssetsModels {
  String get path {
    switch (this) {
      case AssetsModels.mobileNetV3:
        return 'assets/models/mobilenet_v3.tflite';
    }
  }
}

extension GetLabelPath on AssetsModels {
  String get labelPath {
    switch (this) {
      case AssetsModels.mobileNetV3:
        return 'assets/labels/mobilenet_labels.txt';
    }
  }
}
