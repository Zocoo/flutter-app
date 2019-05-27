import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/component/person/change_autograph/change_autograph.dart';
import 'package:flutter_wyz/page/component/person/name/change_name.dart';
import 'package:flutter_wyz/page/component/person/psd/change_password.dart';
import 'package:flutter_wyz/page/login/login.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';

import 'device_list.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  _loginOut() async {
    await LocalStorage().set("userId", "-1");
    await LocalStorage().set("token", "1-1");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => route == null);
  }

  _confirm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('提示'),
          content: SingleChildScrollView(
            child: Text('确定要退出登录吗？'),
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('确定'),
                  onPressed: () {
                    _loginOut();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 2,
                  color: Colors.black12,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (BuildContext context) {
                          return DeviceList();
                        }));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 1, left: 35, right: 15),
                    child: Container(
                      color: Colors.white,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '设备列表',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.black12,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (BuildContext context) {
                      return ChangePassword();
                    }));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 1, left: 35, right: 15),
                    child: Container(
                      color: Colors.white,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '修改密码',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.black12,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (BuildContext context) {
                          return ChangeAutograph();
                        }));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 1, left: 35, right: 15),
                    child: Container(
                      color: Colors.white,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '修改签名',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.black12,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (BuildContext context) {
                      return ChangeName();
                    }));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 1, left: 35, right: 15),
                    child: Container(
                      color: Colors.white,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '修改昵称',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.black12,
                ),
                GestureDetector(
                  onTap: _confirm,
                  child: Padding(
                    padding: EdgeInsets.only(top: 1, left: 35, right: 15),
                    child: Container(
                      color: Colors.white,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '退出登录',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.black12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
