import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:async';

import './homePage.dart';

class currentBookingPage extends StatefulWidget {
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;
  final double price;
  final double distance;
  final String riderNickName;

  currentBookingPage({
    this.fromLat = 0.0,
    this.fromLng = 0.0,
    this.toLat = 0.0,
    this.toLng = 0.0,
    this.distance = 0.0,
    this.price = 0.0,
    this.riderNickName = '',
  });
  @override
  currentBookingPageState createState() => currentBookingPageState();
}

class currentBookingPageState extends State<currentBookingPage> {
  late GoogleMapController _mapController;
  double _totalDragDistance = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late WebSocketChannel _websocket;
  Timer? _timer;
  double _bottomOffset = -270;
  bool _isDown = true;
  bool isDisposed = false;
  int _selectedIndex = 0;
  LatLng? riderLocation;
  bool isFirst = true;
  bool isRideStarted = false;
  final String _apiKey = 'AIzaSyCXtpXXc0yB7vewvbA2h-RQ0iUsw3Xwz5Y';

  String nickName = '';

  Polyline? _routePoints2Client;
  Polyline? _routePoints2Destination;
  Set<Marker> _markers = {};

  String clientDeparture = '';
  String clientDestination = '';

  String riderNickName = '';

  LatLng? clientDeparturePosition;
  LatLng? clientDestinationPosition;

  double? _distance;
  double? _price;

  @override
  void initState() {
    super.initState();

    setState(() {
      clientDeparturePosition = LatLng(widget.fromLat, widget.fromLng);
      clientDestinationPosition = LatLng(widget.toLat, widget.toLng);
      _distance = widget.distance;
      _price = widget.price;
      riderNickName = widget.riderNickName;

      _markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: clientDeparturePosition!,
          infoWindow: InfoWindow(title: 'Pickup'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: clientDestinationPosition!,
          infoWindow: InfoWindow(title: 'Departure'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      );
    });

    _setClientDeparture(
        clientDeparturePosition!.latitude, clientDeparturePosition!.longitude);
    _setClientDestination(clientDestinationPosition!.latitude,
        clientDestinationPosition!.longitude);

    _checkPermissions();
    _getCurrentLocation();
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) {
    //   _getCurrentLocation();
    // });

    // Connect to the WebSocket server
    _websocket = WebSocketChannel.connect(
      Uri.parse('ws://88.222.213.227:8080'),
    );

    // Listen to incoming messages
    _websocket.stream.listen((message) {
      final msg = json.decode(message);

      if (msg['msgType'] == "locationUpdate") {
        setState(() {
          this.riderLocation = LatLng(msg['latitude'], msg['longitude']);
          _markers.add(
            Marker(
              markerId: MarkerId('rider'),
              position: riderLocation!,
              infoWindow: InfoWindow(title: 'Rider'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            ),
          );
        });

        if (isRideStarted) {
          _fetchRouteToDestination();
        } else {
          _fetchRouteToClient();
        }
      }
      if (msg['msgType'] == "startRide") {
        setState(() {
          isRideStarted = true;
        });
        _fetchRouteToDestination();
      }
      if (msg['msgType'] == "finishRide") {
        setState(() {
          isRideStarted = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => myHomePage()),
        );
      }
    });
    _getNickName();
  }

  @override
  void dispose() {
    _timer?.cancel();
    isDisposed = true;
    super.dispose();
    _websocket.sink.close();
  }

  void _getNickName() async {
    var box = await Hive.openBox('userData');
    String nickName = await box.get('nickName');
    setState(() {
      this.nickName = nickName;
    });
    String jsonMsg = json.encode({
      "msgType": "hello",
      "nickName": nickName,
      "type": "rider",
    });
    _websocket.sink.add(jsonMsg);
  }

  Future<void> _checkPermissions() async {
    PermissionStatus permission = await Permission.location.status;
    if (permission.isDenied || permission.isPermanentlyDenied) {
      permission = await Permission.location.request();
    }

    if (permission.isGranted) {
      print("Location permission granted");
    } else {
      print("Location permission denied!");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            "Location permissions are permanently denied. Enable them in settings.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          // desiredAccuracy: LocationAccuracy.high,
          );

      if (!isDisposed) {
        setState(() {
          // riderLocation = LatLng(position.latitude, position.longitude);

          if (isRideStarted) {
            _fetchRouteToDestination();
          } else {
            if (riderLocation != null) _fetchRouteToClient();
          }
        });
      }
      if (isFirst) {
        isFirst = false;

        setState(() {});

        if (isRideStarted) {
          _fetchRouteToDestination();
        } else {
          if (riderLocation != null) _fetchRouteToClient();
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fetchRouteToDestination();
    _mapController.animateCamera(
      CameraUpdate.newLatLng(clientDeparturePosition!),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> _fetchRouteToClient() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${riderLocation?.latitude},${riderLocation?.longitude}&destination=${clientDeparturePosition?.latitude},${clientDeparturePosition?.longitude}&mode=driving&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      final polylinePoints = _decodePolyline(points);
      final route = data['routes'][0];
      final leg = route['legs'][0];
      _distance = leg['distance']['value'].toDouble();
      setState(() {
        _routePoints2Client = Polyline(
          polylineId: PolylineId('route2client'),
          points: polylinePoints,
          color: Colors.red,
          width: 4,
        );
      });
    }
  }

  Future<void> _fetchRouteToDestination() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${clientDeparturePosition?.latitude},${clientDeparturePosition?.longitude}&destination=${clientDestinationPosition?.latitude},${clientDestinationPosition?.longitude}&mode=driving&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      final polylinePoints = _decodePolyline(points);
      final route = data['routes'][0];
      final leg = route['legs'][0];
      _distance = leg['distance']['value'].toDouble();
      setState(() {
        _routePoints2Destination = Polyline(
          polylineId: PolylineId('route2dest'),
          points: polylinePoints,
          color: Colors.green,
          width: 4,
        );
      });
    }
  }

  Future<String> _getNearestAddress(double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String address =
            data['results'][0]['formatted_address'] ?? "No address found";
        return address;
      } else {
        print("Error: ${response.statusCode}");
        return '';
      }
    } catch (e) {
      print("Error fetching address: $e");
      return '';
    }
  }

  Future<void> _setClientDeparture(double latitude, double longitude) async {
    String location = await _getNearestAddress(latitude, longitude);
    setState(() {
      clientDeparture = location;
    });
  }

  Future<void> _setClientDestination(double latitude, double longitude) async {
    String location = await _getNearestAddress(latitude, longitude);
    setState(() {
      clientDestination = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(197, 255, 252, 222),
        ),
        child: Stack(
          children: [
            Center(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(11.55, 124.75), // Default location
                  zoom: 10,
                ),
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                markers: _markers,
                // cameraTargetBounds: CameraTargetBounds(philippinesBounds),
                polylines: {
                  if (_routePoints2Client != null && !isRideStarted)
                    _routePoints2Client!,
                  if (_routePoints2Destination != null)
                    _routePoints2Destination!,
                },
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _bottomOffset,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  _totalDragDistance = 0;
                  if (details.velocity.pixelsPerSecond.dy < 0) {
                    setState(() {
                      _bottomOffset = 0;
                      _isDown = false;
                    });
                  } else if (details.velocity.pixelsPerSecond.dy > 0) {
                    setState(() {
                      _bottomOffset = -270;
                      _isDown = true;
                    });
                  }
                },
                child: Container(
                  height: 360,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(
                      children: [
                        Center(
                          heightFactor: 1.85,
                          child: Text(
                            "Booking Details",
                            style: TextStyle(
                              color: Colors.pink,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isDown = !_isDown;
                                _bottomOffset = _bottomOffset == 0 ? -270 : 0;
                              });
                            },
                            icon: Icon(_isDown
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_circle),
                            iconSize: 40.0,
                            color: Colors.pink,
                          ),
                        ),
                        Positioned(
                          top: 70,
                          child: Container(
                            width: screenWidth - 40,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: Colors.blue,
                                      size: 40.0,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "pickup Location",
                                          style: TextStyle(
                                            fontSize: 13.0,
                                          ),
                                        ),
                                        Container(
                                          width: screenWidth * 0.7,
                                          child: Text(
                                            clientDeparture,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "Destination",
                                          style: TextStyle(
                                            fontSize: 13.0,
                                          ),
                                        ),
                                        Container(
                                          width: screenWidth * 0.7,
                                          child: Text(
                                            clientDestination,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                        "Amount: PHP ${double.parse(_price!.toStringAsFixed(2))}"),
                                    Text(
                                        "Distance: ${double.parse((_distance! / 1000).toStringAsFixed(2))}km"),
                                  ],
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: screenWidth,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 52, 117),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // Shadow color
                      blurRadius: 10, // Softness of the shadow
                      spreadRadius: 2, // Spread radius
                      offset: Offset(0, 10), // Offset in x and y directions
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        "Rider coming now.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}
