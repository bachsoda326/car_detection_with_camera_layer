import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_layer/bndbox.dart';
import 'package:camera_layer/notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'dart:io' show Platform;

class CameraViewPage extends StatefulWidget {
  const CameraViewPage({Key? key}) : super(key: key);

  @override
  _CameraViewPageState createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  late final CameraController _controller;
  Timer? _timer;
  AccelerometerEvent? _acEvent;
  UserAccelerometerEvent? _userAcEvent;
  bool _showCar = true;
  bool _canTakePicture = false;

  List<dynamic>? _recognitions;
  bool _isDetecting = false;
  int _imageHeight = 0;
  int _imageWidth = 0;

  double _y = 125;
  double _x = 0;
  double _z = 0;
  double? _screenWidth;
  double? _screenHeight;
  double? _centerHeight;
  double? _cameraWidth;
  double? _cameraHeight;

  GlobalKey _carFrameKey = GlobalKey();
  RenderBox? _carFrameBox;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      Platform.isIOS
          ? DeviceOrientation.landscapeRight
          : DeviceOrientation.landscapeLeft,
    ]);

    // _loadModel();

    _controller = CameraController(
        context.read<CameraDescription>(), ResolutionPreset.max);
    _controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      await _controller
          .lockCaptureOrientation(DeviceOrientation.landscapeRight);
      setState(() {
        _calculateCameraSize();
      });

      // Detect car obj.
      /*_controller.startImageStream((CameraImage img) {
        if (!_isDetecting) {
          _isDetecting = true;

          Tflite.detectObjectOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            model: "SSDMobileNet",
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 127.5,
            imageStd: 127.5,
            numResultsPerClass: 1,
            threshold: 0.4,
          ).then((recognitions) {
            // int endTime = new DateTime.now().millisecondsSinceEpoch;
            // print("Detection took ${endTime - startTime}");

            // print('-*- RESULT: $recognitions');

            _setRecognitions(recognitions, img.height, img.width);

            _isDetecting = false;
          });
        }
      });*/
    });

    // Listen to device sensor changes.
    accelerometerEvents.listen((AccelerometerEvent event) {
      // print('Camera x: ${event.x}');
      // print('Camera y: ${event.y}');
      // print('Camera z: ${event.z}');
      _acEvent = event;
    });

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      // print('Camera x: ${event.x}');
      // print('Camera y: ${event.y}');
      // print('Camera z: ${event.z}');
      _userAcEvent = event;
    });

    _timer ??= Timer.periodic(Duration(milliseconds: 50), (_) {
      if (_screenWidth != null &&
          _screenHeight != null &&
          _acEvent != null &&
          _userAcEvent != null) {
        _setBarPosition();
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _controller.dispose();
    _timer?.cancel();

    super.dispose();
  }

  _checkCanTakePic() {
    if ((_y + 4 - _centerHeight!).abs() > 12 || _z.abs() > 0.25) {
      context.read<Notifier>().canTakePicture = false;
    } else {
      context.read<Notifier>().canTakePicture = true;
    }
  }

  _calculateCameraSize() {
    _screenWidth ??= MediaQuery.of(context).size.width;
    _screenHeight ??= MediaQuery.of(context).size.height;
    _centerHeight ??= (_screenHeight! / 2) + 1;

    final Size previewSize = _controller.value.previewSize!;
    final double previewHeight = previewSize.height;
    final double previewWidth = previewSize.width;
    final double screenRatio = _screenHeight! / _screenWidth!;
    final double previewRatio = previewHeight / previewWidth;

    _cameraWidth = screenRatio > previewRatio
        ? _screenHeight! / previewHeight * previewWidth
        : _screenWidth!;
    _cameraHeight = screenRatio > previewRatio
        ? _screenHeight!
        : _screenWidth! / previewWidth * previewHeight;
  }

  _loadModel() async {
    Tflite.close();
    print('Loading model');
    try {
      print('Loading model');
      final String? res = await Tflite.loadModel(
        model: "assets/tflite/ssd_mobilenet.tflite",
        labels: "assets/tflite/ssd_mobilenet.txt",
      );

      print('Load model succeeded: $res');
    } on PlatformException catch (e) {
      print('Load model failed: $e');
    }
  }

  _setRecognitions(List<dynamic>? recognitions, imageHeight, imageWidth) {
    if (mounted) {
      setState(() {
        _recognitions =
            recognitions?.where((e) => e["detectedClass"] == 'car').toList();
        _imageHeight = imageHeight;
        _imageWidth = imageWidth;
      });
    }
  }

  _setBarPosition() {
    final double eventZ = _acEvent!.z - _userAcEvent!.z;
    final double eventY = _acEvent!.y - _userAcEvent!.y;
    final double zz = double.parse(eventZ.toStringAsFixed(1));
    final double yy = double.parse(eventY.toStringAsFixed(1));

    if (mounted) {
      setState(() {
        _cameraHeight = _screenHeight;
        _cameraWidth = _screenHeight! * _controller.value.aspectRatio;

        // When x = 0 it should be centered horizontally
        // The left position should equal (width - 100) / 2
        // The greatest absolute value of x is 10, multiplying it by 12 allows the left position to move a total of 120 in either direction.
        // x = ((event.x * 12) + ((width - 100) / 2));
        // _x = (_screenWidth! - 210) / 2;
        _x = (_cameraWidth! / 2) - 30;

        // When y = 0 it should have a top position matching the target, which we set at 125
        // y = -event.y * 12 + height / 2;
        // _y = zz * 10 + _screenHeight! / 2;
        _y = zz * 6 + _cameraHeight! / 2;

        _z = -yy / 6;

        _checkCanTakePic();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    /*final keyContext = _carFrameKey.currentContext;
    if (keyContext != null) {
      // widget is visible
      _carFrameBox = keyContext.findRenderObject() as RenderBox;
    }*/

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Visibility(
            visible: _cameraWidth != null && _cameraHeight != null,
            child: Center(
              child: Container(
                width: _screenWidth,
                height: _screenHeight,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(
                      _controller,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Visibility(
                              visible: _showCar,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/car_chassis_2t.png',
                                  key: _carFrameKey,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Consumer<Notifier>(
                            builder: (_, notifier, __) => Center(
                              child: Image.asset(
                                'assets/images/circle_1t.png',
                                color: notifier.canTakePicture
                                    ? Colors.green.withOpacity(0.7)
                                    : Colors.red.withOpacity(0.7),
                                width: 200,
                                height: 200,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black,
                              ),
                              width: 90,
                              height: 2,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios),
                          ),
                          // Sensor widget.
                          Visibility(
                            visible:
                                _screenWidth != null && _screenHeight != null,
                            child: Positioned(
                              top: _y,
                              left: _x,
                              // the container has a color and is wrapped in a ClipOval to make it round
                              child: Transform(
                                alignment: FractionalOffset.center,
                                // set transform origin
                                transform: new Matrix4.rotationZ(_z),
                                // rotate -10 deg
                                child: Consumer<Notifier>(
                                  builder: (_, notifier, __) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: notifier.canTakePicture
                                          ? Colors.green
                                          : Colors.redAccent,
                                    ),
                                    width: 60,
                                    height: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          /*BndBox(
            _recognitions == null ? [] : _recognitions!,
            _imageHeight,
            _imageWidth,
            _screenHeight,
            _screenWidth,
            carFrameBox: _carFrameBox,
            canTakePicture: _canTakePicture,
            callback: (val) {
              setState(() {
                _canTakePicture = val;
              });
            },
          ),*/
          // Show car icon.
          Padding(
            padding: const EdgeInsets.only(right: 28, bottom: 24),
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _showCar = !_showCar;
                  });
                },
                iconSize: 40,
                icon: Icon(Icons.car_repair, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
