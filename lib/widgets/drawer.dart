import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 100.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Jenny K."),
            accountEmail: Text("k.Jenny@gmail.com"),
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
            title: new Text("News"),
            leading: new Icon(Icons.newspaper),
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
            title: new Text("History"),
            leading: new Icon(Icons.history),
          ),
          ListTile(
            title: new Text("FAQ"),
            leading: new Icon(Icons.question_answer),
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
