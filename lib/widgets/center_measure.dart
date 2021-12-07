import 'package:camera_layer/constants.dart';
import 'package:camera_layer/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CenterMeasure extends StatelessWidget {
  const CenterMeasure({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Notifier>(builder: (_, notifier, __) {
      final Color _color = notifier.canTakePicture ? color : Colors.white;

      return Row(
        children: [
          Expanded(child: Divider(color: _color, thickness: 1)),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1, color: _color),
            ),
          ),
          Expanded(child: Divider(color: _color, thickness: 1)),
        ],
      );
    });
  }
}
