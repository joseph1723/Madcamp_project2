import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:goggle_login/login_platform.dart';
import 'package:goggle_login/point_details_screen.dart';
import 'package:goggle_login/point_list_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'point_list.dart'; // tab1 스크린을 정의한 파일을 import합니다.
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

      final String token = googleUser.email; // 예시로 email을 token으로 사용

      // 토큰을 이용하여 id를 가져오는 함수 호출
      await getIdByToken(token);
      // Get the authentication object
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Print the access token
      print('Access token = ${googleAuth.accessToken}');
      print('ID token = ${googleAuth.idToken}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
    }
  }
  Future<void> getIdByToken(String token) async {
    const String baseUrl = 'http://172.10.7.128:80'; // 서버의 기본 URL
    final String url = '$baseUrl/tokenstoid/$token';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var userId = "";
        if(data == null){
          userId = await tokentoid(token);
        }
        else {
          userId = data['user_id'] as String;
        }
        if (userId != null) {
          print('Returned id: $userId');
          // 여기에서 id를 활용하여 추가적인 작업을 수행할 수 있습니다.
        } else {
          print('User id not found.');
        }
      } else {
        print('Failed to get user id. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user id: $e');
    }
  }

  Future<String> tokentoid(String token) async {
    const String url = 'http://172.10.7.128:80/tokenstoid'; // 포인트를 추가할 엔드포인트 URL

    try {
      // 포인트 리스트 생성하기
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': token,
          'user_id': token.split('@gmail')[0],
        }),
      );

      if (response.statusCode == 201) {
        var result = jsonDecode(response.body);
        print('Token added successfully');
        return(token.split('@gmail')[0]);
      } else {
        print('Failed to add token. Status code: ${response.statusCode}');
        throw Exception('Failed to add user id');
      }
    } catch (error) {
      print('Error adding token: $error');
      throw Exception('Failed to add user id');
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
              ? _mainContent(context)
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
  
  Widget _mainContent(BuildContext context) {

    final pointListProvider = Provider.of<PointListProvider>(context);
    final pointList = pointListProvider.pointList;
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
        pointList != null ? _buildPointList(pointList) : _buildThemeBox(),
        // const Text(
        //   '오늘의 추천 테마',
        //   style: TextStyle(fontSize: 16),
        // ),
        // const SizedBox(height: 20),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     _themeBox('Theme 1', () {
        //       // Navigate to the new screen for Theme 1
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => const ThemeScreen(theme: 'Theme 1')),
        //       );
        //     }),
        //     _themeBox('Theme 2', () {
        //       // Navigate to the new screen for Theme 2
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => const ThemeScreen(theme: 'Theme 2')),
        //       );
        //     }),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildPointList(Map<String, dynamic> pointList) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Point List',
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 20),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: pointList['points'].map<Widget>((point) {
            return _pointBox(point);
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _pointBox(Map<String, dynamic> point) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PointDetail(point: point),
        ),
      );
    },
    child: Container(
      width: 149,
      height: 187,
      color: Colors.grey,
      margin: EdgeInsets.only(right: 10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              point['name'],
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'ID: ${point['_id']}',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildThemeBox() {
    return Column(
      children: [
        Text(
          '오늘의 추천 테마',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _themeBox('Theme 1', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeScreen(theme: 'Theme 1')),
              );
            }),
            _themeBox('Theme 2', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeScreen(theme: 'Theme 2')),
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
