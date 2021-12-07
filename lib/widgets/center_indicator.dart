import 'package:camera_layer/constants.dart';
import 'package:camera_layer/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CenterIndicator extends StatelessWidget {
  const CenterIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Notifier>(
      builder: (_, notifier, __) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: notifier.canTakePicture
              ? color.withOpacity(0.5)
              : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
