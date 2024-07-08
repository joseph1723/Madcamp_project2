import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'point_list_provider.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.42796133580664, 122.085749655962),
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

  Set<Marker> _createMarkers(Map<String, dynamic>? pointList) {
    final Set<Marker> markers = {};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_position'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: '현재 위치'),
        ),
      );
      print('Added current position marker');
    } else {
      print('Current position is null');
    }

    if (pointList != null) {
      for (var point in pointList['points']) {
        final coordinates = point['location']['coordinates'];
        if (coordinates != null && coordinates.length == 2) {
          final latitude = coordinates[0];
          final longitude = coordinates[1];
          
          if (latitude != null && longitude != null) {
            markers.add(
              Marker(
                markerId: MarkerId(point['_id']),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: point['name']),
              ),
            );
            print('Added marker for point: ${point['name']}');
          } else {
            print('Invalid coordinates for point: ${point['name']}');
          }
        } else {
          print('Coordinates not found for point: ${point['name']}');
        }
      }
    } else {
      print('Point list is null');
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final pointListProvider = Provider.of<PointListProvider>(context);
    final pointList = pointListProvider.pointList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google 지도'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              markers: _createMarkers(pointList),
            ),
          ),
          pointList != null ? _buildPointList(pointList) : Container(),
          if (pointList != null && pointList['points'].isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _moveCameraToCurrentLocation,
            child: const Text('걷기 시작'),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildPointList(Map<String, dynamic> pointList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pointList['points'].map<Widget>((point) {
          return _pointBox(point);
        }).toList(),
      ),
    );
  }

  Widget _pointBox(Map<String, dynamic> point) {
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
        color: Colors.grey,
        margin: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                point['name'],
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${point['_id']}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveCameraToCurrentLocation() {
  if (_currentPosition != null) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 14,
        ),
      ),
    );
  } else {
    print('Current position is null');
  }
}

  void _moveCameraToPoint(LatLng target) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 14,
        ),
      ),
    );
  }
}
