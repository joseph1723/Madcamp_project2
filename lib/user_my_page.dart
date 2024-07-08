import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'package:http/http.dart' as http;
import 'edit_profile_page.dart'; // 수정 화면을 import

class MyProfilePage extends StatefulWidget {
  MyProfilePage();

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
          duration: Duration(seconds: 3),
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
    final current_user = userModelProvider.currentUser;
    final photoUrl = current_user?.photoUrl;
    final email = current_user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('${current_user?.displayName} 님의 프로필'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (photoUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(photoUrl!),
                radius: 50,
              ),
            SizedBox(height: 16),
            Text(
              'Name: $_name',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '자기소개: $_desc',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
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
                          await updateUserLogin(userModelProvider.userId!!, name, desc, phoneNumber);
                          // 업데이트 성공 후 작업 (예: 성공 메시지 표시)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('사용자 정보가 성공적으로 업데이트되었습니다.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } catch (e) {
                          // 업데이트 실패 후 작업 (예: 에러 메시지 표시)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('사용자 정보 업데이트에 실패했습니다. $e'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
              child: Text('프로필 수정'),
            ),
          ],
        ),
      ),
    );
  }
}
