import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PointDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pointList;

  const PointDetailsScreen({Key? key, required this.pointList}) : super(key: key);

  void navigateToPointDetails(BuildContext context, Map<String, dynamic> point) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PointDetail(point: point),
      ),
    );
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<double> _calculateDistance(Map<String, dynamic> point) async {
    Position currentPosition = await _getCurrentLocation();
    double pointLatitude = point['location']['coordinates'][1];
    double pointLongitude = point['location']['coordinates'][0];

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
        title: Text(pointList['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Points:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pointList['points'].length,
                itemBuilder: (context, index) {
                  final point = pointList['points'][index];
                  return FutureBuilder<double>(
                    future: _calculateDistance(point),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(point['name']),
                            subtitle: Text('Calculating distance...'),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(point['name']),
                            subtitle: Text('Error calculating distance'),
                          ),
                        );
                      } else {
                        double distance = snapshot.data!;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(point['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Distance: ${distance.toStringAsFixed(2)} meters'),
                                Text('ID: ${point['_id']}'),
                              ],
                            ),
                            onTap: () => navigateToPointDetails(context, point),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PointDetail extends StatelessWidget {
  final Map<String, dynamic> point;

  const PointDetail({Key? key, required this.point}) : super(key: key);

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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<double> _calculateDistance() async {
    Position currentPosition = await _getCurrentLocation();
    double pointLatitude = point['location']['coordinates'][1];
    double pointLongitude = point['location']['coordinates'][0];

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
        title: Text(point['name']),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Point Details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Text('Name: ${point['name']}'),
                  SizedBox(height: 8.0),
                  Text('Location: [${point['location']['coordinates'].join(', ')}]'),
                  SizedBox(height: 8.0),
                  Text('ID: ${point['_id']}'),
                  SizedBox(height: 16.0),
                  Text(
                    'Current Location:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text('Latitude: ${currentPosition.latitude}'),
                  Text('Longitude: ${currentPosition.longitude}'),
                  SizedBox(height: 16.0),
                  FutureBuilder<double>(
                    future: _calculateDistance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Calculating distance...');
                      } else if (snapshot.hasError) {
                        return Text('Error calculating distance');
                      } else {
                        double distance = snapshot.data!;
                        return Text('Distance to Point: ${distance.toStringAsFixed(2)} meters');
                      }
                    },
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
