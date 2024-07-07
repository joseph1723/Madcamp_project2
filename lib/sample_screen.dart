import 'package:flutter/material.dart';
import 'package:goggle_login/login_platform.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'tab1_screen.dart'; // tab1 스크린을 정의한 파일을 import합니다.
import 'google_map_screen.dart'; // google_map_screen을 import합니다.
import 'theme_screen.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  LoginPlatform _loginPlatform = LoginPlatform.none;
  GoogleSignInAccount? _currentUser;

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      //어디에 띄워?
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

  //하단바 만들어서 넣기
  void navigateToTab1() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const Tab1Screen()), // Tab1Screen으로 이동합니다.
    );
  }

  void navigateToGoogleMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GoogleMapScreen()), // GoogleMapScreen으로 이동합니다.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('산책꼬?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tab), // 탭 아이콘 사용 가능
            onPressed: navigateToTab1, // 탭1로 이동하는 함수 호출
          ),
          IconButton(
            icon: const Icon(Icons.map), // 지도 아이콘 사용 가능
            onPressed: navigateToGoogleMapScreen, // Google 지도로 이동하는 함수 호출
          ),
          if (_loginPlatform != LoginPlatform.none)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: signOut,
            ),
        ],
      ),
      body: Center(
          child: _loginPlatform != LoginPlatform.none
              ? _mainContent()
              : _loginButton('login', signInWithGoogle)),
    );
  }

  Widget _loginButton(String path, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(0),
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
            image: AssetImage('asset/$path.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300.0, maxHeight: 60.0),
          alignment: Alignment.center,
          child: null,
        ),
      ),
    );
  }
  // Widget _loginButton(String path, VoidCallback onTap) {
  //   return Card(
  //     elevation: 5.0,
  //     shape: const CircleBorder(),
  //     clipBehavior: Clip.antiAlias,
  //     child: Ink.image(
  //       image: AssetImage('asset/$path.png'),
  //       width: 60,
  //       height: 60,
  //       child: InkWell(
  //         borderRadius: const BorderRadius.all(
  //           Radius.circular(35.0),
  //         ),
  //         onTap: onTap,
  //       ),
  //     ),
  //   );
  // }

  // Widget _logoutButton() {
  //   return ElevatedButton(
  //     onPressed: signOut,
  //     style: ButtonStyle(
  //       backgroundColor: MaterialStateProperty.all(
  //         const Color(0xff0165E1),
  //       ),
  //     ),
  //     child: const Text('로그아웃'),
  //   );
  // }
  Widget _mainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _currentUser?.displayName ?? "User",
                style: const TextStyle(
                  color: Color(0xFFA8DF8E),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              const TextSpan(
                text: '님 안녕하세요!\n오늘도 즐거운 산책을 시작해볼까요?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          '오늘의 추천 테마',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _themeBox('Theme 1', () {
              // Navigate to the new screen for Theme 1
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ThemeScreen(theme: 'Theme 1')),
              );
            }),
            _themeBox('Theme 2', () {
              // Navigate to the new screen for Theme 2
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ThemeScreen(theme: 'Theme 2')),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _themeBox(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 149,
        height: 187,
        color: Colors.grey,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
