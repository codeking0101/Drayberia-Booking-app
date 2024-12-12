import 'dart:convert';

import 'package:flutter/material.dart';
import '../screens/test.dart';
import '../screens/rider/currentBookingPage.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/rider/addFundPage.dart';

class RiderDrawer extends StatefulWidget {
  @override
  _RiderDrawerState createState() => _RiderDrawerState();
}

class _RiderDrawerState extends State<RiderDrawer> {
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
        });
      }
    } catch (e) {
      print("Error fetching wallet bal. results: $e");
    }
  }

  void _addFund(double amount) async {
    final url = "http://88.222.213.227:5000/api/client/updateWallet";

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
      }
    } catch (e) {
      print("Error updating wallet bal. results: $e");
    }
  }

  void _fetchAcceptedBooking() async {
    final url = "http://88.222.213.227:5000/api/rider/hasAcceptedBooking";

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
        if (result['msg'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have no Accepted Booking yet!')),
          );
        } else if (result['msg'] == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => currentBookingPage(
                      fromLat: result['AcceptedBooking']['fromLat'],
                      fromLng: result['AcceptedBooking']['fromLng'],
                      toLat: result['AcceptedBooking']['toLat'],
                      toLng: result['AcceptedBooking']['toLng'],
                      distance:
                          result['AcceptedBooking']['distance'].toDouble(),
                      price: result['AcceptedBooking']['price'].toDouble(),
                      clientNickName: result['AcceptedBooking']
                          ['clientNickName'],
                    )),
          );
        }
      }
    } catch (e) {
      print("Error updating wallet bal. results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 100.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("${nickName}"),
            accountEmail: Text(
              "Wallet: PHP ${walletBalance}",
              style: TextStyle(fontSize: 18.0),
            ),
            currentAccountPicture: ClipOval(
              child: Image.network(
                'https://i.postimg.cc/jSFD1MMR/all-bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 52, 117),
            ),
          ),
          ListTile(
            onTap: () {
              _fetchAcceptedBooking();
            },
            title: new Text("Active Order"),
            leading: new Icon(Icons.route),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addFundPage()),
              );
            },
            title: new Text("Add funds"),
            leading: new Icon(Icons.add_box),
          ),
          Divider(
            height: 0.1,
          ),
          ListTile(
            title: new Text("Settings"),
            leading: new Icon(Icons.settings),
          ),
          ListTile(
            title: new Text("Mail"),
            leading: new Icon(Icons.message),
          ),
          ListTile(
            onTap: () {},
            title: new Text("History"),
            leading: new Icon(Icons.history),
          ),
          ListTile(
            title: new Text("Log out"),
            leading: new Icon(Icons.logout),
          )
        ],
      ),
    );
  }
}
