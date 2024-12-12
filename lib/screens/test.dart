import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketExample extends StatefulWidget {
  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  late WebSocketChannel _channel;
  String _message = "Waiting for messages...";

  @override
  void initState() {
    super.initState();
    // Connect to the WebSocket server
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://88.222.213.227:8080'),
    );

    // Listen to incoming messages
    _channel.stream.listen((message) {
      setState(() {
        _message = message;
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close(); // Close the connection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebSocket Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _channel.sink.add('Hello from Flutter!');
              },
              child: Text("Send Message"),
            ),
          ],
        ),
      ),
    );
  }
}
