import 'package:DRAYBERYA/screens/riderShowPage.dart';
import 'package:flutter/material.dart';
import '../widgets/drawer.dart';
import '../widgets/searchBar.dart';
import './currentBookingPage.dart';
import 'rideBookingPage.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class myHomePage extends StatefulWidget {
  @override
  _myHomePageState createState() => _myHomePageState();
}

class _myHomePageState extends State<myHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool hasRideBooking = false;
  bool hasActiveBooking = false;
  String nickName = '';

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

    // _fetchHasRideBooking();
  }

  void _setHiveData() async {}

  void _fetchHasRideBooking() async {
    final url = "http://88.222.213.227:5000/api/client/hasActiveBooking";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "nickName": nickName,
        }),
      );
      final result = json.decode(response.body);
      if (result['msg'] == 1) {
        setState(() {
          this.hasRideBooking = true;
        });
      } else if (result['msg'] == 2) {
        setState(() {
          this.hasActiveBooking = true;
        });
      }
    } catch (e) {
      print("Error fetching autocomplete results: $e");
    }
  }

  void _activeBookingOpen() async {
    final url = "http://88.222.213.227:5000/api/client/hasActiveBooking";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "nickName": nickName,
        }),
      );
      final result = json.decode(response.body);
      if (result['msg'] > 0) {
        var box = await Hive.openBox('routeData');
        await box.put('departureLongitude', result['ActiveBooking']['fromLng']);
        await box.put('departureLatitude', result['ActiveBooking']['fromLat']);

        await box.put('destinationLongitude', result['ActiveBooking']['toLng']);
        await box.put('destinationLatitude', result['ActiveBooking']['toLat']);

        await box.put(
            'pickupLocation', result['ActiveBooking']['departureLocation']);
        await box.put('destinationLocation',
            result['ActiveBooking']['destinationLocation']);

        await box.put('priceBike', result['ActiveBooking']['price'].toDouble());
        await box.put(
            'priceTricycle', result['ActiveBooking']['price'].toDouble());
        await box.put('priceCar', result['ActiveBooking']['price'].toDouble());

        await box.put(
            'distance', result['ActiveBooking']['distance'].toDouble());

        await box.put('price', result['ActiveBooking']['price'].toDouble());

        await box.put('paymentMethod', 0);
        await box.put('vehicleType', 0);
        if (result['msg'] == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => currentBookingPage(
                      fromLat: result['ActiveBooking']['fromLat'],
                      fromLng: result['ActiveBooking']['fromLng'],
                      toLat: result['ActiveBooking']['toLat'],
                      toLng: result['ActiveBooking']['toLng'],
                      distance: result['ActiveBooking']['distance'].toDouble(),
                      price: result['ActiveBooking']['price'].toDouble(),
                      riderNickName: '',
                    )),
          );
        }
        if (result['msg'] == 2) {
          print("asdfasdfasdfasdfasdfasdfasdfasdf");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RiderShowPage()),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SecondRoute()),
        );
      }
    } catch (e) {
      print("Error fetching autocomplete results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(197, 255, 252, 222),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color.fromARGB(197, 255, 252, 222),
              floating: true,
              pinned: true,
              snap: true,
              expandedHeight: 180.0,
              collapsedHeight: 180,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 52, 117),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(40.0, 30.0),
                    bottomRight: Radius.elliptical(40.0, 30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // Shadow color
                      blurRadius: 10, // Softness of the shadow
                      spreadRadius: 2, // Spread radius
                      offset: Offset(0, 10), // Offset in x and y directions
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 15,
                      bottom: 10,
                      child: Container(
                        width: screenWidth < 410
                            ? screenWidth * 0.7
                            : screenWidth * 0.75,
                        child:
                            MySearchBar(hintText: "search all our services..."),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        // width: screenWidth * 0.15,
                        child: IconButton(
                          icon: Icon(Icons.send_sharp),
                          iconSize: 30,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          tooltip: 'Increase volume by 5',
                          onPressed: () {},
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.openDrawer();
                          print("Drawer opened");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 100.0, // Set the desired width
                              maxHeight: 100.0, // Set the desired height
                            ),
                            child: Image.asset(
                              'assets/images/appLogo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 110,
                      bottom: screenWidth <= 400 ? 115 : 105,
                      child: Text(
                        "Feel Warm with US",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: Container(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                      return Container(
                        margin: EdgeInsets.only(left: 10.0, top: 20.0),
                        child: Text(
                          "Our Service",
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    case 1:
                      // Horizontal scrolling section
                      return SizedBox(
                        height:
                            200.0, // Set a fixed height for the horizontal ListView
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _activeBookingOpen();
                              },
                              child: Container(
                                width: screenWidth * 3 / 5,
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        child: Image.asset(
                                          'assets/images/homeRideButton.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(24.0),
                                            bottomRight: Radius.circular(24.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.motorcycle,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Ride',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showAlertDialog(context);
                              },
                              child: Container(
                                width: screenWidth * 3 / 5,
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        child: Image.asset(
                                          'assets/images/homeFoodButton.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(24.0),
                                            bottomRight: Radius.circular(24.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.dinner_dining,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Food',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showAlertDialog(context);
                              },
                              child: Container(
                                width: screenWidth * 3 / 5,
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        child: Image.asset(
                                          'assets/images/homeGroceryButton.jfif',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                115, 0, 0, 0),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(24.0),
                                              bottomRight:
                                                  Radius.circular(24.0),
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.local_grocery_store,
                                              color: Colors.white,
                                              size: 25.0,
                                            ),
                                            title: Text(
                                              'Grocery',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    case 2:
                      return Container(
                        margin: EdgeInsets.only(left: 10.0, top: 20.0),
                        child: Text(
                          "Our Promotions",
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    case 3:
                      // Horizontal scrolling section
                      return SizedBox(
                        height:
                            260.0, // Set a fixed height for the horizontal ListView
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                print("service selected");
                              },
                              child: Container(
                                width: 260.0, // Set the width of the container
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/images/todaySpecial1.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.money,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Same Price',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("service selected");
                              },
                              child: Container(
                                width: 260.0, // Set the width of the container
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/images/todaySpecial2.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.holiday_village_sharp,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Holiday Service',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("service selected");
                              },
                              child: Container(
                                width: 260.0, // Set the width of the container
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/images/todaySpecial3.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.attach_money,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Low Price',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    case 4:
                      return Container(
                        margin: EdgeInsets.only(left: 10.0, top: 20.0),
                        child: Text(
                          "Our Customers",
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    case 5:
                      // Horizontal scrolling section
                      return SizedBox(
                        height:
                            260.0, // Set a fixed height for the horizontal ListView
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                print("service selected");
                              },
                              child: Container(
                                width: 200.0, // Set the width of the container
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/images/ourBestRider1.jfif',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.man,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Jerry T.',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("service selected");
                              },
                              child: Container(
                                width: 200.0, // Set the width of the container
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/images/ourBestRider2.jfif',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.man,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Timer K.',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("service selected");
                              },
                              child: Container(
                                width: 200.0, // Set the width of the container
                                margin: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/images/ourBestRider3.jfif',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.man,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          title: Text(
                                            'Senny L.',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                  }
                  return null;
                },
                childCount: 50,
              ),
            ),
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}

showAlertDialog(BuildContext context) {
  // Create button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Thanks for your use."),
    content: Text("This feature will be added in soon."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
