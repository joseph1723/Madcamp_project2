import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  final String initialName;
  final String initialDesc;
  final String initialPhoneNumber;
  final Function(String, String, String) onSave;

  EditProfilePage({
    required this.initialName,
    required this.initialDesc,
    required this.initialPhoneNumber,
    required this.onSave,
  });

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _nameController.text = initialName;
    _descController.text = initialDesc;
    _phoneNumberController.text = initialPhoneNumber;

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
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: '자기소개'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: '전화번호'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  onSave(
                    _nameController.text,
                    _descController.text,
                    _phoneNumberController.text,
                  );
                  Navigator.pop(context); // 수정 완료 후 이전 페이지로 이동
                },
                child: Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
