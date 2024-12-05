import 'dart:async';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      // Function called every 5 seconds
      _myFunction();
    });
  }

  void _myFunction() {
    setState(() {
      _counter++; // Example logic
    });
    print("Function called: Counter is $_counter");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Call Function Every 5 Seconds")),
      body: Center(
        child: Text(
          "Counter: $_counter",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: MyApp()));
