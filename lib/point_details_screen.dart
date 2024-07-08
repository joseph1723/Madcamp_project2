import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'point_list_provider.dart';
import 'package:geolocator/geolocator.dart';

class PointDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pointList;

  const PointDetailsScreen({Key? key, required this.pointList}) : super(key: key);

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
  }

  void navigateToPointDetails(BuildContext context, Map<String, dynamic> point) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PointDetail(point: point),
      ),
    );
  }

  void savePointList(BuildContext context) {
    Provider.of<PointListProvider>(context, listen: false).setPointList(widget.pointList);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pointList['name']),
        actions: [
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.black, // 테두리 색상
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
              'Points:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => savePointList(context),
              child: Text('Save to Provider'),
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Point Details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Text('Name: ${widget.point['name']}'),
                  SizedBox(height: 8.0),
                  Text('Location: [${widget.point['location']['coordinates'].join(', ')}]'),
                  SizedBox(height: 8.0),
                  Text('ID: ${widget.point['_id']}'),
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
                    future: distanceFuture,
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
