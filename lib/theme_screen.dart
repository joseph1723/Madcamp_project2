import 'package:flutter/material.dart';

class ThemeScreen extends StatelessWidget {
  final String theme;

  const ThemeScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$theme Screen'),
      ),
      body: Center(
        child: Text(
          'This is the $theme screen.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
