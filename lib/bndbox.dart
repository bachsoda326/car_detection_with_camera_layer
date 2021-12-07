import 'package:camera_layer/notifier.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class BndBox extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final RenderBox? carFrameBox;

  const BndBox(
    this.results,
    this.previewH,
    this.previewW,
    this.screenH,
    this.screenW, {
    required this.carFrameBox,
  });

  @override
  Widget build(BuildContext context) {
    final double emptyWidthSpace =
        (MediaQuery.of(context).size.width - screenW) / 2;

    // Check with car wireframe.
    _checkIfCanTakePicture(
        double left, double top, double right, double bottom) {
      if (carFrameBox != null) {
        final pos = carFrameBox!.localToGlobal(Offset.zero);
        final double leftBox = pos.dx;
        final double topBox = pos.dy;
        final double rightBox = pos.dx + carFrameBox!.size.width;
        final double bottomBox = pos.dy + carFrameBox!.size.height;
        final Notifier notifier = context.read<Notifier>();

        // Outside car frame.
        if (left < leftBox ||
            top < topBox ||
            right > rightBox ||
            bottom > bottomBox) {
          if (notifier.canTakePicture) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              notifier.canTakePicture = false;
            });
          }
        }
        // Inside car frame.
        else {
          if (!notifier.canTakePicture) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              notifier.canTakePicture = true;
            });
          }
        }
      }
    }

    // Check if center.
    _checkIfCarIsCenter(double left, double top, double right, double bottom) {
      final Notifier notifier = context.read<Notifier>();

      // Outside car frame.
      if (notifier.reachGoodZone) {
        // print('$left - $top - $right - $bottom');
        if (left < emptyWidthSpace + 24 ||
            top < 8 ||
            right > screenW + emptyWidthSpace - 24 ||
            bottom > screenH - 8) {
          if (notifier.hasCar) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              notifier.hasCar = false;
              print('-- OUTSIDE');
            });
          }
        }
        // Inside car frame.
        else {
          if (!notifier.hasCar) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              notifier.hasCar = true;
              print('-- IN');
            });
          }
        }
      }
    }

    List<Widget> _renderCarBox() {
      return results.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var scaleW, scaleH, x, y, w, h;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW + emptyWidthSpace;
          w = _w * scaleW;
          if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
          y = _y * scaleH;
          h = _h * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          w = _w * scaleW;
          y = (_y - difH / 2) * scaleH;
          h = _h * scaleH;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        }

        final double left = math.max(0, x);
        final double top = math.max(0, y);
        final double right = left + w;
        final double bottom = top + h;

        // _checkIfCanTakePicture(left, top, right, bottom);
        _checkIfCarIsCenter(left, top, right, bottom);

        return Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: Container(
            // padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }

    /*List<Widget> _renderBoxes() {
      return results.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var scaleW, scaleH, x, y, w, h;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          w = _w * scaleW;
          if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
          y = _y * scaleH;
          h = _h * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          w = _w * scaleW;
          y = (_y - difH / 2) * scaleH;
          h = _h * scaleH;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        }

        return Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }*/

    return Stack(
      children: _renderCarBox(),
    );
  }
}
