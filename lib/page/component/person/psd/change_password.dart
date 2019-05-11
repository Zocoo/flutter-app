import 'package:flutter/material.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _pwdState = false;
  TextEditingController _pwdcontroller1 = new TextEditingController();
  TextEditingController _pwdcontroller2 = new TextEditingController();
  String _checkStr;

  void _checkPwd() {
    if (_pwdcontroller2.text.isNotEmpty &&
        _pwdcontroller2.text.trim().length >= 6 &&
        _pwdcontroller2.text.trim().length <= 20) {
      _pwdState = true;
    } else {
      _pwdState = false;
    }
  }

  _changePassword() async {
    String token = await LocalStorage().get("token");
    String id = await LocalStorage().get("userId");
    String url = Config().host +
        "/user/changePassword?token=" +
        token +
        "&oldPassword=" +
        _pwdcontroller1.text +
        "&newPassword=" +
        _pwdcontroller2.text +
        "&id=" +
        id;
    final http.Response response = await http.get(url);
    var data = json.decode(response.body);
    print(data);
    var result = data['code'];
    if (result == 0) {
      Navigator.pop(context);
      Toast.toast(context, '密码修改成功！');
    } else {
      Toast.toast(context, data['msg']);
    }
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('修改密码'),
      ),
      body: new ListView(
        children: <Widget>[
          new Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.fromLTRB(20.0, 55.0, 20.0, 40.0),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new Padding(
                          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                          child: Icon(Icons.lock)),
                      new Expanded(
                        child: new TextField(
                          controller: _pwdcontroller1,
                          decoration: new InputDecoration(
                            hintText: '请输入旧密码',
                            suffixIcon: new IconButton(
                              icon:
                                  new Icon(Icons.clear, color: Colors.black45),
                              onPressed: () {
                                _pwdcontroller1.clear();
                              },
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ]),
              ),
              new Padding(
                padding: new EdgeInsets.fromLTRB(20.0, 0, 20.0, 40.0),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new Padding(
                          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                          child: Icon(Icons.lock)),
                      new Expanded(
                        child: new TextField(
                          controller: _pwdcontroller2,
                          decoration: new InputDecoration(
                            hintText: '请输入新密码',
                            suffixIcon: new IconButton(
                              icon:
                                  new Icon(Icons.clear, color: Colors.black45),
                              onPressed: () {
                                _pwdcontroller2.clear();
                              },
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ]),
              ),
              new Container(
                width: 340.0,
                child: new Card(
                  color: Colors.blue,
                  elevation: 16.0,
                  child: new FlatButton(
                    child: new Padding(
                      padding: new EdgeInsets.all(10.0),
                      child: new Text(
                        '修改',
                        style:
                            new TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                    onPressed: () {
                      _checkStr = null;
                      ;
                      _checkPwd();
                      if (!_pwdState) {
                        _checkStr = '请输入6-20位密码！';
                      }

                      print(_checkStr);
                      if (_checkStr == null || _checkStr == "") {
                        _changePassword();
                        Toast.toast(context, '提交中');
                      } else {
                        Toast.toast(context, _checkStr);
                      }
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
