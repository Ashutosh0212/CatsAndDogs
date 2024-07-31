// import 'dart:convert';
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
  var v = "";
  // var dataList = [];
  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future detectimage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();
      // dataList = List<Map<String, dynamic>>.from(jsonDecode(v));
    });
    print(_recognitions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        centerTitle: true,
        title: const Text(
          'Cat Or Dog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 179, 138, 249),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_image!.path),
                    height: 300,
                    width: 300,
                    fit: BoxFit.fill,
                  ),
                ),
              )
            else
              Container(
                  // color: const Color.fromARGB(255, 172, 124, 255),
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 179, 138, 249),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                    child: Text(
                      'Pick an image to identify',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  )),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image from Gallery'),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.amber),
              child: Center(
                  child: Text(
                v.contains("Dog") ? "Dog" : "Cat",
                style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              )),
            ),
            // Text(v),
          ],
        ),
      ),
    );
  }
}
