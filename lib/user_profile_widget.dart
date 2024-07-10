import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class UserProfileWidget extends StatefulWidget {
  final String userId;
  final bool isEditable;

  const UserProfileWidget({
    required this.userId,
    this.isEditable = false,
    Key? key,
  }) : super(key: key);

  @override
  _UserProfileWidgetState createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late String _name;
  late String _desc;
  late String _phoneNumber;
  late List<String> _complt_thema;
  late String _profileImageUrl;
  Uint8List? _profileImageBytes;
  bool _isLoading = true; // 로딩 상태를 나타내는 변수 추가

  @override
  void initState() {
    super.initState();
    _name = '';
    _desc = '';
    _phoneNumber = '';
    _complt_thema = [];
    loadUserLogin(widget.userId);
  }

  Future<void> fetchImage(String url) async {
    final requesturl = 'http://172.10.7.128:80/image/${url.split('/')[1]}';
    final response = await http.get(Uri.parse(requesturl)); // 프로필 이미지 URL에서 이미지 데이터 가져오기
    if (response.statusCode == 200) {
      setState(() {
        _profileImageBytes = response.bodyBytes; // 이미지 데이터를 상태에 저장
      });
    } else {
      throw Exception('Failed to load image');
    }
  }
  Future<void> updateUserLogin(String userId, String name, String desc, String phoneNumber, String imagePath) async {
    String baseUrl = 'http://172.10.7.128:80'; // 서버의 기본 URL
    String url = '$baseUrl/userslogin/$userId'; // 수정할 사용자의 user_id

    try {
      // 기존 사용자 정보 조회
      final getUserResponse = await http.get(Uri.parse(url));

      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields['name'] = name;
      request.fields['desc'] = desc;
      request.fields['phoneNumber'] = phoneNumber;

      if(imagePath.isNotEmpty) {
        final file = File(imagePath);
        var multipartFile = http.MultipartFile(
          'profileImage',
          file.openRead(),
          await file.length(),
          filename: file.path
              .split('/')
              .last,
        );

        request.files.add(multipartFile);
      }

      // 멀티파트 요청 보내기
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        print('사용자 로그인 정보 업데이트 성공: $updatedData');
        // setState(() {
        //   _name = name;
        //   _desc = desc;
        //   _phoneNumber = phoneNumber;
        // });
      } else {
        throw Exception('사용자 로그인 정보 업데이트에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (error) {
      print('사용자 로그인 정보 업데이트 중 오류 발생: $error');
      throw Exception('사용자 로그인 정보를 업데이트하는 도중 오류가 발생했습니다.');
    }
  }

  Future<void> loadUserLogin(String userId) async {
    try {
      final data = await getUserLogin(userId);
      setState(() {
        _name = data['name'] ?? '이름 없음';
        _desc = data['desc'] ?? '자기소개 없음';
        _phoneNumber = data['phonenumber'] ?? '';
        _complt_thema = data['complt_thema']?.cast<String>() ?? [];
        _profileImageUrl = data['profileImage'] ?? '';
      });
      if (_profileImageUrl.isNotEmpty) {
        await fetchImage(_profileImageUrl);
      }
      setState(() {
        _isLoading = false; // 데이터 로드 완료 후 로딩 상태를 false로 설정
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // 오류가 발생해도 로딩 상태를 false로 설정
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사용자 정보를 가져오는 중에 오류가 발생했습니다. $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getUserLogin(String userId) async {
    String baseUrl = 'http://172.10.7.128:80';
    String url = '$baseUrl/userslogin/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            '사용자 로그인 정보를 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('사용자 로그인 정보를 가져오는 도중 오류가 발생했습니다.');
    }
  }

  void _sendMessage() async {
    final uri = Uri(scheme: 'sms', path: _phoneNumber);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch $uri';
    }
  }

  void _makePhoneCall() async {
    final uri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 인디케이터 표시
        : SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 100,
            backgroundImage: _profileImageBytes != null
                ? MemoryImage(_profileImageBytes!)
                : AssetImage('asset/img2.png') as ImageProvider,
            backgroundColor: const Color(0xFFFCFAE9), // CircleAvatar 배경색 설정
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              color: const Color(0xFFFCFAE9), // Card 배경색 설정
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Email: ${widget.userId}', // 이메일을 userId로 대체
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            '전화번호: $_phoneNumber',
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.call),
                            onPressed: _makePhoneCall,
                          ),
                          IconButton(
                            icon: Icon(Icons.chat_bubble_outline),
                            onPressed: _sendMessage,
                          ),
                        ],
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
            ),),
          if (widget.isEditable) ...[
            const SizedBox(height: 30),
            SizedBox(
              width: 150, // 원하는 너비로 설정
              height: 45, // 원하는 높이로 설정
              child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8DF8E),
                textStyle: const TextStyle( // 글꼴 스타일 설정
                  fontSize: 18,
                  fontFamily: '교보',
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      initialName: _name,
                      initialDesc: _desc,
                      initialPhoneNumber: _phoneNumber,
                      onSave: (String name, String desc, String phoneNumber, String imagePath) async {
                        try {
                          await updateUserLogin(widget.userId, name, desc, phoneNumber, imagePath);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('사용자 정보가 성공적으로 업데이트되었습니다.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } catch (e) {
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
            ),
          ],
          const SizedBox(height: 30),
          const Text(
            '내가 획득한 뱃지',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _complt_thema.map((theme) {
                String imagePath = 'asset/$theme.png';
                String description = theme;

                return BadgeBox(
                  imagePath: imagePath,
                  description: description,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BadgeBox extends StatelessWidget {
  final String imagePath;
  final String description;

  const BadgeBox({required this.imagePath, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 170,
            height: 210,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFA8DF8E)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(imagePath),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
