import 'dart:typed_data';
import 'package:image/image.dart' as Img;

class Utils {
  static Future<bool> detectIfHasCar({required Uint8List bytes}) async {
    Img.Image? image = Img.decodeImage(bytes);
    if (image == null) return false;

    var pixels = image.getBytes();
    bool hasCar = false;

    for (int i = 0, len = pixels.length; i < len; i += 4) {
      if (pixels[i] == 255 && pixels[i + 1] == 255 && pixels[i + 2] == 255) {
        hasCar = true;
        print('+++ YESSSSSS');
        break;
      }
    }

    if (!hasCar) {
      print('--- NO');
    }

    return hasCar;
  }
}
