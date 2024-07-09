import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'point_list_provider.dart'; // PointListProvider 파일을 import합니다.
import 'sample_screen.dart'; // SampleScreen을 정의한 파일을 import합니다.
import 'user_model.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(create: (context) => PointListProvider()),
      ],
      child: MyApp(),
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
        scaffoldBackgroundColor: Colors.white,
        fontFamily: '교보',
        appBarTheme: AppBarTheme(color: Colors.white,),
      ),
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/background.png'), 
            fit: BoxFit.cover, // 이미지가 화면에 맞게 조정됨
          ),
        ),
        child: AnimatedSplashScreen(
          splash: Image.asset('asset/splash_logo.png'),
          nextScreen: const SampleScreen(),
          splashTransition: SplashTransition.rotationTransition,
          duration: 1500,
          splashIconSize: 200,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
