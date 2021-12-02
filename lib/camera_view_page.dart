import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraViewPage extends StatefulWidget {
  const CameraViewPage({Key? key}) : super(key: key);

  @override
  _CameraViewPageState createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  late final CameraController _controller;
  Timer? _timer;
  late AccelerometerEvent _acEvent;
  bool _showCar = true;

  double _y = 125;
  double _x = 0;
  double _z = 0;
  double _width = 0;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);

    _controller = CameraController(
        context.read<CameraDescription>(), ResolutionPreset.max);
    _controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      await _controller.lockCaptureOrientation();
      setState(() {});
    });

    // Listen to device sensor changes.
    accelerometerEvents.listen((AccelerometerEvent event) {
      // print('Camera x: ${event.x}');
      // print('Camera y: ${event.y}');
      // print('Camera z: ${event.z}');
      _acEvent = event;
    });

    _timer ??= Timer.periodic(Duration(milliseconds: 50), (_) {
      _setBarPosition(_acEvent);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _controller.dispose();

    super.dispose();
  }

  _setBarPosition(AccelerometerEvent event) {
    final double zz = double.parse(event.z.toStringAsFixed(1));
    final double yy = double.parse(event.y.toStringAsFixed(1));

    if (mounted) {
      setState(() {
        // When x = 0 it should be centered horizontally
        // The left position should equal (width - 100) / 2
        // The greatest absolute value of x is 10, multiplying it by 12 allows the left position to move a total of 120 in either direction.
        // x = ((event.x * 12) + ((width - 100) / 2));
        _x = (_width - 210) / 2;

        // When y = 0 it should have a top position matching the target, which we set at 125
        // y = -event.y * 12 + height / 2;
        _y = zz * 10 + _height / 2;

        _z = -yy / 10;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        right: false,
        bottom: false,
        child: Stack(
          children: [
            CameraPreview(
              _controller,
              child: Stack(
                children: [
                  Visibility(
                    visible: _showCar,
                    child: Center(
                      child: Image.asset(
                        'assets/images/car_chassis_2t.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/circle_1t.png',
                      color: Colors.red.withOpacity(0.7),
                      width: 200,
                      height: 200,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  // Sensor widget.
                  Positioned(
                    top: _y,
                    left: _x,
                    // the container has a color and is wrapped in a ClipOval to make it round
                    child: Transform(
                      alignment: FractionalOffset.center,
                      // set transform origin
                      transform: new Matrix4.rotationZ(_z),
                      // rotate -10 deg
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.redAccent,
                        ),
                        width: 60,
                        height: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      ),
    );
  }
}
