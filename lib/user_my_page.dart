import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'user_profile_widget.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userModelProvider = Provider.of<UserModel>(context);
    final currentUser = userModelProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentUser?.displayName} 님의 프로필'),
      ),
      body: UserProfileWidget(
        userId: userModelProvider.userId!,
        isEditable: true,
      ),
    );
  }
}

class OtherUserProfilePage extends StatelessWidget {
  final String userId;

  const OtherUserProfilePage({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다른 사용자의 프로필'),
      ),
      body: UserProfileWidget(
        userId: userId,
        isEditable: false,
      ),
    );
  }
}
