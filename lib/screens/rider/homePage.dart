import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/drawer.dart';
import '../../widgets/searchBar.dart';
import './currentBookingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RiderHomePage extends StatefulWidget {
  @override
  _RiderHomePageState createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  double _totalDragDistance = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _timer;
  MapController _mapController = MapController();
  double _bottomOffset = -400;
  bool _isDown = false;
  bool isDisposed = false;
  int _selectedIndex = 0;
  LatLng? _locationMessage;
  bool isFirst = true;

  List<LatLng> _routePoints = [];

  String clientDeparture = '';
  String clientDestination = '';

  LatLng? clientDeparturePosition;
  LatLng? clientDestinationPosition;

  List<dynamic> waitingClients = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getCurrentLocation();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    isDisposed = true;
    super.dispose();
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
          _locationMessage = LatLng(position.latitude, position.longitude);

          waitingClients = [
            {
              "name": "Client1",
              "index": 0,
              "position": LatLng(position.latitude - 0.01, position.longitude),
            },
            {
              "name": "Client2",
              "index": 1,
              "position": LatLng(position.latitude + 0.01, position.longitude),
            },
            {
              "name": "Client3",
              "index": 2,
              "position": LatLng(position.latitude, position.longitude + 0.01),
            },
            {
              "name": "Client4",
              "index": 3,
              "position": LatLng(position.latitude, position.longitude - 0.01),
            },
          ];
          print(_locationMessage);
        });
      }
      if (isFirst) {
        isFirst = false;
        _mapController.move(
            LatLng(position.latitude, position.longitude), 16.0);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchRoute() async {
    final url =
        "https://router.project-osrm.org/route/v1/driving/${clientDeparturePosition?.longitude},${clientDeparturePosition?.latitude};${clientDestinationPosition?.longitude},${clientDestinationPosition?.latitude}?overview=full&geometries=geojson";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'];
        final points = coordinates.map<LatLng>((coord) {
          return LatLng(coord[1], coord[0]); // Reverse lat/lon order
        }).toList();
        setState(() {
          _routePoints = points;
        });
      } else {
        print("Failed to fetch route: ${response.body}");
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<String> _getNearestAddress(double latitude, double longitude) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String address = data['display_name'] ?? "No address found";
        return address;
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
    return ("error on fetching address");
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
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(14.590449, 120.980362),
                  initialZoom: 16.0,
                  maxZoom: 18.0,
                  minZoom: 5.0,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                        LatLng(4.2158, 116.5891), LatLng(21.1224, 126.6056)),
                  ),
                  onTap: (tapPosition, point) {},
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: waitingClients.map((client) {
                      int index = client['index'];
                      return Marker(
                          width: 100.0,
                          height: 80.0,
                          point: client['position'],
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mapController.move(client['position'], 15.0);
                                _bottomOffset = 0;
                                _isDown = false;
                                clientDeparturePosition = client['position'];
                                clientDestinationPosition = LatLng(
                                    client['position'].latitude - 0.015,
                                    client['position'].longitude);
                                _setClientDeparture(client['position'].latitude,
                                    client['position'].longitude);
                                _setClientDestination(
                                    client['position'].latitude - 0.015,
                                    client['position'].longitude);
                              });
                            },
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Icon(
                                    Icons.location_on,
                                    color:
                                        const Color.fromARGB(255, 235, 140, 32),
                                    size: 60.0,
                                  ),
                                ),
                                Positioned(
                                  left: 40,
                                  bottom: 10,
                                  child: Column(
                                    children: [
                                      Text(
                                        '${client['name']}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '450m',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ));
                    }).toList(),
                  ),
                  if (_locationMessage != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _locationMessage!,
                          child: Stack(
                            children: [
                              Positioned(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 60.0,
                                ),
                              ),
                              Positioned(
                                left: 40,
                                bottom: 10,
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          strokeCap: StrokeCap.round,
                          points: _routePoints,
                          strokeWidth: 6.0,
                          color: Colors.green,
                        ),
                      ],
                    ),
                ],
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
                      _bottomOffset = -260;
                      _isDown = true;
                    });
                  }
                },
                child: Container(
                  height: 350,
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
                                _bottomOffset = _bottomOffset == 0 ? -260 : 0;
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
                                    Text("Amount: PHP 52"),
                                    Text("Distance: 2.75km"),
                                  ],
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: screenWidth * 0.6,
                                      decoration: BoxDecoration(
                                          color: Colors.pink,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0))),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    currentBookingPage()),
                                          );
                                        },
                                        child: Text(
                                          "Accept",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
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
                height: 200,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 52, 117),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(40.0, 30.0),
                    bottomRight: Radius.elliptical(40.0, 30.0),
                  ),
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
                    Positioned(
                      left: 15,
                      bottom: 10,
                      child: Container(
                        width: screenWidth < 410
                            ? screenWidth * 0.7
                            : screenWidth * 0.75,
                        child:
                            MySearchBar(hintText: "search all our services..."),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        // width: screenWidth * 0.15,
                        child: IconButton(
                          icon: Icon(Icons.send_sharp),
                          iconSize: 30,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.openDrawer();
                          print("Drawer opened");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 100.0, // Set the desired width
                              maxHeight: 100.0, // Set the desired height
                            ),
                            child: Image.asset(
                              'assets/images/appLogo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 110,
                      bottom: screenWidth <= 400 ? 115 : 105,
                      child: Text(
                        "Grow with US",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Stack(
        clipBehavior:
            Clip.none, // Allows the button to overflow outside the bar
        children: [
          Container(
            height: 70,
            color: const Color.fromARGB(255, 247, 52, 117),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.query_stats, color: Colors.white),
                      Text(
                        "Unattended Queries",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications, color: Colors.white),
                      Text(
                        "Notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
