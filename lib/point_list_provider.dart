import 'package:flutter/material.dart';

class PointListProvider extends ChangeNotifier {
  Map<String, dynamic>? _pointList;

  Map<String, dynamic>? get pointList => _pointList;

  void setPointList(Map<String, dynamic> pointList) {
    _pointList = pointList;
    notifyListeners();
  }
}
