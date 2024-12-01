import 'package:flutter/material.dart';

class OverflowingListExample extends StatefulWidget {
  @override
  _OverflowingListExampleState createState() => _OverflowingListExampleState();
}

class _OverflowingListExampleState extends State<OverflowingListExample> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _dataList = List.generate(20, (index) => "Item $index");
  bool _isListVisible = false;

  void _toggleListVisibility() {
    setState(() {
      _isListVisible = !_isListVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overflowing List Example'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'Type something',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_drop_up),
                      onPressed: _toggleListVisibility,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // List that appears above the text field
          if (_isListVisible)
            Positioned(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).size.height -
                  120, // Position the list above the text field
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 200, // Set desired height for the list
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _dataList
                          .map(
                            (item) => ListTile(
                              title: Text(item),
                              onTap: () {
                                _textController.text = item;
                                _toggleListVisibility();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: OverflowingListExample()));
}
