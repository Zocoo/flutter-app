import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/index/index.dart';
import 'package:flutter_wyz/page/pojo/user.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeName extends StatefulWidget {
  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  bool _pwdState = false;
  TextEditingController _pwdcontroller1 = new TextEditingController();
  String _checkStr;
  User user = new User(null, null, null);

  _ChangeNameState() {
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
        _pwdcontroller1.text = user.name;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _changeName() async {
    var namel = _pwdcontroller1.text.length;
    if(namel>8){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('提示'),
            content: SingleChildScrollView(
              child: Text('名称不能超过8个字'),
            ),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('好的'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
      return;
    }else{
      Toast.toast(context, '提交中');
    }
    String token = await LocalStorage().get("token");
    String id = await LocalStorage().get("userId");
    String url = Config().host + "/user?token=" + token;
    String datax = json.encode({'name': _pwdcontroller1.text, 'id': id});
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
        title: new Text('修改基本信息'),
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
                            hintText: '请输入昵称',
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
                        _checkStr = '请输入6-20位密码！';
                      }

                      print(_checkStr);
                      if (_checkStr == null || _checkStr == "") {
                        _changeName();
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
