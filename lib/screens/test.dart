import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ParentWidget(),
    );
  }
}

class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  String message = "No signal received";

  void _updateMessage(String newMessage) {
    setState(() {
      message = newMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signal Transmission Example")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          SizedBox(height: 20),
          ChildWidget(onSignalSent: _updateMessage),
        ],
      ),
    );
  }
}

class ChildWidget extends StatelessWidget {
  final Function(String) onSignalSent;

  ChildWidget({required this.onSignalSent});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onSignalSent("Signal received from ChildWidget!"),
      child: Text("Send Signal"),
    );
  }
}
