import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import './riderShowPage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class SecondRoute extends StatefulWidget {
  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController _mapController;
  late WebSocketChannel _websocket;
  String _message = "Waiting for messages...";
  String nickName = '';

  Set<Marker> _markers = {};

  double _bottomOffset = 0;
  bool _isDown = false;
  bool isCar = false;
  bool isBike = false;
  bool isTricycle = false;
  double _distance = 0;
  double _price_Bike = 0.0;
  double _price_Tricycle = 0.0;
  double _price_Car = 0.0;
  bool _payWithCash = true;
  bool _isSelectedWell = false;
  bool isDisposed = false;
  bool isFirst = true;
  LatLng? _myLocation;

  TextEditingController _departureController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  LatLng? _departurePosition;
  LatLng? _destinationPosition;
  List<dynamic> _autocompleteResults = [];
  List<LatLng> _routePoints = [];
  Polyline? _routePolyline;
  bool _isTypingForDeparture = true;

  final String _apiKey = 'AIzaSyCXtpXXc0yB7vewvbA2h-RQ0iUsw3Xwz5Y';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getCurrentLocation();

    // Connect to the WebSocket server
    _websocket = WebSocketChannel.connect(
      Uri.parse('ws://88.222.213.227:8080'),
    );

    // Listen to incoming messages
    _websocket.stream.listen((message) {
      setState(() {
        _message = message;
      });
      print(message);
    });

    _getNickName();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
    _websocket.sink.close();
  }

  ///////////////////////////////////////////////

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng position) async {
    setState(() {
      if (_isTypingForDeparture) {
        _departurePosition = position;
        _markers.add(
          Marker(
            markerId: MarkerId('departure'),
            position: position,
            infoWindow: InfoWindow(title: 'Departure'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ),
        );
      } else {
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: position,
            infoWindow: InfoWindow(
              title: 'Destination',
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          ),
        );
        _destinationPosition = position;
      }
      _getNearestAddress(position.latitude, position.longitude);
      if (_departurePosition != null && _destinationPosition != null) {
        _fetchRoute();
      }
    });
  }

  ////////////////////////////////////////////////////

  void _getNickName() async {
    var box = await Hive.openBox('userData');
    String nickName = await box.get('nickName');
    setState(() {
      this.nickName = nickName;
    });
    String jsonMsg = json.encode({
      "msgType": "hello",
      "nickName": nickName,
      "type": "client",
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
          _myLocation = LatLng(position.latitude, position.longitude);

          print(_myLocation);
        });
      }
      if (isFirst) {
        isFirst = false;
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
        setState(() {
          _departurePosition = _myLocation!;
          _markers.add(
            Marker(
              markerId: MarkerId('departure'),
              position: _myLocation!,
              infoWindow: InfoWindow(title: 'Departure'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            ),
          );
        });
        _getNearestAddressForDeparture(position.latitude, position.longitude);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _bookRide() async {
    final url = "http://88.222.213.227:5000/api/client/bookRide";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "nickName": nickName,
          "fromLat": _departurePosition?.latitude,
          "fromLng": _departurePosition?.longitude,
          "toLat": _destinationPosition?.latitude,
          "toLng": _destinationPosition?.longitude,
          "fromLocation": _departureController.text,
          "toLocation": _destinationController.text,
          "distance": _distance,
          "price": isBike
              ? _price_Bike
              : isTricycle
                  ? _price_Tricycle
                  : _price_Car,
          "vehicleType": isBike
              ? 0
              : isTricycle
                  ? 1
                  : 2,
          "paymentMethod": _payWithCash ? 0 : 1,
        }),
      );
      if (response.statusCode == 200) {
        String notification = json.encode({
          "msgType": "newBooking",
          "nickName": nickName,
          "fromLat": _departurePosition?.latitude,
          "fromLng": _departurePosition?.longitude,
          "toLat": _destinationPosition?.latitude,
          "toLng": _destinationPosition?.longitude,
          "distance": _distance,
          "price": isBike
              ? _price_Bike
              : isTricycle
                  ? _price_Tricycle
                  : _price_Car,
          "vehicleType": isBike
              ? 0
              : isTricycle
                  ? 1
                  : 2,
          "paymentMethod": _payWithCash ? 0 : 1,
        });
        _websocket.sink.add(notification);
      }
    } catch (e) {
      print("Error fetching autocomplete results: $e");
    }
  }

  void _searchNearestRiders() {
    if (!_isSelectedWell) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pls select positions Correct.')),
      );
      return;
    }
    if (isBike | isTricycle | isCar) {
      _setHiveData();
      _bookRide();
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
    if (distance <= 3000) {
      setState(() {
        _price_Bike = 41.0;
        _price_Tricycle = 120.0;
        _price_Car = 200.0;
      });
    } else {
      setState(() {
        if (distance < 5000) {
          _price_Bike = 41.0 + (distance - 3000) / 1000 * 15;
          _price_Tricycle = 120.0 + (distance - 3000) / 1000 * 15;
          _price_Car = 200.0 + (distance - 3000) / 1000 * 15;
        } else if (distance < 8000) {
          _price_Bike = 41.0 + (distance - 3000) / 1000 * 16;
          _price_Tricycle = 120.0 + (distance - 3000) / 1000 * 16;
          _price_Car = 200.0 + (distance - 3000) / 1000 * 16;
        } else if (distance < 11000) {
          _price_Bike = 41.0 + (distance - 3000) / 1000 * 17;
          _price_Tricycle = 120.0 + (distance - 3000) / 1000 * 17;
          _price_Car = 200.0 + (distance - 3000) / 1000 * 17;
        } else if (distance < 15000) {
          _price_Bike = 41.0 + (distance - 3000) / 1000 * 18;
          _price_Tricycle = 120.0 + (distance - 3000) / 1000 * 18;
          _price_Car = 200.0 + (distance - 3000) / 1000 * 18;
        } else {
          _price_Bike = 41.0 + (distance - 3000) / 1000 * 19;
          _price_Tricycle = 120.0 + (distance - 3000) / 1000 * 19;
          _price_Car = 200.0 + (distance - 3000) / 1000 * 19;
        }
      });
    }

    print(_price_Bike);
  }

  void _fetchAutocompleteResults(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&location=${_myLocation!.latitude},${_myLocation!.longitude}&radius=50000&language=en&components=country:ph';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if there are results

        print(data);
        if (data['predictions'] != null && data['predictions'].isNotEmpty) {
          setState(() {
            _autocompleteResults = data['predictions']
                .map((result) => {
                      'display_name': result['description'],
                      'placeId': result['place_id'],
                    })
                .toList();
          });
        } else {
          setState(() {
            _autocompleteResults = [];
          });
        }
      } else {
        print('Error fetching autocomplete results: ${response.statusCode}');
        setState(() {
          _autocompleteResults = [];
        });
      }
    } catch (e) {
      print("Error fetching autocomplete results: $e");
      setState(() {
        _autocompleteResults = [];
      });
    }
  }

  Future<void> _getNearestAddressForDeparture(
      double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String address =
            data['results'][0]['formatted_address'] ?? "No address found";
        _departureController.text = address;
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  Future<void> _getNearestAddress(double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String address =
            data['results'][0]['formatted_address'] ?? "No address found";
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

  Future<Map<String, dynamic>> getLatLngfromid(String placeId) async {
    final placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    final response = await http.get(Uri.parse(placeDetailsUrl));

    if (response.statusCode == 200) {
      // Parse the response JSON
      final data = jsonDecode(response.body);
      final result = data['result'];

      // Extract latitude and longitude
      final latitude = result['geometry']['location']['lat'];
      final longitude = result['geometry']['location']['lng'];

      return {
        'lat': latitude,
        'lng': longitude,
        'formatted_address': result['formatted_address'],
      };
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  void _selectLocationFromAutocomplete(Map<String, dynamic> location) async {
    final selectedLatLng = await getLatLngfromid(location['placeId']);
    setState(() {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
            LatLng(selectedLatLng['lat'], selectedLatLng['lng'])),
      );
      if (_isTypingForDeparture) {
        _departurePosition =
            LatLng(selectedLatLng['lat'], selectedLatLng['lng']);
        _markers.add(
          Marker(
            markerId: MarkerId('departure'),
            position: _departurePosition!,
            infoWindow: InfoWindow(title: 'Departure'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ),
        );
        _departureController.text = location['display_name'];
      } else {
        _destinationPosition =
            LatLng(selectedLatLng['lat'], selectedLatLng['lng']);
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: _destinationPosition!,
            infoWindow: InfoWindow(title: 'Destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          ),
        );
        _destinationController.text = location['display_name'];
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

    await box.put('distance', _distance);

    await box.put(
        'price',
        isBike
            ? _price_Bike
            : isTricycle
                ? _price_Tricycle
                : _price_Car);

    await box.put('paymentMethod', _payWithCash ? 0 : 1);
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

  Future<void> _fetchRoute() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_departurePosition?.latitude},${_departurePosition?.longitude}&destination=${_destinationPosition?.latitude},${_destinationPosition?.longitude}&mode=driving&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      final polylinePoints = _decodePolyline(points);
      final route = data['routes'][0];
      final leg = route['legs'][0];
      _distance = leg['distance']['value'].toDouble();
      setState(() {
        _routePolyline = Polyline(
          polylineId: PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 4,
        );
      });

      _calculatePrice(_distance);
      _isSelectedWell = true;
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
                        "${double.parse(_price_Bike.toStringAsFixed(2))}",
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
                        "${double.parse(_price_Tricycle.toStringAsFixed(2))}",
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
                        "${double.parse(_price_Car.toStringAsFixed(2))}",
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
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(11.55, 124.75), // Default location
                  zoom: 10,
                ),
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                markers: _markers,
                // cameraTargetBounds: CameraTargetBounds(philippinesBounds),
                polylines: _routePolyline != null
                    ? {
                        _routePolyline!,
                      }
                    : {},
                onTap: _onMapTapped,
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
                                                              setState(() {
                                                                _autocompleteResults
                                                                    .clear();
                                                              });
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
