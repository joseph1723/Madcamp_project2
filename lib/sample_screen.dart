import 'package:flutter/material.dart';
import 'package:goggle_login/login_platform.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'tab1_screen.dart'; // tab1 스크린을 정의한 파일을 import합니다.
import 'google_map_screen.dart'; // google_map_screen을 import합니다.

class SampleScreen extends StatefulWidget {
  const SampleScreen({Key? key}) : super(key: key);

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
    }
  }

  void signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.google:
        await GoogleSignIn().signOut();
        break;
      case LoginPlatform.none:
        break;
    }

    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  void navigateToTab1() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Tab1Screen()), // Tab1Screen으로 이동합니다.
    );
  }

  void navigateToGoogleMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoogleMapScreen()), // GoogleMapScreen으로 이동합니다.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.tab), // 탭 아이콘 사용 가능
            onPressed: navigateToTab1, // 탭1로 이동하는 함수 호출
          ),
          IconButton(
            icon: Icon(Icons.map), // 지도 아이콘 사용 가능
            onPressed: navigateToGoogleMapScreen, // Google 지도로 이동하는 함수 호출
          ),
        ],
      ),
      body: Center(
        child: _loginPlatform != LoginPlatform.none
            ? _logoutButton()
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loginButton(
              'google',
              signInWithGoogle,
            )
          ],
        ),
      ),
    );
  }

  Widget _loginButton(String path, VoidCallback onTap) {
    return Card(
      elevation: 5.0,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink.image(
        image: AssetImage('asset/$path.png'),
        width: 60,
        height: 60,
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(35.0),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
      onPressed: signOut,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color(0xff0165E1),
        ),
      ),
      child: const Text('로그아웃'),
    );
  }
}
