import 'package:flutter/material.dart';

// Define the StatefulWidget and its props
class CounterWidget extends StatefulWidget {
  final String label; // A property for the widget
  final int initialValue; // A property for the initial counter value

  // Constructor to accept props
  CounterWidget({required this.label, this.initialValue = 0});

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

// Define the State class
class _CounterWidgetState extends State<CounterWidget> {
  late int counter; // Local state variable

  @override
  void initState() {
    super.initState();
    // Initialize the local state using the widget's props
    counter = widget.initialValue;
  }

  // Increment the counter
  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${widget.label}: $counter', // Access props using `widget`
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: incrementCounter,
          child: Text('Increment'),
        ),
      ],
    );
  }
}

void main() => runApp(MaterialApp(home: MyHomePage()));

// Main app screen
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stateful Widget Props Example')),
      body: Center(
        child: CounterWidget(
          label: 'Count', // Pass the label as a prop
          initialValue: 10, // Pass the initial value as a prop
        ),
      ),
    );
  }
}