// import 'package:flutter/material.dart';
import 'dart:convert';

// import './screens/authPage.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import './screens/googlemapTest.dart';

// void main() async {
//   await Hive.initFlutter();
//   runApp(MaterialApp(
//     home: authPage(),
//   ));
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_background before enabling background execution
  await FlutterBackground.initialize();

  // Check if we have permissions for background execution
  bool hasPermission = await FlutterBackground.hasPermissions;
  if (!hasPermission) {
    print("Background execution permission not granted.");
  }

  // Enable background execution (requests permission on Android if not already granted)
  await FlutterBackground.enableBackgroundExecution();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Background WebSocket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebSocketChannel? _channel;
  Timer? _timer;
  int i = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        i++;
      });
      i++;
      final jsonMsg = json.encode({
        "msgType": "test",
        "msg": i,
      });
      _channel?.sink.add(jsonMsg);
      // print("===========================>>>>$i<<<<<<=========================");
    });
    // Connect WebSocket in the background
    _connectWebSocket();
  }

  void _connectWebSocket() {
    // WebSocket connection
    _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.147.184:8080'));

    _channel?.stream.listen((message) {
      print('Received message: $message');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Background WebSocket'),
      ),
      body: Center(
        child: Text('WebSocket is running in the background. -- $i'),
      ),
    );
  }
}
