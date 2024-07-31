import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ObjectDetectionScreen(),
    );
  }
}

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var resultText = "";

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
          file = File(image.path);
        });
        detectImage(file!);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> detectImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      String x= recognitions.toString();
      resultText = x.contains("Dog") ? "Dog" : "Cat";
              
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        centerTitle: true,
        title: const Text(
          'Cat or Dog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_image!.path),
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Pick an image to identify',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                // primary: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text(
                'Pick Image from Gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            if (resultText.isNotEmpty)
              Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.amber,
                ),
                child: Center(
                  child: Text(
                    resultText,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
