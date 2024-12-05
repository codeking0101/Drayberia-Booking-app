import 'package:flutter/material.dart';
import '../verifyPhonePage.dart';

class VehicleRegisterPage extends StatefulWidget {
  @override
  _VehicleRegisterPageState createState() => _VehicleRegisterPageState();
}

class _VehicleRegisterPageState extends State<VehicleRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedVehicleType = 'Bike'; // Default vehicle type
  String _vehicleNumber = '';
  bool _isAvailableNow = true;

  void _register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => verifyPhonePage(
                  isRider: true,
                )),
      );
      print('Vehicle Type: $_selectedVehicleType');
      print('Vehicle Number: $_vehicleNumber');
      print('Available Now: $_isAvailableNow');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Vehicle Registered Successfully!')),
      // );
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
