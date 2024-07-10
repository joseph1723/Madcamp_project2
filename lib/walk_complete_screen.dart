import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_model.dart';

class WalkCompletePage extends StatefulWidget {
  final String pointListName;
  final String pointListReview;
  const WalkCompletePage(
      {Key? key, required this.pointListName, required this.pointListReview})
      : super(key: key);

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
    final addCompleteThemaUrl =
        '$baseUrl/userslogin/$userId/add-complt-thema'; // 값을 추가할 엔드포인트 URL

    final compltThemaItem = pointListName; // 추가할 complt_thema 항목
    final Map<String, String> body = {
      'complt_thema_item': compltThemaItem,
      'pointListName': pointListName
    };

    try {
      final response = await http.put(
        Uri.parse(addCompleteThemaUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to add complt_thema item! HTTP status: ${response.statusCode}');
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('산책 완료'),
        backgroundColor: Color(0xFFF6F3DF),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12),
                Text(
                  '축하해요:D',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '당신은 ${widget.pointListName}\n산책을 마쳤어요!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Image.asset(
                  'asset/line.png',
                ),
                SizedBox(height: 30),
                Text(
                  '당신의 뱃지', // 뱃지 섹션 제목
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                BadgeBox(
                  imagePath: 'asset/${widget.pointListName}.png', // 뱃지 이미지 경로
                  description: '${widget.pointListName}를 완주한 증표!!', // 뱃지 설명
                ),
                SizedBox(height: 28),
                Text(
                  widget.pointListReview, // 뱃지 섹션 제목
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 26),
                if (isAddingCompleteThema)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA8DF8E),
                    ),
                    child: const Text(
                      '돌아가기',
                      style: TextStyle(color: Colors.black),
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
  final String description;

  const BadgeBox({Key? key, required this.imagePath, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(0, 168, 223, 142)),
          ),
          child: Image.asset(imagePath), // 뱃지 이미지 표시
        ),
        SizedBox(height: 16), // Increased spacing
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
