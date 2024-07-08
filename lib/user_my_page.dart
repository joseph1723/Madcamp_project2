import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'package:http/http.dart' as http;
import 'edit_profile_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late String _name;
  late String _desc;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _name = '';
    _desc = '';
    _phoneNumber = '';
    // 사용자 로그인 정보 초기 로딩
    loadUserLogin();
  }

  Future<void> loadUserLogin() async {
    final userModelProvider = Provider.of<UserModel>(context, listen: false);
    try {
      final data = await getUserLogin(userModelProvider.userId!);
      setState(() {
        _name = data['name'] ?? '이름 없음';
        _desc = data['desc'] ?? '자기소개 없음';
        _phoneNumber = data['phonenumber'] ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사용자 정보를 가져오는 중에 오류가 발생했습니다. $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getUserLogin(String userId) async {
    String baseUrl = 'http://172.10.7.128:80'; // 서버의 기본 URL
    String url = '$baseUrl/userslogin/$userId'; // 특정 사용자 로그인 정보를 가져올 URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print('사용자 로그인 정보 가져오기 성공: $data');
        return data; // 가져온 사용자 로그인 정보 반환
      } else {
        throw Exception('사용자 로그인 정보를 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user login: $e');
      throw Exception('사용자 로그인 정보를 가져오는 도중 오류가 발생했습니다.');
    }
  }

  Future<void> updateUserLogin(String userId, String name, String desc, String phoneNumber) async {
    String baseUrl = 'http://172.10.7.128:80'; // 서버의 기본 URL
    String url = '$baseUrl/userslogin/$userId'; // 수정할 사용자의 user_id

    try {
      // 기존 사용자 정보 조회
      final getUserResponse = await http.get(Uri.parse(url));

      if (getUserResponse.statusCode != 200) {
        throw Exception('사용자 정보를 조회하는데 실패했습니다. 상태 코드: ${getUserResponse.statusCode}');
      }

      final userData = jsonDecode(getUserResponse.body);

      // 새로운 사용자 데이터 생성
      Map<String, dynamic> updatedUserData = {
        'name': name,
        'desc': desc,
        'phoneNumber': phoneNumber,
      };

      // 사용자 정보 수정 요청 (기존 데이터를 완전히 대체)
      final updateResponse = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedUserData),
      );

      if (updateResponse.statusCode == 200) {
        final updatedData = jsonDecode(updateResponse.body);
        print('사용자 로그인 정보 업데이트 성공: $updatedData');
        setState(() {
          _name = name;
          _desc = desc;
          _phoneNumber = phoneNumber;
        });
      } else {
        throw Exception('사용자 로그인 정보 업데이트에 실패했습니다. 상태 코드: ${updateResponse.statusCode}');
      }
    } catch (error) {
      print('사용자 로그인 정보 업데이트 중 오류 발생: $error');
      throw Exception('사용자 로그인 정보를 업데이트하는 도중 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModelProvider = Provider.of<UserModel>(context);
    final currentUser = userModelProvider.currentUser;
    final email = currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentUser?.displayName} 님의 프로필'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 텍스트 중앙 정렬
              children: <Widget>[
                CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('asset/img1.png'), // 로컬 이미지 경로
                ),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 시작 정렬
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Name: $_name',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Email: $email',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '전화번호: $_phoneNumber',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '자기소개: $_desc',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8DF8E), // 버튼 색상 변경
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          initialName: _name,
                          initialDesc: _desc,
                          initialPhoneNumber: _phoneNumber,
                          onSave: (String name, String desc, String phoneNumber) async {
                            try {
                              await updateUserLogin(userModelProvider.userId!, name, desc, phoneNumber);
                              // 업데이트 성공 후 작업 (예: 성공 메시지 표시)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('사용자 정보가 성공적으로 업데이트되었습니다.'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } catch (e) {
                              // 업데이트 실패 후 작업 (예: 에러 메시지 표시)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('사용자 정보 업데이트에 실패했습니다. $e'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('프로필 수정'),
                ),
                const SizedBox(height: 30),
                const Text(
                  '내가 획득한 뱃지',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                    children: <Widget>[
                      BadgeBox(imagePath: 'asset/img1.png', description: '첫 번째 뱃지'),
                      BadgeBox(imagePath: 'asset/img2.png', description: '첫 번째 뱃지'),
                      BadgeBox(imagePath: 'asset/img3.png', description: '첫 번째 뱃지'),
                      BadgeBox(imagePath: 'asset/img4.png', description: '첫 번째 뱃지'),
                      BadgeBox(imagePath: 'asset/img5.png', description: '첫 번째 뱃지'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BadgeBox extends StatelessWidget {
  final String imagePath;
  final String description; // 새로 추가된 설명 파라미터

  const BadgeBox({required this.imagePath, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFA8DF8E)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(imagePath),
          ),
          SizedBox(height: 8), // 이미지와 설명 사이의 간격
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}