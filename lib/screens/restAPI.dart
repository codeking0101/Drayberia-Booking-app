import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostRequestExample extends StatefulWidget {
  @override
  _PostRequestExampleState createState() => _PostRequestExampleState();
}

class _PostRequestExampleState extends State<PostRequestExample> {
  String _response = "Response will be shown here";

  Future<void> _sendPostRequest() async {
    final url = Uri.parse("https://jsonplaceholder.typicode.com/posts");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "title": "Hello Flutter",
          "body": "This is a sample POST request",
          "userId": 1,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _response = "Success: ${response.body}";
        });
      } else {
        setState(() {
          _response = "Error: ${response.statusCode}, ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Exception: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("POST Request Example")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _sendPostRequest,
              child: Text("Send POST Request"),
            ),
            SizedBox(height: 20),
            Text(
              _response,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
