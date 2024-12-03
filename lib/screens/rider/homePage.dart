import 'package:flutter/material.dart';
import '../../widgets/drawer.dart';

class RiderHomePage extends StatefulWidget {
  @override
  _RiderHomePageState createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  double _bottomOffset = 0;
  bool _isDown = false;
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 52, 117),
        title: Container(
          child: Text(
            "Pending Bookings.",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          weight: 30.0,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(197, 255, 252, 222),
        ),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print("Taped on $index");
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    height: 75.0,
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? const Color.fromARGB(255, 236, 97, 144)
                          : (index % 2 == 0
                              ? const Color.fromARGB(255, 223, 221, 221)
                              : const Color.fromARGB(255, 238, 234, 234)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("name$index"),
                        Text("price$index"),
                        Text("distance$index"),
                      ],
                    ),
                  ),
                );
              },
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _bottomOffset,
              left: 0,
              right: 0,
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Stack(
                    children: [
                      Center(
                        heightFactor: 1.5,
                        child: Text(
                          "About Customer",
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _isDown = !_isDown;
                              _bottomOffset = _bottomOffset == 0 ? -330 : 0;
                            });
                          },
                          icon: Icon(_isDown
                              ? Icons.arrow_drop_up_rounded
                              : Icons.arrow_drop_down_circle),
                          iconSize: 40.0,
                          color: Colors.pink,
                        ),
                      ),
                      Positioned(
                        top: 70.0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 300.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Table(
                                border: TableBorder.all(),
                                children: [
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Name')),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('client name')),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('From')),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'departure',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('To')),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('destination')),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Price')),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('price')),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Far from You')),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('distance')),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('mobile')),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('9409356548')),
                                  ]),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                    ),
                                    width: screenWidth / 4,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                    ),
                                    width: screenWidth / 4,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Decline",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                    ),
                                    width: screenWidth / 3,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Show on Map",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}
