import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'point_list_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'user_model.dart';
import 'package:http/http.dart' as http;
import 'user_my_page.dart';


class PointDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pointList;

  const PointDetailsScreen({Key? key, required this.pointList})
      : super(key: key);

  @override
  _PointDetailsScreenState createState() => _PointDetailsScreenState();
}

class _PointDetailsScreenState extends State<PointDetailsScreen> {
  bool isFavorited = false;
  late Future<List<double>> distancesFuture;

  @override
  void initState() {
    super.initState();
    distancesFuture = _calculateDistances();


    final userModel = Provider.of<UserModel>(context, listen: false);
    final likedPeople = widget.pointList['likePeople'];
    if (userModel != null && userModel.userId != null && likedPeople != null) {
      if (likedPeople.contains(userModel.userId)) {
        setState(() {
          isFavorited = true;
        });
      }
    }
  }

  void navigateToPointDetails(
      BuildContext context, Map<String, dynamic> point) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PointDetail(point: point),
      ),
    );
  }

  void savePointList(BuildContext context) {
    Provider.of<PointListProvider>(context, listen: false)
        .setPointList(widget.pointList);
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<double>> _calculateDistances() async {
    Position currentPosition = await _getCurrentLocation();
    List<double> distances = [];
    for (var point in widget.pointList['points']) {
      double pointLatitude = point['location']['coordinates'][0];
      double pointLongitude = point['location']['coordinates'][1];
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        pointLatitude,
        pointLongitude,
      );
      distances.add(distance);
    }
    return distances;
  }



  Future<void> editLikedPeople(bool isFavorite, String pointListName) async {
    setState(() {
      isFavorited = isFavorite;
    });
    if (isFavorite) {
      await addLikedPerson(pointListName);
    } else {
      await removeLikedPerson(pointListName);
    }
    // Update the likePeople list in the popup
  }

  Future<void> addLikedPerson(String pointListName) async {
    const baseUrl = 'http://172.10.7.128:80'; // 서버의 기본 URL
    final user_id = Provider.of<UserModel>(context, listen: false).userId; // 추가할 사용자의 user_id

    try {
      // 특정 포인트 리스트 조회하여 ID 가져오기
      final getPointListUrl = Uri.parse('$baseUrl/pointslist/$pointListName');
      final getPointListResponse = await http.get(getPointListUrl);

      if (getPointListResponse.statusCode != 200) {
        throw Exception('Failed to fetch point list! HTTP status: ${getPointListResponse.statusCode}');
      }

      final pointList = jsonDecode(getPointListResponse.body);
      final pointListId = pointList['_id'];

      // LikedPeople에 사용자 추가하기
      final addLikedPersonUrl = Uri.parse('$baseUrl/pointslist/$pointListId/add-liked-person');
      final addLikedPersonResponse = await http.put(
        addLikedPersonUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': user_id}),
      );

      if (addLikedPersonResponse.statusCode != 200) {
        throw Exception('Failed to add liked person! HTTP status: ${addLikedPersonResponse.statusCode}');
      }

      final updatedPointList = jsonDecode(addLikedPersonResponse.body);
      print('Updated point list: $updatedPointList');

      // Update the likePeople list in the popup
      setState(() {
        widget.pointList['likePeople'].add(updatedPointList['user_id']);
      });
    } catch (error) {
      print('Error adding liked person: $error');
    }
  }

  Future<void> removeLikedPerson(String pointListName) async {
    const baseUrl = 'http://172.10.7.128:80'; // 서버의 기본 URL
    final user_id = Provider.of<UserModel>(context, listen: false).userId; // 제거할 사용자의 user_id

    try {
      // 특정 포인트 리스트 조회하여 ID 가져오기
      final getPointListUrl = Uri.parse('$baseUrl/pointslist/$pointListName');
      final getPointListResponse = await http.get(getPointListUrl);

      if (getPointListResponse.statusCode != 200) {
        throw Exception('Failed to fetch point list! HTTP status: ${getPointListResponse.statusCode}');
      }

      final pointList = jsonDecode(getPointListResponse.body);
      final pointListId = pointList['_id'];

      // LikedPeople에서 사용자 제거하기
      final removeLikedPersonUrl = Uri.parse('$baseUrl/pointslist/$pointListId/remove-liked-person');
      final removeLikedPersonResponse = await http.put(
        removeLikedPersonUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': user_id}),
      );

      if (removeLikedPersonResponse.statusCode != 200) {
        throw Exception('Failed to remove liked person! HTTP status: ${removeLikedPersonResponse.statusCode}');
      }

      final updatedPointList = jsonDecode(removeLikedPersonResponse.body);
      print('Updated point list: $updatedPointList');

      // Update the likePeople list in the popup
      setState(() {
        widget.pointList['likePeople'].remove(updatedPointList['user_id']);
      });
    } catch (error) {
      print('Error removing liked person: $error');
    }
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              titlePadding: EdgeInsets.only(top: 20, left: 20, right: 20),
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: EdgeInsets.only(bottom: 20, right: 20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('같이 걸어요 ><'),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                child: _buildDummyList(widget.pointList['name']),
              ),
            );
          },
        );
      },
    );
  }


  Future<List<dynamic>> getLikePeopleFromListByName(String name) async {
    const String baseUrl = 'http://172.10.7.128:80/pointslist/';
    final String url = '$baseUrl$name';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('Response not ok with url: $url, status: ${response.statusCode}, statusText: ${response.reasonPhrase}');
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      print('Fetched point list: $data');
      return data['likePeople'] as List<dynamic>;
    } catch (error) {
      print('Error fetching point list: $error');
      rethrow;
    }
  }

  Widget _buildDummyList(String name) {
    return FutureBuilder<List<dynamic>>(
      future: getLikePeopleFromListByName(name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available'));
        } else {
          final likePeople = snapshot.data!;
          return Scrollbar(
            child: ListView.builder(
              itemCount: likePeople.length,
              itemBuilder: (context, index) {
                final person = likePeople[index];
                return ListTile(
                  title: Text(person),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OtherUserProfilePage(userId: person),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
  // Widget _buildDummyList(List<dynamic> name) {
  //   return Scrollbar(
  //     child: ListView.builder(
  //       itemCount: likePeople.length,
  //       itemBuilder: (context, index) {
  //         // Null 체크 추가
  //         final item = likePeople[index];
  //         if (item == null) {
  //           return SizedBox(); // 또는 다른 기본 위젯을 반환하여 처리
  //         }
  //         return ListTile(
  //           title: Text(item.toString()), // toString()을 사용하여 문자열로 변환
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pointList['name']),
        actions: [
          IconButton(
            icon: Image.asset('asset/view.png'),
            onPressed: () {
              _showPopup(context);
            },
          ),
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.black,
                  size: 30.0,
                ),
                Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : Colors.white,
                  size: 24.0,
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                isFavorited = !isFavorited;
              });
              editLikedPeople(isFavorited, widget.pointList['name']);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '어디 걸을까? :D',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<List<double>>(
                future: distancesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error calculating distances'));
                  } else {
                    List<double> distances = snapshot.data!;
                    return ListView.builder(
                      itemCount: widget.pointList['points'].length,
                      itemBuilder: (context, index) {
                        final point = widget.pointList['points'][index];
                        double distance = distances[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
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
                              title: Text(point['name']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('떨어진 거리: ${distance.toStringAsFixed(2)} meters'),
                                  Text(point['address']),
                                ],
                              ),
                              onTap: () => navigateToPointDetails(context, point),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () => savePointList(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA8DF8E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(200, 50),
                ),
                child: Text('테마 선택',
                style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class PointDetail extends StatefulWidget {
  final Map<String, dynamic> point;

  const PointDetail({Key? key, required this.point}) : super(key: key);

  @override
  _PointDetailState createState() => _PointDetailState();
}

class _PointDetailState extends State<PointDetail> {
  bool isFavorited = false;
  late Future<double> distanceFuture;

  @override
  void initState() {
    super.initState();
    distanceFuture = _calculateDistance();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<double> _calculateDistance() async {
    Position currentPosition = await _getCurrentLocation();
    double pointLatitude = widget.point['location']['coordinates'][0];
    double pointLongitude = widget.point['location']['coordinates'][1];

    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      pointLatitude,
      pointLongitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.point['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<Position>(
          future: _getCurrentLocation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching current location'));
            } else {
              Position currentPosition = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Change alignment to center
                children: [
                  Text(
                    '${widget.point['name']}',
                    style: TextStyle(fontSize: 26), // Set font size to 22
                  ),
                  SizedBox(height: 6.0),
                  Text('${widget.point['address']}', 
                    style: TextStyle(fontSize: 22),),
                  SizedBox(height: 12.0),
                  FutureBuilder<double>(
                    future: distanceFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('거리 계산 중...');
                      } else if (snapshot.hasError) {
                        return Text('Error calculating distance');
                      } else {
                        double distance = snapshot.data!;
                        return Text(
                          '여기서부터 ${distance.toStringAsFixed(2)} meters 떨어짐',
                          style: TextStyle(color: Colors.red), // Set text color to red
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20.0),
                  Image.asset(
                    'asset/places/${widget.point['name']}.png',
                    fit: BoxFit.contain, // Ensure image fits within the container
                  ),
                ],
              );

            }
          },
        ),
      ),
    );
  }
}
