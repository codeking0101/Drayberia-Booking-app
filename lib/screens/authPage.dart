import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/customSwitch.dart';
import '../screens/homePage.dart';
import './rider/vehicleRegisterPage.dart';
import '../screens/verifyPhonePage.dart';
import './loginPage.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class authPage extends StatefulWidget {
  @override
  _authPageState createState() => _authPageState();
}

class _authPageState extends State<authPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _nickName = '';
  String _phoneNumber = '';
  String _password = '';

  bool _isRider = false;

  void _setAsRider(bool) {}

  void _saveNickName(String nickName) async {
    var box = await Hive.openBox('userData');
    await box.put('nickName', nickName);
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (!_isRider) {
        _registerClient(_name, _nickName, _password, _phoneNumber);
      } else {
        _registerRider(_name, _nickName, _password, _phoneNumber);
      }
    }
  }

  Future<void> _registerClient(
      String name, String nickName, String password, String phoneNumber) async {
    final url = "http://88.222.213.227:5000/api/client/registry";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "name": name,
          "nickName": nickName,
          "password": password,
          "phoneNumber": int.parse(phoneNumber),
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );

      if (response.statusCode == 200) {
        _saveNickName(_nickName);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => verifyPhonePage(
                    isRider: false,
                  )),
        );
      }
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _registerRider(
      String name, String nickName, String password, String phoneNumber) async {
    final url = "http://88.222.213.227:5000/api/rider/registry";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "name": name,
          "nickName": nickName,
          "password": password,
          "phoneNumber": int.parse(phoneNumber),
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );

      if (response.statusCode == 200) {
        _saveNickName(_nickName);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VehicleRegisterPage()),
        );
      }
    } catch (e) {
      setState(() {});
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
                  _nickName = value!;
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
                  _phoneNumber = value!;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => loginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
