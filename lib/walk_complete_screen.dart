import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_model.dart';

class WalkCompletePage extends StatefulWidget {
  final String pointListName;

  const WalkCompletePage({Key? key, required this.pointListName}) : super(key: key);

  @override
  _WalkCompletePageState createState() => _WalkCompletePageState();
}

class _WalkCompletePageState extends State<WalkCompletePage> {
  late UserModel userModel;
  bool isAddingCompleteThema = false;

  @override
  void initState() {
    super.initState();
    addCompleteThema(widget.pointListName);
  }

  Future<void> addCompleteThema(String pointListName) async {
    setState(() {
      isAddingCompleteThema = true;
    });

    final baseUrl = 'http://172.10.7.128:80'; // 서버의 기본 URL
    final userModelProvider = Provider.of<UserModel>(context, listen: false);
    final userId = userModelProvider.userId; // 사용자의 user_id
    final addCompleteThemaUrl = '$baseUrl/userslogin/$userId/add-complt-thema'; // 값을 추가할 엔드포인트 URL

    final compltThemaItem = pointListName; // 추가할 complt_thema 항목
    final Map<String, String> body = {'complt_thema_item': compltThemaItem, 'pointListName': pointListName};

    try {
      final response = await http.put(
        Uri.parse(addCompleteThemaUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add complt_thema item! HTTP status: ${response.statusCode}');
      }

      final updatedUser = jsonDecode(response.body);
      print('Updated user: $updatedUser');

      setState(() {
        isAddingCompleteThema = false;
      });

      // Optionally handle success or navigate somewhere else
    } catch (error) {
      print('Error adding complt_thema item: $error');

      setState(() {
        isAddingCompleteThema = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('산책 완료'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '축하해요, ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '당신은 ${widget.pointListName} 산책을 모두 완료했습니다!',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 32),
            if (isAddingCompleteThema)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('돌아가기'),
              ),
            SizedBox(height: 32),
            Text(
              '당신의 뱃지', // 뱃지 섹션 제목
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            BadgeBox(
              imagePath: 'asset/${widget.pointListName}.png', // 뱃지 이미지 경로
              description: '${widget.pointListName}를 완주한 증표!!', // 뱃지 설명
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeBox extends StatelessWidget {
  final String imagePath;
  final String description;

  const BadgeBox({Key? key, required this.imagePath, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(imagePath), // 뱃지 이미지 표시
        ),
        SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
