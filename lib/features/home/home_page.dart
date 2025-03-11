import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ouidou_rtlite_demo/helpers/image_classification_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ImagePicker imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;
  ImageClassificationHelper? imageClassificationHelper;

  @override
  void initState() {
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Ouidou RTLite",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final label = classification?.keys.elementAt(index);
                  final confidence = classification?[label];
                  return ListTile(
                    title: Text(label ?? "Unknown"),
                    subtitle: Text(
                      confidence != null
                          ? "${(confidence * 100).toStringAsFixed(2)}%"
                          : "No confidence",
                    ),
                  );
                },
                itemCount: classification?.length ?? 0,
                shrinkWrap: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 9.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text("Pick an Image"),
                  ),
                  OutlinedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: const Text("Take an Image"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _pickImage(ImageSource source) async {
    cleanResult();
    final result = await imagePicker.pickImage(
      source: source,
    );

    imagePath = result?.path;
    setState(() {});
    processImage();
  }

  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }

  Future<void> processImage() async {
    if (imagePath != null) {
      final imageData = File(imagePath!).readAsBytesSync();

      image = img.decodeImage(imageData);
      setState(() {});
      classification = await imageClassificationHelper?.inferenceImage(image!);
      if (classification != null) {
        // Sort the classification results by confidence and where confidence is sufficient( >= 1%)
        classification = Map.fromEntries(
          classification!.entries.where((entry) => entry.value >= 0.01).toList()
            ..sort((a, b) => b.value.compareTo(a.value)),
        );
      }
      setState(() {});
    }
  }
}
