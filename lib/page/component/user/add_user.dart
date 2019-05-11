import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/component/user/qrcode.dart';
import 'package:flutter_wyz/page/component/user/user_info.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MaterialButton(
            color: Colors.blue,
            onPressed: () {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (BuildContext context) {
                return UserInfo();
              }));
            },
            child: Text(
              "添加人员",
              style: TextStyle(color: Colors.white),
            ),
          ),
          MaterialButton(
            color: Colors.blue,
            onPressed: () {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (BuildContext context) {
                    return Qrcode();
                  }));
            },
            child: Text(
              "扫码添加",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
