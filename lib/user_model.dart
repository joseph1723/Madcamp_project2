import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserModel extends ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  String? _userId;

  GoogleSignInAccount? get currentUser => _currentUser;
  String? get userId => _userId;

  void setUser(GoogleSignInAccount? user, String? userId) {
    _currentUser = user;
    _userId = userId;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _userId = null;
    notifyListeners();
  }
}
