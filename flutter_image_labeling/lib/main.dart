import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ml_kit_image_labeling/modules/image_labling.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

//image Labling
// void main() {
//   runApp(ImageLabling());
// }

List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraImage img;
  CameraController controller;
  bool isBusy = false;
  String result = "";
  ImageLabeler labeler;

  @override
  void initState() {
    super.initState();
    labeler = GoogleMlKit.vision.imageLabeler();
  }

  //Initialize camera
  initializeCamera () async
  {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => {
        if(!isBusy){
          isBusy = true,
          img = image,
          doImageLabeling()
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


  //Write image labeling code
  doImageLabeling() async{
    setState(() {
      img;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/img2.jpg'), fit: BoxFit.fill),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                          margin: EdgeInsets.only(top: 100),
                          height: 220,
                          width : 320,
                          child: Image.asset('images/lcd2.jpg')),
                    ),
                    Center(
                      child: FlatButton(
                        child: Container(
                          margin: EdgeInsets.only(top: 118),
                          height: 177,
                          width: 310,
                          child: img == null?Container(
                            width: 140,
                            height: 150,
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                          ):AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: CameraPreview(controller),
                          ),
                        ),
                        onPressed: (){
                          initializeCamera();
                        },
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    height: 245,
                    child: SingleChildScrollView(
                        child: Text(
                          '$result',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontFamily: 'finger_paint'),
                          textAlign: TextAlign.center,
                        )),
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
