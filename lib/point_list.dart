import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'point_details_screen.dart'; // 새로운 파일을 import

const String baseUrl = 'http://172.10.7.128:80/pointslist/';

class Tab1Screen extends StatefulWidget {
  const Tab1Screen({Key? key}) : super(key: key);

  @override
  _Tab1ScreenState createState() => _Tab1ScreenState();
}

class _Tab1ScreenState extends State<Tab1Screen> {
  List<Map<String, dynamic>> pointLists = [];
  List<Map<String, dynamic>> filteredPointLists = [];
  TextEditingController _searchController = TextEditingController();

  Future<void> getPointsLists() async {
    String url = baseUrl;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          pointLists = data.map((item) => Map<String, dynamic>.from(item)).toList();
          filteredPointLists = pointLists;
        });
      } else {
        print('Response not ok with url: $url, status: ${response.statusCode}, statusText: ${response.reasonPhrase}');
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching point lists: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getPointsLists();
    _searchController.addListener(_filterPoints);
  }

  void _filterPoints() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPointLists = pointLists.where((point) {
        final name = point['name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  void navigateToDetails(Map<String, dynamic> pointList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PointDetailsScreen(pointList: pointList),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Point Lists'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: Color(0xFFA8DF8E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFA8DF8E)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFA8DF8E)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: filteredPointLists.isEmpty
                  ? CircularProgressIndicator()
                  : ListView.builder(
                itemCount: filteredPointLists.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(filteredPointLists[index]['name']),
                      subtitle: Text('Points: ${filteredPointLists[index]['points'].length}'),
                      onTap: () => navigateToDetails(filteredPointLists[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
