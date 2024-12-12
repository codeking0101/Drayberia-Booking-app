import 'package:DRAYBERYA/widgets/riderDrawer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/riderDrawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/searchBar.dart';
import './currentBookingPage.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:async';

class RiderHomePage extends StatefulWidget {
  @override
  _RiderHomePageState createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late WebSocketChannel _websocket;
  late GoogleMapController _mapController;
  final String _apiKey = 'AIzaSyCXtpXXc0yB7vewvbA2h-RQ0iUsw3Xwz5Y';

  Timer? _timer;
  double _leftOffset = -300;
  double _bottomOffset = -400;
  bool _isDown = false;
  bool isDisposed = false;
  int _selectedIndex = 0;
  LatLng? _myLocation;
  String nickName = '';
  String clientNickName = '';
  int _newBookingCnt = 0;

  double _price = 0;
  double _distance = 0;
  bool isFirst = true;

  Set<Marker> _markers = {};

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
    _fetchwaitingClients();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getCurrentLocation();
    });

    // Connect to the WebSocket server
    _websocket = WebSocketChannel.connect(
      Uri.parse('ws://88.222.213.227:8080'),
    );

    // Listen to incoming messages
    _websocket.stream.listen((message) {
      final msg = json.decode(message);

      print("==================>>>>>>>>>>>>>>>>>>>");
      print(msg['msgType'] == "accepted");
      print("==================>>>>>>>>>>>>>>>>>>>");

      if (msg['msgType'] == "newBooking") {
        setState(() {
          waitingClients.add(msg);

          for (int i = 0; i < waitingClients.length; i++) {
            setState(() {
              _markers.add(
                Marker(
                  onTap: () {
                    setState(() {
                      _mapController.animateCamera(
                        CameraUpdate.newLatLng(LatLng(
                            waitingClients[i]['fromLat'],
                            waitingClients[i]['fromLng'])),
                      );
                      _bottomOffset = 0;
                      _leftOffset = -300;
                      _isDown = false;
                      clientDeparturePosition = LatLng(
                          waitingClients[i]['fromLat'],
                          waitingClients[i]['fromLng']);
                      clientDestinationPosition = LatLng(
                          waitingClients[i]['toLat'],
                          waitingClients[i]['toLng']);
                      _setClientDeparture(waitingClients[i]['fromLat'],
                          waitingClients[i]['fromLng']);
                      _setClientDestination(waitingClients[i]['toLat'],
                          waitingClients[i]['toLng']);
                      _distance = waitingClients[i]['distance'].toDouble();
                      _price = waitingClients[i]['price'].toDouble();
                      clientNickName = waitingClients[i]['nickName'];
                    });
                    setState(() {
                      _selectedIndex = i;
                    });
                  },
                  markerId: MarkerId('client$i'),
                  position: LatLng(waitingClients[i]['fromLat'],
                      waitingClients[i]['fromLng']),
                  infoWindow: InfoWindow(title: waitingClients[i]['nickName']),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                ),
              );
            });
          }
          _newBookingCnt++;
        });
        print(msg);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New booking!')),
        );
      } else if (msg['msgType'] == "accepted") {
        print("==================>>>>>>>>>>>>>>>>>>>");
        print(waitingClients.length);
        print("==================>>>>>>>>>>>>>>>>>>>");

        for (int i = 0; i < waitingClients.length; i++) {
          if (waitingClients[i]['nickName'] == msg['clientNickName']) {
            setState(() {
              waitingClients.removeAt(i);
            });
          }
        }
        if (_newBookingCnt > 0) {
          _newBookingCnt--;
        }
        print(
            "asdfdvadshfkjlahdslfiuyhlqijehwlkjfbhlkj-----------------------------");

        print(waitingClients);

        setState(() {
          _markers.clear();
        });

        for (int i = 0; i < waitingClients.length; i++) {
          setState(() {
            _markers.add(
              Marker(
                onTap: () {
                  setState(() {
                    _mapController.animateCamera(
                      CameraUpdate.newLatLng(LatLng(
                          waitingClients[i]['fromLat'],
                          waitingClients[i]['fromLng'])),
                    );
                    _bottomOffset = 0;
                    _leftOffset = -300;
                    _isDown = false;
                    clientDeparturePosition = LatLng(
                        waitingClients[i]['fromLat'],
                        waitingClients[i]['fromLng']);
                    clientDestinationPosition = LatLng(
                        waitingClients[i]['toLat'], waitingClients[i]['toLng']);
                    _setClientDeparture(waitingClients[i]['fromLat'],
                        waitingClients[i]['fromLng']);
                    _setClientDestination(
                        waitingClients[i]['toLat'], waitingClients[i]['toLng']);
                    _distance = waitingClients[i]['distance'].toDouble();
                    _price = waitingClients[i]['price'].toDouble();
                    clientNickName = waitingClients[i]['nickName'];
                  });
                  setState(() {
                    _selectedIndex = i;
                  });
                },
                markerId: MarkerId('client$i'),
                position: LatLng(
                    waitingClients[i]['fromLat'], waitingClients[i]['fromLng']),
                infoWindow: InfoWindow(title: waitingClients[i]['nickName']),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange),
              ),
            );
          });
        }
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

  void _fetchwaitingClients() async {
    final url = "http://88.222.213.227:5000/api/client/waitingClients";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
      });

      final waitingClients = json.decode(response.body);

      for (int i = 0; i < waitingClients['awaitingBooking'].length; i++) {
        setState(() {
          _markers.add(
            Marker(
              onTap: () {
                setState(() {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(LatLng(
                        waitingClients['awaitingBooking'][i]['fromLat'],
                        waitingClients['awaitingBooking'][i]['fromLng'])),
                  );
                  _bottomOffset = 0;
                  _leftOffset = -300;
                  _isDown = false;
                  clientDeparturePosition = LatLng(
                      waitingClients['awaitingBooking'][i]['fromLat'],
                      waitingClients['awaitingBooking'][i]['fromLng']);
                  clientDestinationPosition = LatLng(
                      waitingClients['awaitingBooking'][i]['toLat'],
                      waitingClients['awaitingBooking'][i]['toLng']);
                  _setClientDeparture(
                      waitingClients['awaitingBooking'][i]['fromLat'],
                      waitingClients['awaitingBooking'][i]['fromLng']);
                  _setClientDestination(
                      waitingClients['awaitingBooking'][i]['toLat'],
                      waitingClients['awaitingBooking'][i]['toLng']);
                  _distance = waitingClients['awaitingBooking'][i]['distance']
                      .toDouble();
                  _price =
                      waitingClients['awaitingBooking'][i]['price'].toDouble();
                  clientNickName =
                      waitingClients['awaitingBooking'][i]['nickName'];
                });
                setState(() {
                  _selectedIndex = i;
                });
              },
              markerId: MarkerId('client$i'),
              position: LatLng(waitingClients['awaitingBooking'][i]['fromLat'],
                  waitingClients['awaitingBooking'][i]['fromLng']),
              infoWindow: InfoWindow(
                  title: waitingClients['awaitingBooking'][i]['nickName']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
            ),
          );
        });
      }
      setState(() {
        this.waitingClients = waitingClients['awaitingBooking'];
      });
    } catch (e) {
      print("Error fetching autocomplete results: $e");
    }
  }

  void _saveCurrentBooking() async {
    final url = "http://88.222.213.227:5000/api/rider/bookRide";

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "nickName": nickName,
            "clientNickName": clientNickName,
            "fromLat": clientDeparturePosition?.latitude,
            "fromLng": clientDeparturePosition?.longitude,
            "toLat": clientDestinationPosition?.latitude,
            "toLng": clientDestinationPosition?.longitude,
            "fromLocation": clientDeparture,
            "toLocation": clientDestination,
            "distance": _distance.toDouble(),
            "price": _price.toDouble(),
            "vehicleType": 0,
            "paymentMethod": 0,
          }));
    } catch (e) {
      print("Error fetching autocomplete results: $e");
    }
  }

  void _payForAccept(double amount) async {
    final url = "http://88.222.213.227:5000/api/rider/payforAccept";

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "nickName": nickName,
            "moneyValue": amount,
          }));

      print(response.body);

      final result = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => currentBookingPage(
                    fromLat: clientDeparturePosition!.latitude,
                    fromLng: clientDeparturePosition!.longitude,
                    toLat: clientDestinationPosition!.latitude,
                    toLng: clientDestinationPosition!.longitude,
                    distance: _distance,
                    price: _price,
                    clientNickName: this.clientNickName,
                  )),
        );

        _saveCurrentBooking();
        String jsonMsg = json.encode({
          "msgType": "accept",
          "clientNickName": clientNickName,
          "nickName": nickName,
        });
        _websocket.sink.add(jsonMsg);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['msg'])),
        );
      }
    } catch (e) {
      print("Error fetching autocomplete results: $e");
    }
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
        });
      }
      if (isFirst) {
        isFirst = false;

        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
    double screenHeigh = MediaQuery.of(context).size.height;
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
                onTap: (pointer) {
                  setState(() {
                    _leftOffset = -300;
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(11.55, 124.75), // Default location
                  zoom: 10,
                ),
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                markers: _markers,
                // cameraTargetBounds: CameraTargetBounds(philippinesBounds),
                // polylines: {
                //   if (_routePoints2Client != null && !isRideStarted)
                //     _routePoints2Client!,
                //   if (_routePoints2Destination != null)
                //     _routePoints2Destination!,
                // },
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
                                    Text(
                                        "Amount: PHP ${double.parse(_price.toStringAsFixed(2))}"),
                                    Text(
                                        "Distance: ${double.parse((_distance / 1000).toStringAsFixed(2))}km"),
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
                                            _bottomOffset = -400;
                                          });
                                          _payForAccept(_price);
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
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _leftOffset,
              child: Stack(
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx < 0) {
                        setState(() {
                          _leftOffset = -300;
                        });
                      }
                    },
                    child: Container(
                      height: screenHeigh - 70,
                      width: 300,
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
                        padding: const EdgeInsets.all(0.0),
                        child: ListView.builder(
                          itemCount: waitingClients.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _mapController.animateCamera(
                                    CameraUpdate.newLatLng(LatLng(
                                        waitingClients[index]['fromLat'],
                                        waitingClients[index]['fromLng'])),
                                  );
                                  _bottomOffset = 0;
                                  _leftOffset = -300;
                                  _isDown = false;
                                  clientDeparturePosition = LatLng(
                                      waitingClients[index]['fromLat'],
                                      waitingClients[index]['fromLng']);
                                  clientDestinationPosition = LatLng(
                                      waitingClients[index]['toLat'],
                                      waitingClients[index]['toLng']);
                                  _setClientDeparture(
                                      waitingClients[index]['fromLat'],
                                      waitingClients[index]['fromLng']);
                                  _setClientDestination(
                                      waitingClients[index]['toLat'],
                                      waitingClients[index]['toLng']);
                                  _distance = waitingClients[index]['distance']
                                      .toDouble();
                                  _price =
                                      waitingClients[index]['price'].toDouble();
                                  clientNickName =
                                      waitingClients[index]['nickName'];
                                });
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: Container(
                                height: 75.0,
                                padding: EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                  color: _selectedIndex == index
                                      ? const Color.fromARGB(255, 153, 145, 148)
                                      : (index % 2 == 0
                                          ? const Color.fromARGB(
                                              255, 223, 221, 221)
                                          : const Color.fromARGB(
                                              255, 238, 234, 234)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedIndex == index
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255, 58, 51, 51),
                                      ),
                                    ),
                                    Text(
                                      "${waitingClients[index]['nickName']}",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedIndex == index
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255, 58, 51, 51),
                                      ),
                                    ),
                                    Text(
                                      "${double.parse((waitingClients[index]['distance'] / 1000).toStringAsFixed(2))}km",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedIndex == index
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255, 58, 51, 51),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
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
                  onPressed: () {
                    setState(() {
                      _newBookingCnt = 0;
                      _leftOffset = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 65,
                        child: Stack(
                          children: [
                            Center(
                              child:
                                  Icon(Icons.query_stats, color: Colors.white),
                            ),
                            if (_newBookingCnt > 0)
                              Positioned(
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          "$_newBookingCnt",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
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
      drawer: RiderDrawer(),
    );
  }
}
