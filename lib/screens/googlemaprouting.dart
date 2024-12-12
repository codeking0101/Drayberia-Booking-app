// import 'package:flutter/material.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// const String _apiKey = "YOUR_GOOGLE_API_KEY";

// // Reference location (e.g., somewhere in the Philippines)
// const double referenceLat = 14.5995; // Example: Manila's latitude
// const double referenceLng = 120.9842; // Example: Manila's longitude

// class AddressSearchScreen extends StatefulWidget {
//   @override
//   _AddressSearchScreenState createState() => _AddressSearchScreenState();
// }

// class _AddressSearchScreenState extends State<AddressSearchScreen> {
//   TextEditingController _controller = TextEditingController();
//   List<Prediction> _predictions = [];
//   Position? _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   // Get the current location of the user (optional)
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print("Location services are disabled.");
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.whileInUse &&
//           permission != LocationPermission.always) {
//         print("Location permissions are denied.");
//         return;
//       }
//     }

//     // Get the current position
//     _currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     setState(() {});
//   }

//   // Calculate distance between two lat-lng points (in meters)
//   double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
//     return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Search Addresses by Proximity"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             GooglePlaceAutoCompleteTextField(
//               textEditingController: _controller,
//               googleAPIKey: _apiKey,
//               inputDecoration: InputDecoration(
//                 hintText: "Enter address in the Philippines",
//                 border: OutlineInputBorder(),
//               ),
//               debounceTime: 600,
//               countries: ["ph"], // Restrict to the Philippines
//               isLatLngRequired: true,
//               getPlaceDetailWithLatLng: (Prediction prediction) {
//                 print("Place ID: ${prediction.placeId}");
//                 print("Description: ${prediction.description}");
//               },
//               itmClick: (Prediction prediction) {
//                 _controller.text = prediction.description!;
//                 _controller.selection = TextSelection.fromPosition(
//                   TextPosition(offset: prediction.description!.length),
//                 );

//                 print("Selected Place: ${prediction.description}");
//                 print("Place ID: ${prediction.placeId}");
//               },
//               onChanged: (value) {
//                 // This will trigger when the user types
//                 if (value.isNotEmpty) {
//                   _getSuggestions(value);
//                 }
//               },
//             ),
//             if (_predictions.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _predictions.length,
//                   itemBuilder: (context, index) {
//                     final prediction = _predictions[index];
//                     return ListTile(
//                       title: Text(prediction.description!),
//                       subtitle: Text(
//                           "Distance: ${_calculateDistance(referenceLat, referenceLng, prediction.lat!, prediction.lng!).toStringAsFixed(2)} meters"),
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Fetch address suggestions based on query
//   Future<void> _getSuggestions(String query) async {
//     final places = GooglePlaces(apiKey: _apiKey);
//     final response = await places.autocomplete(query, components: [Component(Component.country, "ph")]);

//     if (response.isNotEmpty) {
//       setState(() {
//         _predictions = response.predictions;
//       }

//       // Sort predictions by distance
//       _predictions.sort((a, b) {
//         double distanceA = _calculateDistance(
//           referenceLat,
//           referenceLng,
//           a.lat!,
//           a.lng!,
//         );
//         double distanceB = _calculateDistance(
//           referenceLat,
//           referenceLng,
//           b.lat!,
//           b.lng!,
//         );
//         return distanceA.compareTo(distanceB);
//       });
//     }
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: AddressSearchScreen(),
//   ));
// }
