import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class addFundPage extends StatefulWidget {
  @override
  _addFundPageState createState() => _addFundPageState();
}

class _addFundPageState extends State<addFundPage> {
  final TextEditingController _refNoController = TextEditingController();
  final TextEditingController _addAmountController = TextEditingController();
  String nickName = '';
  double walletBalance = 0;

  @override
  void initState() {
    super.initState();
    _getNickName();
  }

  void _getNickName() async {
    var box = await Hive.openBox('userData');
    String nickName = await box.get('nickName');
    setState(() {
      this.nickName = nickName;
    });
    _getWalletBal();
  }

  void _getWalletBal() async {
    final url = "http://88.222.213.227:5000/api/rider/walletBalance";

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "nickName": this.nickName,
          }));

      final result = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          double temp = result['walletBal'].toDouble();
          this.walletBalance = double.parse(temp.toStringAsFixed(2));
          print(walletBalance);
        });
      }
    } catch (e) {
      print("Error fetching wallet bal. results: $e");
    }
  }

  void _addFund(double amount) async {
    final url = "http://88.222.213.227:5000/api/rider/updateWallet";

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "nickName": this.nickName,
            "moneyValue": amount,
          }));

      final result = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          this.walletBalance = walletBalance + amount;
        });
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['msg'])),
        );
      }
    } catch (e) {
      print("Error updating wallet bal. results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Funds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Funds',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Current Amount: PHP ${walletBalance}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Amount to Add: PHP',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: TextField(
                    controller: _addAmountController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'amount',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Ref No:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _refNoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reference number',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_addAmountController.text == '' ||
                        _refNoController.text == '') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('input invalid!')),
                      );
                    } else
                      _addFund(double.parse(_addAmountController.text));
                  },
                  child: Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
