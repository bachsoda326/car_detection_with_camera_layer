import 'package:flutter/cupertino.dart';

class Notifier extends ChangeNotifier {
  bool _canTakePicture = false;
  bool reachGoodZone = false;
  bool hasCar = false;
  bool isTooFar = false;
  bool isTooClose = false;
  bool isCenter = false;

  bool get canTakePicture => _canTakePicture;

  set canTakePicture(bool val) {
    _canTakePicture = val;
    notifyListeners();
  }

  String getGuideMessage () {
    String message = '';

    if (!reachGoodZone) {
      message = 'Move the camera to center';
    } else if (!hasCar) {
      message = 'Position your car inside the camera';
    } else if (isTooFar) {
      message = 'Move camera closer';
    } else if (isTooClose) {
      message = 'Move camera further';
    } else if (!isCenter) {
      message = 'Align your car in the center';
    }

    return message;
  }
}
