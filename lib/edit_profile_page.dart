import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;



class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialDesc;
  final String initialPhoneNumber;
  final Function(String, String, String, String) onSave; // imagePath 추가

  EditProfilePage({
    required this.initialName,
    required this.initialDesc,
    required this.initialPhoneNumber,
    required this.onSave,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _phoneNumberController;
  String? _imagePath; // 선택된 이미지 파일 경로

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.initialName;
    _descController.text = widget.initialDesc;
    _phoneNumberController.text = widget.initialPhoneNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 이미지 선택 버튼 추가
              ElevatedButton(
                onPressed: _getImage,
                child: Text('이미지 선택'),
              ),
              SizedBox(height: 16),
              if (_imagePath != null) // 선택된 이미지가 있을 경우 미리보기 표시
                Image.file(
                  File(_imagePath!),
                  height: 200,
                ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: '자기소개',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // imagePath도 onSave 함수에 전달
                  print("NEW IMAGE PATH IS $_imagePath");
                  widget.onSave(
                    _nameController.text,
                    _descController.text,
                    _phoneNumberController.text,
                    _imagePath ?? '', // 이미지 경로가 없을 경우 빈 문자열 전달
                  );
                  Navigator.pop(context); // 수정 완료 후 이전 페이지로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA8DF8E), // 버튼의 배경색 설정
                ),
                child: Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
