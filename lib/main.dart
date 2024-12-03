import 'package:flutter/material.dart';
import './screens/homePage.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  runApp(MaterialApp(
    home: myHomePage(),
  ));
}
