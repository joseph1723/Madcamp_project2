import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화된 경우
      return;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // 위치 권한이 영구적으로 거부된 경우
      return;
    }

    if (permission == LocationPermission.denied) {
      // 위치 권한이 거부된 경우
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // 위치 권한이 허용되지 않은 경우
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google 지도'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: _currentPosition != null
            ? {
          Marker(
            markerId: MarkerId('current_position'),
            position: LatLng(_currentPosition!.latitude,
                _currentPosition!.longitude),
            infoWindow: InfoWindow(title: '현재 위치'),
          ),
        }
            : {},
      ),
    );
  }
}
