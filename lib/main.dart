import 'package:flutter/material.dart';
import 'package:remotemouse/find_devices.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Devices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FindDevicesScreen(),
    );
  }
}
