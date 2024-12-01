import 'package:flutter/material.dart';
import '../widgets/drawer.dart';
import '../widgets/searchBar.dart';
import 'rideBookingPage.dart';

class myHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(197, 255, 252, 222),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color.fromARGB(197, 255, 252, 222),
              title: Text(
                "Home",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              floating: true,
              pinned: true,
              snap: true,
              expandedHeight: 180.0,
              collapsedHeight: 180,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/homeBanner.jpg"),
                    fit: BoxFit.cover,
                  ),
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
                        width: screenWidth * 0.8,
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
                      left: 15,
                      bottom: 80,
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
              iconTheme: IconThemeData(
                size: 25,
                color: Colors.white, // Set the color of the drawer icon
              ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SecondRoute()),
                                );
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

  // Create AlertDialog
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
