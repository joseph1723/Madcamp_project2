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


  @override
  void initState() {
    super.initState();
    getPointsLists(); // 초기에 데이터 불러오기

    _searchController.addListener(_filterPoints);

    // Tab1Screen이 화면에 나타날 때마다 데이터 다시 불러오기
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getPointsLists();
    });

  }
  void onRouteChanged() {
    if (ModalRoute.of(context)?.isCurrent == true) {
      // 현재 페이지가 화면에 보일 때만 데이터 다시 불러오기
      getPointsLists();
    }
  }

  Future<void> getPointsLists() async {
    String url = baseUrl;
    print("GET CALLED");
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
    ).then((_){
      getPointsLists();
    });
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
                  borderSide: BorderSide(color: Color(0xFFA8DF8E), width: 2), // 테두리 두께 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFA8DF8E), width: 2), // 테두리 두께 설정
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Card 배경색 설정
                        border: Border.all(
                          color: Color(0xFFA8DF8E), // 테두리 색상 설정
                          width: 2, // 테두리 두께 설정
                        ),
                        borderRadius: BorderRadius.circular(10), // Card의 기본 borderRadius 설정
                      ),
                      child: ListTile(
                        title: Text(filteredPointLists[index]['name']),
                        subtitle: Text('목표 지점 수: ${filteredPointLists[index]['points'].length} 개'),
                        onTap: () => navigateToDetails(filteredPointLists[index]),
                      ),
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
