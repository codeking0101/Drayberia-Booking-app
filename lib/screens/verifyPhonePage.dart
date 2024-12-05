import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import '../widgets/customSwitch.dart';
import '../screens/homePage.dart';
import '../screens/rider/homePage.dart';

class verifyPhonePage extends StatefulWidget {
  final bool isRider;

  verifyPhonePage({this.isRider = false});
  @override
  _verifyPhonePageState createState() => _verifyPhonePageState();
}

class _verifyPhonePageState extends State<verifyPhonePage> {
  final _formKey = GlobalKey<FormState>();
  String? _verifyCode = '';

  void _register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_verifyCode == "123456") {
        if (!widget.isRider)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => myHomePage()),
          );
        else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RiderHomePage()),
          );
        }
      } else
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verify Code invalid!')),
        );
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
              Text("Verify Code send to your phone number."),
              SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Verify Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your code';
                  }
                  return null;
                },
                onSaved: (value) {
                  _verifyCode = value;
                },
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
                  'Submit',
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
