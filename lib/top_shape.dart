import 'package:flutter/material.dart';

class TopShape extends StatelessWidget {
  const TopShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        'assets/Group.png',
        fit: BoxFit.contain,
        width: double.infinity,
      ),
    );
  }
}
