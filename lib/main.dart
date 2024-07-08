import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'point_list_provider.dart'; // PointListProvider 파일을 import합니다.
import 'sample_screen.dart'; // SampleScreen을 정의한 파일을 import합니다.

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PointListProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SampleScreen(), // SampleScreen을 초기 화면으로 설정합니다.
    );
  }
}
