import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class ImageLabling extends StatefulWidget {
  ImageLabling({Key key}) : super(key: key);

  @override
  _ImageLablingState createState() => _ImageLablingState();
}

class _ImageLablingState extends State<ImageLabling> {
  ImagePicker imagePicker;
  File _image;
  String result = '';
  ImageLabeler imageLabeler;
  TextDetector textDetector;

  //TODO declare ImageLabeler
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textDetector = GoogleMlKit.vision.textDetector();
    imageLabeler = GoogleMlKit.vision.imageLabeler();
    imagePicker = ImagePicker();
    //TODO initialize labeler
  }

  _imgFromCamera() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    _image = File(pickedFile.path);
    setState(() {
      _image;
    });
    doImageLabeling();
  }

  _imgFromGallery() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    _image = File(pickedFile.path);
    setState(() {
      _image;
    });
    doImageLabeling();
  }

  @override
  void dispose() {
    imageLabeler.close();
  } //TODO image labeling code here

  doImageLabeling() async {
    final inputImage = InputImage.fromFile(_image);
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);
    setState(() {
      result = "";
      result = recognisedText.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/img2.jpg'), fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 100),
                    child: Stack(children: <Widget>[
                      Stack(children: <Widget>[
                        Center(
                          child: Image.asset(
                            'images/frame3.png',
                            height: 210,
                            width: 200,
                          ),
                        ),
                      ]),
                      Center(
                        child: TextButton(
                          onPressed: _imgFromGallery,
                          onLongPress: _imgFromCamera,
                          child: Container(
                            margin: EdgeInsets.only(top: 8),
                            child: _image != null
                                ? Image.file(
                                    _image,
                                    width: 135,
                                    height: 195,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    width: 140,
                                    height: 150,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    '$result',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'finger_paint', fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
