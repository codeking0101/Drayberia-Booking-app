import 'package:flutter/material.dart';

import './homePage.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedIndex = -1;
  double _bottomOffset = -210;
  bool _isDown = true;
  bool _isFirst = true;

  List<dynamic> riders = [];
  List<dynamic> ridersInfo = [
    {
      "index": 0,
      "name": "123123123",
      "vehicleType": 0,
      "reviewScore": 4.0,
      "drivingCnt": 5,
    },
    {
      "index": 1,
      "name": "123123123123123123123123123",
      "vehicleType": 1,
      "reviewScore": 4.0,
      "drivingCnt": 100,
    },
    {
      "index": 2,
      "name": "rider3",
      "vehicleType": 2,
      "reviewScore": 3.0,
      "drivingCnt": 100,
    },
    {
      "index": 3,
      "name": "rider4",
      "vehicleType": 0,
      "reviewScore": 2.0,
      "drivingCnt": 100,
    }
  ];

  @override
  Widget build(BuildContext context) {
    if (_isFirst) {
      _isFirst = false;
    }
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 52, 117),
        title: Container(
          child: Stack(
            children: [
              Text(
                "Booking History",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                          ? const Color.fromARGB(255, 153, 145, 148)
                          : (index % 2 == 0
                              ? const Color.fromARGB(255, 223, 221, 221)
                              : const Color.fromARGB(255, 238, 234, 234)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == index
                                ? Colors.white
                                : const Color.fromARGB(255, 58, 51, 51),
                          ),
                        ),
                        Text(
                          "price$index",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == index
                                ? Colors.white
                                : const Color.fromARGB(255, 58, 51, 51),
                          ),
                        ),
                        Text(
                          "distance$index",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == index
                                ? Colors.white
                                : const Color.fromARGB(255, 58, 51, 51),
                          ),
                        ),
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
                height: 300,
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
                        heightFactor: 1.85,
                        child: Text(
                          "No Rider Selected",
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 20.0,
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
                              _bottomOffset = _bottomOffset == 0 ? -210 : 0;
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
                        bottom: 10.0,
                        left: 0,
                        right: 0,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
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
                                    width: screenWidth * 0.4,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  myHomePage()),
                                        );
                                      },
                                      child: Text(
                                        "Select",
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
                                    width: screenWidth * 0.4,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Chat",
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
                      Positioned(
                        top: 70,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                  child: Container(
                                width: 100,
                                child: Image.asset(
                                    "assets/images/driverAvatar.png"),
                              )),
                              Positioned(
                                top: 0,
                                left: 100,
                                child: Container(
                                  width: 100,
                                  child: Text(
                                    "name",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 100,
                                child: Container(
                                  width: 140,
                                  child: Text(
                                    'aaa',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.0,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
