import 'package:flutter/material.dart';
import 'sample_screen.dart'; // SampleScreen을 정의한 파일을 import합니다.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleScreen(), // SampleScreen을 초기 화면으로 설정합니다.
    );
  }
}
