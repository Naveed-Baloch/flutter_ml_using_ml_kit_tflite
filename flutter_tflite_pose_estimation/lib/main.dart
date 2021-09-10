import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  List _recognitions;
  bool selection = false;
  double _imageHeight;
  double _imageWidth;
  ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    loadModel();
    imagePicker = ImagePicker();
  }

  //TODO chose image from camera
  _imgFromCamera() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    File image = File(pickedFile.path);
    predictImage(image);
  }

  //TODO chose image gallery
  _imgFromGallery() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    File image = File(pickedFile.path);
    predictImage(image);
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
        // useGpuDelegate: true,
      );
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future predictImage(File image) async {
    if (image == null) return;
    poseNet(image);

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));
    setState(() {
      _image = image;
    });
  }

  //TODO perform inference using posenet model
  Future poseNet(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 2,
    );

    print(recognitions);

    setState(() {
      _recognitions = recognitions;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  //TODO draw points
  List<Widget> renderKeypoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();
      lists..addAll(list);
    });
    return lists;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];
    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null
          ? Center(
              child: Container(
                margin: EdgeInsets.only(top: size.height / 2 - 140),
                child: Icon(
                  Icons.image_rounded,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            )
          : Image.file(_image),
    ));
    stackChildren.addAll(renderKeypoints(size));
    stackChildren.add(
      Container(
        height: size.height,
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: _imgFromCamera,
                child: Icon(
                  Icons.camera,
                  color: Colors.black,
                ),
                color: Colors.white,
              ),
              RaisedButton(
                onPressed: _imgFromGallery,
                child: Icon(
                  Icons.image,
                  color: Colors.black,
                ),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(top: 50),
        color: Colors.black,
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}
