import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/customSwitch.dart';
import '../screens/homePage.dart';
import './rider/vehicleRegisterPage.dart';
import '../screens/verifyPhonePage.dart';

class authPage extends StatefulWidget {
  @override
  _authPageState createState() => _authPageState();
}

class _authPageState extends State<authPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';

  bool _isRider = false;

  void _setAsRider(bool) {}

  void _register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (!_isRider) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => verifyPhonePage(
                    isRider: false,
                  )),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VehicleRegisterPage()),
        );
      }
      // Perform registration logic here
      print('Name: $_name, Email: $_email, Password: $_password');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Registration successful!')),
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your user name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("I am a rider."),
                  Checkbox(
                    value: _isRider,
                    onChanged: (bool) {
                      setState(() {
                        _isRider = !_isRider;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black54,
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
