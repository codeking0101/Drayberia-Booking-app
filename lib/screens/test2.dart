// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

// class GPSApp extends StatefulWidget {
//   @override
//   _GPSAppState createState() => _GPSAppState();
// }

// class _GPSAppState extends State<GPSApp> {
//   String _locationMessage = "Press the button to get location.";

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }

//   // Check and request location permissions
//   Future<void> _checkPermissions() async {
//     PermissionStatus permission = await Permission.location.status;
//     if (permission.isDenied || permission.isPermanentlyDenied) {
//       permission = await Permission.location.request();
//     }

//     if (permission.isGranted) {
//       print("Location permission granted");
//     } else {
//       setState(() {
//         _locationMessage = "Location permission denied!";
//       });
//     }
//   }

//   // Fetch the current location
//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         setState(() {
//           _locationMessage = "Location services are disabled.";
//         });
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _locationMessage = "Location permission denied.";
//           });
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _locationMessage =
//               "Location permissions are permanently denied. Enable them in settings.";
//         });
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         _locationMessage =
//             "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
//       });
//     } catch (e) {
//       setState(() {
//         _locationMessage = "Error: $e";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("GPS App"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               _locationMessage,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _getCurrentLocation,
//               child: Text("Get Location"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: GPSApp(),
//   ));
// }
