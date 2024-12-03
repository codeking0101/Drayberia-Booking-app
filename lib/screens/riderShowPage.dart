import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/riderListDrawer.dart';

class RiderShowPage extends StatefulWidget {
  @override
  _RiderShowPageState createState() => _RiderShowPageState();
}

class _RiderShowPageState extends State<RiderShowPage> {
  double _bottomOffset = -330;
  bool _isDown = true;
  bool _isFirst = true;
  int selectedRiderIndex = -1;

  final MapController _mapController = MapController();
  LatLng? _departurePosition;
  LatLng? _destinationPosition;
  List<LatLng> _routePoints = [];

  List<dynamic> riders = [];
  List<dynamic> ridersInfo = [
    {
      "index": 0,
      "name": "123123123",
      "vehicleType": 0,
      "reviewScore": 5.0,
    },
    {
      "index": 1,
      "name": "123123123123123123123123123",
      "vehicleType": 1,
      "reviewScore": 4.0,
    },
    {
      "index": 2,
      "name": "rider3",
      "vehicleType": 2,
      "reviewScore": 3.0,
    },
    {
      "index": 3,
      "name": "rider4",
      "vehicleType": 0,
      "reviewScore": 2.0,
    }
  ];

  void _setRiderIndex(int index) {
    setState(() {
      selectedRiderIndex = index;
    });
    _mapController.move(riders[index]['position'], 18.0);
  }

  void _getRider() async {
    var box = await Hive.openBox('routeData');
    double departureLatitude = box.get("departureLatitude");
    double departureLongitude = box.get("departureLongitude");
    double destinationLatitude = box.get("destinationLatitude");
    double destinationLongitude = box.get("destinationLongitude");
    setState(() {
      _departurePosition = LatLng(departureLatitude, departureLongitude);
      _destinationPosition = LatLng(destinationLatitude, destinationLongitude);

      riders = [
        {
          "index": 0,
          "position": LatLng(departureLatitude - 0.01, departureLongitude),
        },
        {
          "index": 1,
          "position": LatLng(departureLatitude + 0.01, departureLongitude),
        },
        {
          "index": 2,
          "position": LatLng(departureLatitude, departureLongitude + 0.01),
        },
        {
          "index": 3,
          "position": LatLng(departureLatitude, departureLongitude - 0.01),
        },
      ];
    });
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final url =
        "https://router.project-osrm.org/route/v1/driving/${_departurePosition!.longitude},${_departurePosition!.latitude};${_destinationPosition!.longitude},${_destinationPosition!.latitude}?overview=full&geometries=geojson";

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

  @override
  Widget build(BuildContext context) {
    if (_isFirst) {
      _getRider();
      _isFirst = false;
    }
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: RiderListDrawer(onSignalRiderSelectIndex: _setRiderIndex),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 52, 117),
        title: Container(
          child: Text(
            "Select rider.",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          weight: 30.0,
        ),
      ),
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
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    // subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: riders.map((rider) {
                      int index = rider['index'];
                      return Marker(
                          width: 80.0,
                          height: 80.0,
                          point: rider['position'],
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
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ));
                    }).toList(),
                  ),
                  if (_departurePosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _departurePosition!,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 60.0,
                          ),
                        ),
                      ],
                    ),
                  if (_destinationPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _destinationPosition!,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 60.0,
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
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
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
                          selectedRiderIndex >= 0
                              ? "About Rider"
                              : "No Rider Selected",
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selectedRiderIndex >= 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isDown = !_isDown;
                                _bottomOffset = _bottomOffset == 0 ? -330 : 0;
                              });
                            },
                            icon: Icon(_isDown
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_circle),
                            iconSize: 40.0,
                            color: Colors.pink,
                          ),
                        ),
                      if (selectedRiderIndex >= 0)
                        Positioned(
                          top: 70.0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 300.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Table(
                                  border: TableBorder.all(),
                                  children: [
                                    TableRow(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'Name',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            '${ridersInfo[selectedRiderIndex]['name']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'Review Score',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          '${ridersInfo[selectedRiderIndex]['reviewScore']}',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'Vehicle Type',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            (ridersInfo[selectedRiderIndex]
                                                        ["vehicleType"] ==
                                                    0)
                                                ? 'Bike'
                                                : (ridersInfo[selectedRiderIndex]
                                                            ["vehicleType"] ==
                                                        1)
                                                    ? 'Tricycle'
                                                    : 'Car',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                    ]),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.pink,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30.0),
                                        ),
                                      ),
                                      width: screenWidth / 1.5,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          "Select this Rider",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }
}
