import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondRoute extends StatefulWidget {
  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  double _bottomOffset = 0;
  bool _isDown = false;
  bool isCar = false;
  bool isBike = false;
  bool isTricycle = false;

  final MapController _mapController = MapController();
  TextEditingController _departureController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  LatLng? _departurePosition;
  LatLng? _destinationPosition;
  List<Map<String, dynamic>> _autocompleteResults = [];
  List<LatLng> _routePoints = [];
  bool _isTypingForDeparture = true;

  void _fetchAutocompleteResults(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1"
        "&viewbox=116.5891,21.1224,126.6056,4.2158&bounded=1";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        setState(() {
          _autocompleteResults = results
              .map((e) => {
                    "display_name": e["display_name"],
                    "lat": double.parse(e["lat"]),
                    "lon": double.parse(e["lon"]),
                  })
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching autocomplete results: $e");
    }
  }

  Future<void> _getNearestAddress(double latitude, double longitude) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String address = data['display_name'] ?? "No address found";
        if (_isTypingForDeparture) {
          _departureController.text = address;
        } else {
          _destinationController.text = address;
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  void _selectLocationFromAutocomplete(Map<String, dynamic> location) {
    final selectedLatLng = LatLng(location["lat"], location["lon"]);
    setState(() {
      _mapController.move(selectedLatLng, 16.0);
      if (_isTypingForDeparture) {
        _departurePosition = selectedLatLng;
        _departureController.text = location["display_name"];
      } else {
        _destinationPosition = selectedLatLng;
        _destinationController.text = location["display_name"];
      }

      if (_departurePosition != null && _destinationPosition != null) {
        _fetchRoute();
      }
      _autocompleteResults.clear();
    });
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 52, 117),
        title: Container(
          child: Text(
            "Book your ride.",
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
                  // swPanBoundary: LatLng(4.2158, 116.5891),
                  // nePanBoundary: LatLng(21.1224, 126.6056),
                  // boundsOptions: FitBoundsOptions(
                  //   padding: EdgeInsets.all(10.0),
                  // ),
                  onTap: (tapPosition, point) {
                    setState(() {
                      if (_isTypingForDeparture) {
                        _departurePosition = point;
                      } else {
                        _destinationPosition = point;
                      }
                      _getNearestAddress(point.latitude, point.longitude);
                      if (_departurePosition != null &&
                          _destinationPosition != null) {
                        _fetchRoute();
                      }
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    // subdomains: ['a', 'b', 'c'],
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
                        heightFactor: 1.5,
                        child: Text(
                          "Where Are you Going?",
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 25.0,
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
                      Positioned(
                        top: 70.0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 300.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isBike = !isBike;
                                      });
                                    },
                                    child: ColorFiltered(
                                      colorFilter: isBike
                                          ? ColorFilter.matrix(
                                              <double>[
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                              ],
                                            )
                                          : ColorFilter.matrix(
                                              <double>[
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                              ],
                                            ),
                                      child: Image.asset(
                                        "assets/images/bikeIcon.png",
                                        height: 40.0,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isTricycle = !isTricycle;
                                      });
                                    },
                                    child: ColorFiltered(
                                      colorFilter: isTricycle
                                          ? ColorFilter.matrix(
                                              <double>[
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                              ],
                                            )
                                          : ColorFilter.matrix(
                                              <double>[
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                              ],
                                            ),
                                      child: Image.asset(
                                        "assets/images/tricycleIcon.png",
                                        height: 40.0,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isCar = !isCar;
                                      });
                                    },
                                    child: ColorFiltered(
                                      colorFilter: isCar
                                          ? ColorFilter.matrix(
                                              <double>[
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                              ],
                                            )
                                          : ColorFilter.matrix(
                                              <double>[
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                              ],
                                            ),
                                      child: Image.asset(
                                        "assets/images/carIcon.png",
                                        height: 40.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: screenWidth * 0.7,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: TextField(
                                              controller: _departureController,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.search),
                                                suffixIcon: _departureController
                                                        .text.isNotEmpty
                                                    ? IconButton(
                                                        icon: Icon(Icons.clear),
                                                        onPressed: () {
                                                          _departureController
                                                              .clear();

                                                          setState(() {
                                                            _autocompleteResults
                                                                .clear();
                                                          });
                                                        },
                                                      )
                                                    : null,
                                                hintText:
                                                    "Select your Departure.",
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 15),
                                              ),
                                              onChanged: (value) {
                                                _isTypingForDeparture = true;
                                                setState(() {});
                                                _fetchAutocompleteResults(
                                                    value);
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            iconSize: screenWidth * 0.075,
                                            onPressed: () {
                                              setState(() {
                                                _isDown = true;
                                                _isTypingForDeparture = true;
                                                _autocompleteResults.clear();
                                                _bottomOffset = -330;
                                              });
                                            },
                                            icon: Icon(Icons.location_on),
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: screenWidth * 0.7,
                                            margin: EdgeInsets.only(top: 15.0),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: TextField(
                                              controller:
                                                  _destinationController,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.search),
                                                suffixIcon:
                                                    _destinationController
                                                            .text.isNotEmpty
                                                        ? IconButton(
                                                            icon: Icon(
                                                                Icons.clear),
                                                            onPressed: () {
                                                              _destinationController
                                                                  .clear();
                                                              setState(() {});
                                                            },
                                                          )
                                                        : null,
                                                hintText:
                                                    "Select your Destination.",
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 15),
                                              ),
                                              onChanged: (value) {
                                                _isTypingForDeparture = false;
                                                setState(() {});
                                                _fetchAutocompleteResults(
                                                    value);
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isDown = true;
                                                _isTypingForDeparture = false;
                                                _autocompleteResults.clear();
                                                _bottomOffset = -330;
                                              });
                                            },
                                            iconSize: screenWidth * 0.075,
                                            icon: Icon(Icons.location_on),
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: screenWidth,
                                decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(30.0))),
                                margin: EdgeInsets.only(top: 20.0),
                                child: TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Search Riders.",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ],
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
              ),
            ),
            if (_autocompleteResults.isNotEmpty)
              Positioned(
                left: 20.0,
                right: 20.0,
                bottom: 270, // Position the list above the text field
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: _autocompleteResults
                            .map(
                              (item) => ListTile(
                                title: Text(item["display_name"]),
                                onTap: () {
                                  _selectLocationFromAutocomplete(item);
                                },
                              ),
                            )
                            .toList(),
                      ),
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