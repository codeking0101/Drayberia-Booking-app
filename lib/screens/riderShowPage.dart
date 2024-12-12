import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/riderListDrawer.dart';
import './homePage.dart';
import './currentBookingPage.dart';

class RiderShowPage extends StatefulWidget {
  @override
  _RiderShowPageState createState() => _RiderShowPageState();
}

class _RiderShowPageState extends State<RiderShowPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _apiKey = 'AIzaSyCXtpXXc0yB7vewvbA2h-RQ0iUsw3Xwz5Y';
  late WebSocketChannel _websocket;
  double _bottomOffset = -270;
  bool _isDown = true;
  bool _isFirst = true;
  int selectedRiderIndex = -1;
  String nickName = '';

  int vehicleType = -1;

  String _pickupLocation = '';
  String _destinationLocation = '';
  double priceBike = 0;
  double priceTricycle = 0;
  double priceCar = 0;
  double price = 0;
  double distance = 0;
  int paymentMethod = 0;

  late GoogleMapController _mapController;
  LatLng? _departurePosition;
  LatLng? _destinationPosition;
  Polyline? _routePolyline;

  List<dynamic> riders = [];
  List<dynamic> ridersInfo = [];

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getBookingInfo();

    // Connect to the WebSocket server
    _websocket = WebSocketChannel.connect(
      Uri.parse('ws://88.222.213.227:8080'),
    );

    // Listen to incoming messages
    _websocket.stream.listen((message) {
      final msg = json.decode(message);

      if (msg['msgType'] == "accepted") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => currentBookingPage(
                    fromLat: _departurePosition!.latitude,
                    fromLng: _departurePosition!.longitude,
                    toLat: _destinationPosition!.latitude,
                    toLng: _destinationPosition!.longitude,
                    distance: distance,
                    price: price,
                    riderNickName: msg['nickName'],
                  )),
        );
      }
    });

    _getNickName();
  }

  @override
  void dispose() {
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
      "type": "client",
    });
    _websocket.sink.add(jsonMsg);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.animateCamera(
      CameraUpdate.newLatLng(_departurePosition!),
    );
  }

  void _declineBook() async {
    String jsonMsg = json.encode({
      "msgType": "decline",
      "nickName": nickName,
    });
    _websocket.sink.add(jsonMsg);
    Navigator.pop(context);
  }

  void _getBookingInfo() async {
    var box = await Hive.openBox('routeData');
    double departureLatitude = box.get("departureLatitude");
    double departureLongitude = box.get("departureLongitude");
    double destinationLatitude = box.get("destinationLatitude");
    double destinationLongitude = box.get("destinationLongitude");

    double priceBike = box.get('priceBike');
    double priceTricycle = box.get('priceTricycle');
    double priceCar = box.get('priceBike');
    double price = box.get("price");
    double distance = box.get("distance");

    String pickup = box.get("pickupLocation");
    String destination = box.get("destinationLocation");

    int tov = box.get("vehicleType"); //type of vehicle

    print("asdfasdfasdfasdfasdfasdfasdfasdf");

    setState(() {
      _departurePosition = LatLng(departureLatitude, departureLongitude);
      _destinationPosition = LatLng(destinationLatitude, destinationLongitude);

      _markers.add(
        Marker(
          markerId: MarkerId('departure'),
          position: _departurePosition!,
          infoWindow: InfoWindow(title: 'Departure'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: _destinationPosition!,
          infoWindow: InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      );
      _pickupLocation = pickup;
      _destinationLocation = destination;

      this.priceBike = priceBike;
      this.priceTricycle = priceTricycle;
      this.priceCar = priceCar;
      this.price = price;
      this.distance = distance;

      vehicleType = tov;
    });
    _fetchRoute();
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
      setState(() {
        _routePolyline = Polyline(
          polylineId: PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 4,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirst) {
      _isFirst = false;
    }
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
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
                // onTap: _onMapTapped,
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _bottomOffset,
              left: 0,
              right: 0,
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
                                          "$_pickupLocation",
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
                                          "$_destinationLocation",
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
                                      "Amount: PHP ${double.parse(price.toStringAsFixed(2))}"),
                                  Text(
                                      "Distance: ${double.parse((distance / 1000).toStringAsFixed(2))}km"),
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
                                        setState(() {
                                          _bottomOffset = -370;
                                        });
                                        _declineBook();
                                      },
                                      child: Text(
                                        "Decline",
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
          ],
        ),
      ),
    );
  }
}
