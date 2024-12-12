import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

const String _apiKey = "AIzaSyCXtpXXc0yB7vewvbA2h-RQ0iUsw3Xwz5Y";

class AddressSearchScreen extends StatefulWidget {
  @override
  _AddressSearchScreenState createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Places Autocomplete"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GooglePlaceAutoCompleteTextField(
              textEditingController: _controller,
              googleAPIKey: _apiKey,
              inputDecoration: InputDecoration(
                hintText: "Enter address",
                border: OutlineInputBorder(),
              ),
              debounceTime: 600, // Debounce time in milliseconds
              countries: ["ph"], // Restrict results to specific countries
              isLatLngRequired: true, // Include latitude and longitude
              getPlaceDetailWithLatLng: (prediction) {
                // This function is triggered when a user selects a suggestion
                print("Place ID: ${prediction.placeId}");
                print("Description: ${prediction.description}");
              },
              itemClick: (Prediction prediction) {
                // This function is triggered when an item is clicked
                _controller.text = prediction.description!;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description!.length),
                );

                print("Selected Place: ${prediction.description}");
                print("Place ID: ${prediction.placeId}");
              },
            ),
          ],
        ),
      ),
    );
  }
}
