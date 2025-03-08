import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloorTwoView extends StatelessWidget {
  const FloorTwoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon:const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
    );
  }
}
