import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import './riderShowPage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondRoute extends StatefulWidget {
  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _bottomOffset = 0;
  bool _isDown = false;
  bool isCar = false;
  bool isBike = false;
  bool isTricycle = false;
  double _distance = 0;
  double _price_Bike = 0;
  double _price_Tricycle = 0;
  double _price_Car = 0;
  bool _payWithCash = true;
  bool _isSelectedWell = false;

  final MapController _mapController = MapController();
  TextEditingController _departureController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  LatLng? _departurePosition;
  LatLng? _destinationPosition;
  List<Map<String, dynamic>> _autocompleteResults = [];
  List<LatLng> _routePoints = [];
  bool _isTypingForDeparture = true;

  void _searchNearestRiders() {
    if (!_isSelectedWell) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pls select positions Correct.')),
      );
      return;
    }
    if (isBike | isTricycle | isCar) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RiderShowPage()),
      );
    } else {
      _scaffoldKey.currentState?.openDrawer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select vehicle type first.')),
      );
    }
  }

  void _calculatePrice(double distance) {
    if (distance <= 2000) {
      setState(() {
        _price_Bike = 42;
        _price_Tricycle = 42;
        _price_Car = 42;
      });
    } else {
      int distanceClip = (distance.ceil() / 2000).floor();
      setState(() {
        _price_Bike = 42 + distanceClip * 10;
        _price_Tricycle = 42 + distanceClip * 10;
        _price_Car = 42 + distanceClip * 10;
      });
    }

    print(_price_Bike);
  }

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

  void _setHiveData() async {
    var box = await Hive.openBox('routeData');
    await box.put('departureLongitude', _departurePosition!.longitude);
    await box.put('departureLatitude', _departurePosition!.latitude);

    await box.put('destinationLongitude', _destinationPosition!.longitude);
    await box.put('destinationLatitude', _destinationPosition!.latitude);

    await box.put('pickupLocation', _departureController.text);
    await box.put('destinationLocation', _destinationController.text);

    await box.put('priceBike', _price_Bike);
    await box.put('priceTricycle', _price_Tricycle);
    await box.put('priceCar', _price_Car);
  }

  void _saveVehicleType() async {
    var box = await Hive.openBox('routeData');
    if (isBike) {
      await box.put('vehicleType', 0);
    }
    if (isTricycle) {
      await box.put('vehicleType', 1);
    }
    if (isCar) {
      await box.put('vehicleType', 2);
    }
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
          _distance = data["routes"][0]["distance"];
        });
        print(_distance);
        _calculatePrice(_distance);

        setState(() {
          _routePoints = points;
          print(points);
        });
        _isSelectedWell = true;
      } else {
        print("Failed to fetch route: ${response.body}");
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
    _setHiveData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Container(
        width: 300,
        height: screenHeight,
        color: Colors.pink,
        child: Column(
          children: [
            SizedBox(
              height: 70.0,
            ),
            Text(
              "Select Vehicle Type.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isTricycle = isCar = false;
                      isBike = !isBike;
                    });
                  },
                  child: Column(
                    children: [
                      ColorFiltered(
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
                      Text(
                        "$_price_Bike",
                        style: TextStyle(
                          color: !isBike ? Colors.black87 : Colors.white,
                          fontSize: 18.0,
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBike = isCar = false;
                      isTricycle = !isTricycle;
                    });
                  },
                  child: Column(
                    children: [
                      ColorFiltered(
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
                      Text(
                        "$_price_Tricycle",
                        style: TextStyle(
                          color: !isTricycle ? Colors.black87 : Colors.white,
                          fontSize: 18.0,
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBike = isTricycle = false;
                      isCar = !isCar;
                    });
                  },
                  child: Column(
                    children: [
                      ColorFiltered(
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
                      Text(
                        "$_price_Car",
                        style: TextStyle(
                          color: !isCar ? Colors.black87 : Colors.white,
                          fontSize: 18.0,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Pay With Cash.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                Checkbox(
                  checkColor: Colors.pink,
                  activeColor: Colors.white,
                  value: _payWithCash,
                  onChanged: (bool) {
                    setState(() {
                      _payWithCash = true;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Pay With GCash.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                Checkbox(
                  checkColor: Colors.pink,
                  activeColor: Colors.white,
                  value: !_payWithCash,
                  onChanged: (bool) {
                    setState(() {
                      _payWithCash = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
                    subdomains: ['a', 'b', 'c'],
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
                height: 350,
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
                          "Where Are you Going?",
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
                              _bottomOffset = _bottomOffset == 0 ? -250 : 0;
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
                        top: 60.0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 310.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
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
                                                    "Select your Location.",
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
                                                _bottomOffset = -250;
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
                                                _bottomOffset = -250;
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
                                  onPressed: () {
                                    _saveVehicleType();
                                    _searchNearestRiders();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Book ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: 30.0,
                                      // ),
                                      if (isBike)
                                        Image.asset(
                                          height: 30.0,
                                          'assets/images/bikeIcon.png',
                                        ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      if (isTricycle)
                                        Image.asset(
                                          height: 30.0,
                                          'assets/images/tricycleIcon.png',
                                        ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      if (isCar)
                                        Image.asset(
                                          height: 30.0,
                                          'assets/images/carIcon.png',
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
