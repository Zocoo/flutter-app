import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/component/list/user_list.dart';
import 'package:flutter_wyz/page/component/msg/msg_add.dart';
import 'package:flutter_wyz/page/component/msg/msg_home.dart';
import 'package:flutter_wyz/page/component/user/add_user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主页'),
      ),
      body: MsgHome(),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (BuildContext context) {
            return MsgAdd();
          })).then((result) {
            if (result == 'flush') {

            }
          });
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.add),
      ),
//        ),
//      body: Column(
//        children: <Widget>[
//          AddUser(),
//          UserList(),
//        ],
//      ),
    );
  }
}
