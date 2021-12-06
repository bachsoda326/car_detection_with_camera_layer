import 'package:camera_layer/camera_view_page.dart';
import 'package:camera_layer/notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  _loadModel() async {
    Tflite.close();
    try {
      final String? res = await Tflite.loadModel(
        // model: "assets/tflite/ssd_mobilenet.tflite",
        model: "assets/tflite/lite-model_deeplabv3-mobilenetv2_dm05_1_default_2.tflite",
        // labels: "assets/tflite/ssd_mobilenet.txt",
        labels: "assets/tflite/deeplabv3_257_mv_gpu.txt",
      );

      setState(() {});
      print('Load model succeeded: $res');
    } on PlatformException catch (e) {
      print('Load model failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomePage')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                    create: (_) => Notifier(), child: CameraViewPage())),
          );
        },
        child: Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}
