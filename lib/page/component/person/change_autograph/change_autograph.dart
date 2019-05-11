import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/index/index.dart';
import 'package:flutter_wyz/page/pojo/user.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeAutograph extends StatefulWidget {
  @override
  _ChangeAutographState createState() => _ChangeAutographState();
}

class _ChangeAutographState extends State<ChangeAutograph> {
  bool _pwdState = false;
  TextEditingController _pwdcontroller1 = new TextEditingController();
  String _checkStr;
  User user = new User(null, null, null);

  _ChangeAutographState() {
    _initData();
  }

  void _checkPwd() {
    if (_pwdcontroller1.text.isNotEmpty &&
        _pwdcontroller1.text.trim().length >= 1) {
      _pwdState = true;
    } else {
      _pwdState = false;
    }
  }

  _initData() async {
    String id = await LocalStorage().get("userId");
    String token = await LocalStorage().get("token");
    String url = Config().host + "/user?id=" + id + "&token=" + token;
    final http.Response response = await http.get(url);
    Map data = json.decode(response.body);
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        user = new User.fromJson(data['data']);
        _pwdcontroller1.text = user.autograph;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _changeName() async {
    String token = await LocalStorage().get("token");
    String id = await LocalStorage().get("userId");
    String url = Config().host + "/user?token=" + token;
    String datax = json.encode({'autograph': _pwdcontroller1.text, 'id': id});
    print(datax);
    final http.Response response = await http.put(url, body: datax);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      await LocalStorage().set("labelId", '3');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Index()),
          (route) => route == null);
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('修改签名'),
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
                          child: Icon(Icons.calendar_view_day)),
                      new Expanded(
                        child: new TextField(
                          controller: _pwdcontroller1,
                          decoration: new InputDecoration(
                            hintText: '请输入签名',
                            suffixIcon: new IconButton(
                              icon:
                                  new Icon(Icons.clear, color: Colors.black45),
                              onPressed: () {
                                _pwdcontroller1.clear();
                              },
                            ),
                          ),
                          obscureText: false,
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
                        _checkStr = '不能为空！';
                      }

                      print(_checkStr);
                      if (_checkStr == null || _checkStr == "") {
                        _changeName();
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
