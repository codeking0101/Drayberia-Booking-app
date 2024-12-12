import 'package:flutter/material.dart';
import '../verifyPhonePage.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class VehicleRegisterPage extends StatefulWidget {
  @override
  _VehicleRegisterPageState createState() => _VehicleRegisterPageState();
}

class _VehicleRegisterPageState extends State<VehicleRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedVehicleType = 'Bike'; // Default vehicle type
  String _vehicleNumber = '';
  bool _isAvailableNow = true;

  Future<String> _getNickName() async {
    var box = await Hive.openBox('userData');

    String nickName = box.get("nickName");

    print(nickName);

    return nickName;
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String nickName = await _getNickName();

      final url = "http://88.222.213.227:5000/api/rider/vehicle";

      try {
        final response = await http.put(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "nickName": nickName,
            "vehicleType": _selectedVehicleType == 'Bike'
                ? 0
                : _selectedVehicleType == 'Tricycle'
                    ? 1
                    : 2,
            "vehicleNumber": _vehicleNumber,
          }),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => verifyPhonePage(
                      isRider: true,
                    )),
          );
        }
      } catch (e) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                items: ['Bike', 'Tricycle', 'Car']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _vehicleNumber = value!;
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    value: _isAvailableNow,
                    onChanged: (value) {
                      setState(() {
                        _isAvailableNow = value!;
                      });
                    },
                  ),
                  Text('Available Now'),
                ],
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
