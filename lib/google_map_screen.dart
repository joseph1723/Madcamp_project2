import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'point_list_provider.dart';
import 'walk_complete_screen.dart'; // 새로운 페이지 import

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );
  Position? _currentPosition;
  Timer? _timer;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      _updateCurrentPositionMarker();
      if (_controller != null) {
        _moveCameraToCurrentLocation();
      }
    });

    // 10초마다 위치 업데이트를 위한 타이머 설정
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateCurrentLocation();
    });
  }

  @override
  void dispose() {
    // 타이머 해제
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permissions are denied');
        return;
      }
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14,
      );
      print('Current position: $_currentPosition');
    });
  }

  void _updateCurrentLocation() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = newPosition;
      });

      // 현재 위치 마커 업데이트
      _updateCurrentPositionMarker();
    } catch (e) {
      print('Error updating current location: $e');
    }
  }

  void _updateCurrentPositionMarker() {
    if (_controller != null && _currentPosition != null) {
      // _controller!.animateCamera(
      //   CameraUpdate.newCameraPosition(
      //     CameraPosition(
      //       target:
      //           LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      //       zoom: 18.5,
      //     ),
      //   ),
      // );

      // 현재 위치 마커 업데이트
      setState(() {
        _markers.removeWhere(
            (marker) => marker.markerId.value == 'current_position');
        _markers.add(
          Marker(
            markerId: const MarkerId('current_position'),
            position:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen), // 빨간색 아이콘으로 변경
            infoWindow: const InfoWindow(title: '현재 위치'),
          ),
        );
      });
    }
  }

  Set<Marker> _createMarkers(Map<String, dynamic>? pointList) {
    final Set<Marker> markers = {};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_position'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed), // 빨간색 아이콘으로 변경
          infoWindow: const InfoWindow(title: '현재 위치'),
        ),
      );
    }

    if (pointList != null) {
      bool allPointsReached = true; // 모든 지점에 도달했는지 여부 확인

      for (var point in pointList['points']) {
        final coordinates = point['location']['coordinates'];
        if (coordinates != null && coordinates.length == 2) {
          final latitude = coordinates[0];
          final longitude = coordinates[1];
          double distanceInMeters = 9999999.0;

          if (latitude != null &&
              longitude != null &&
              _currentPosition != null) {
            distanceInMeters = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              latitude,
              longitude,
            );
          }

          bool pointReached = point['pointReached'] ?? false;
          if (distanceInMeters <= 10) {
            pointReached = true;
          }

          markers.add(
            Marker(
              markerId: MarkerId(point['_id']),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: point['name'],
                snippet:
                    'Distance: ${distanceInMeters.toStringAsFixed(2)} meters'
                    '${pointReached ? "\n도달했습니다" : ""}',
              ),
            ),
          );

          // 현재 포인트의 도달 여부를 업데이트
          point['pointReached'] = pointReached;

          // 하나라도 도달하지 않은 지점이 있으면 allPointsReached를 false로 설정
          if (!pointReached) {
            allPointsReached = false;
          }
        } else {
          print('Coordinates not found for point: ${point['name']}');
        }
      }

      // 모든 지점에 도달했을 때 새 페이지로 이동
      if (allPointsReached) {
        _timer?.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => WalkCompletePage(
                  pointListName: pointList['name'],
                  pointListReview: pointList['review'])));
        });
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final pointListProvider = Provider.of<PointListProvider>(context);
    final pointList = pointListProvider.pointList;

    String appBarTitle = pointList != null ? pointList['name'] : 'Google 지도';

    // 마커 업데이트
    Set<Marker> markers = _createMarkers(pointList);
    markers.addAll(_markers);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                // 지도 생성 후 현재 위치로 카메라 이동
                _moveCameraToCurrentLocation();
              },
              markers: markers,
            ),
          ),
          pointList != null ? _buildPointList(pointList) : Container(),
          if (pointList != null && pointList['points'].isNotEmpty)
            SizedBox(
              width: double.infinity, // Set the width to match the screen width
              child: Container(
                color: const Color(0xFFFCFAE9), // Set the background color here
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _moveCameraToCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA8DF8E), // 버튼 색상 변경
                    ),
                    child: const Text(
                      '내 위치로',
                      style: TextStyle(color: Colors.black), // 글씨 색상 변경
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPointList(Map<String, dynamic> pointList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: const Color(0xFFFCFAE9), // Set the background color here
        child: Row(
          children: pointList['points'].map<Widget>((point) {
            return _pointBox(point);
          }).toList(),
        ),
      ),
    );
  }

  Widget _pointBox(Map<String, dynamic> point) {
    double distanceInMeters = 999999.0;
    if (_currentPosition != null) {
      final lat = point['location']['coordinates'][0];
      final lng = point['location']['coordinates'][1];
      distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        lat,
        lng,
      );
    }

    bool pointReached = point['pointReached'] ?? false;
    if (distanceInMeters <= 10) {
      pointReached = true;
    }

    return GestureDetector(
      onTap: () {
        final lat = point['location']['coordinates'][0];
        final lng = point['location']['coordinates'][1];
        print('Clicked point: Latitude = $lat, Longitude = $lng');
        _moveCameraToPoint(LatLng(lat, lng));
      },
      child: Container(
        width: 149,
        height: 187,
        decoration: BoxDecoration(
          color:
              pointReached ? const Color(0xFFA8DF8E) : const Color(0xFFFCFAE9),
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                point['name'],
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Image.asset(
                'asset/places/${point['name']}.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 12),
              Text(
                '${distanceInMeters.toStringAsFixed(2)} 미터 남음',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveCameraToCurrentLocation() {
    if (_currentPosition != null && _controller != null) {
      print(
          'Current position: Latitude = ${_currentPosition!.latitude}, Longitude = ${_currentPosition!.longitude}');
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 18.5,
          ),
        ),
      );
    } else {
      print('Current position is null');
    }
  }

  void _moveCameraToPoint(LatLng target) {
    print("MOVECAMERACALLED.DEFINITLLY");
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 18.5,
        ),
      ),
    );
  }
}
