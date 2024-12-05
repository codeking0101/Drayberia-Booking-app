import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RiderListDrawer extends StatefulWidget {
  final Function(int) onSignalRiderSelectIndex;

  RiderListDrawer({required this.onSignalRiderSelectIndex});
  @override
  _RiderListDrawerState createState() => _RiderListDrawerState();
}

class _RiderListDrawerState extends State<RiderListDrawer> {
  List<dynamic> riders = [
    {
      "index": 0,
      "name": "123123123",
      "vehicleType": 0,
    },
    {
      "index": 1,
      "name": "123123123123123123123123123",
      "vehicleType": 1,
    },
    {
      "index": 2,
      "name": "rider3",
      "vehicleType": 2,
    },
    {
      "index": 3,
      "name": "rider4",
      "vehicleType": 0,
    }
  ];
  int _selectedIndex = -1;

  void _getRider() async {
    var box = await Hive.openBox('routeData');
    double departureLatitude = box.get("departureLatitude");
    double departureLongitude = box.get("departureLongitude");
    double destinationLatitude = box.get("destinationLatitude");
    double destinationLongitude = box.get("destinationLongitude");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      elevation: 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 120.0,
            color: const Color.fromARGB(255, 247, 52, 117),
            child: Center(
              child: Text(
                "Riders Around You",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Stack(
            children: [
              Positioned(
                child: Container(
                  color: const Color.fromARGB(255, 247, 52, 117),
                  height: screenHeight - 120,
                  child: ListView.builder(
                    itemCount: riders.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          widget.onSignalRiderSelectIndex(index);
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Container(
                          height: 75.0,
                          decoration: BoxDecoration(
                            color: _selectedIndex == index
                                ? const Color.fromARGB(255, 226, 10, 82)
                                : const Color.fromARGB(255, 247, 52, 117),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white38,
                                width: 2,
                              ),
                              bottom: (riders.length - 1) == index
                                  ? BorderSide(
                                      color: Colors.white38,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedIndex == index
                                      ? Colors.white
                                      : Colors.white,
                                ),
                              ),
                              Container(
                                width: 70.0,
                                child: Text(
                                  "${riders[index]['name']}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedIndex == index
                                        ? Colors.white
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              if (riders[index]['vehicleType'] == 0)
                                Image.asset(
                                  "assets/images/bikeIcon.png",
                                  width: 40.0,
                                ),
                              if (riders[index]['vehicleType'] == 1)
                                Image.asset(
                                  "assets/images/tricycleIcon.png",
                                  width: 40.0,
                                ),
                              if (riders[index]['vehicleType'] == 2)
                                Image.asset(
                                  "assets/images/carIcon.png",
                                  width: 40.0,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
