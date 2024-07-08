import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    _name = '';
    _desc = '';
    _phoneNumber = '';
    _complt_thema = [];
    loadUserLogin(widget.userId);
  }

  Future<void> loadUserLogin(String userId) async {
    try {
      final data = await getUserLogin(userId);
      setState(() {
        _name = data['name'] ?? '이름 없음';
        _desc = data['desc'] ?? '자기소개 없음';
        _phoneNumber = data['phonenumber'] ?? '';
        _complt_thema = data['complt_thema']?.cast<String>() ?? [];
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
    String baseUrl = 'http://172.10.7.128:80';
    String url = '$baseUrl/userslogin/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('사용자 로그인 정보를 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('사용자 로그인 정보를 가져오는 도중 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage('asset/img2.png'),
          ),
          const SizedBox(height: 30),
          Card(
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
          if (widget.isEditable) ...[
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8DF8E),
              ),
              onPressed: () {
                // 프로필 수정 화면으로 이동
                // 사용자가 수정할 수 있도록 하는 기능
              },
              child: const Text('프로필 수정'),
            ),
          ],
          const SizedBox(height: 30),
          const Text(
            '내가 획득한 뱃지',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
            width: 200,
            height: 200,
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
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
