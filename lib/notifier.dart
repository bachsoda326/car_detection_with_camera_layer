import 'package:flutter/cupertino.dart';

class Notifier extends ChangeNotifier {
  bool _canTakePicture = false;
  bool hasCar = false;
  bool reachGoodZone = false;

  bool get canTakePicture => _canTakePicture;

  set canTakePicture(bool val) {
    _canTakePicture = val;
    notifyListeners();
  }
}
