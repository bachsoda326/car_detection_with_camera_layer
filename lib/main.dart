import 'package:camera/camera.dart';
import 'package:camera_layer/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final List<CameraDescription> cameras = await availableCameras();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MyApp(cameras.first)));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp(this.camera);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: camera,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Camera',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomePage(),
      ),
    );
  }
}
