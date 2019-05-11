import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/index/index.dart';
import 'package:flutter_wyz/page/login/login.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool _phoneState, _pwdState, _codeState = false;
  String _checkStr;
  TextEditingController _pwdcontroller = new TextEditingController();
  TextEditingController _phonecontroller = new TextEditingController();
  TextEditingController _codecontroller = new TextEditingController();
  String _sc = '发送';
  int t = 60;
  Timer _ct;

  void _tgo() {
    setState(() {
      _sc = t.toString() + "秒";
      _ct = Timer.periodic(new Duration(seconds: 1), (timer) {
        setState(() {
          if (t > 0) {
            t--;
            _sc = t.toString() + "秒";
          } else {
            _sc = '发送';
            t = 60;
            _ct.cancel();
            _ct = null;
          }
        });
      });
    });
  }

  @override
  void dispose(){
    _ct?.cancel();
    _ct = null;
    super.dispose();
  }

  void _checkPhone() {
    if (_phonecontroller.text.isNotEmpty &&
        _phonecontroller.text.trim().length == 11) {
      _phoneState = true;
    } else {
      _phoneState = false;
    }
  }

  void _checkPwd() {
    if (_pwdcontroller.text.isNotEmpty &&
        _pwdcontroller.text.trim().length >= 6 &&
        _pwdcontroller.text.trim().length <= 20) {
      _pwdState = true;
    } else {
      _pwdState = false;
    }
  }

  void _checkCode() {
    if (_codecontroller.text.isNotEmpty &&
        _codecontroller.text.trim().length == 4) {
      _codeState = true;
    } else {
      _codeState = false;
    }
  }

  register() async {
    String url = Config().host + "/user/changePasswordCode";
    String datax = json.encode({
      'phone': _phonecontroller.text,
      'password': _pwdcontroller.text,
      'code': _codecontroller.text
    });
    print(datax);
    final http.Response response = await http.post(url, body: datax);
    var data = json.decode(response.body);
    print(data);
    var result = data['code'];
    if (result == 0) {
      Toast.toast(context, '密码已重置！');
      Navigator.pop(context);
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  sendCode() async {
    if (_sc == '发送') {
      String phone = _phonecontroller.text;
      if (phone != null && phone.length == 11) {
        String url = Config().host + "/user/sendCode?type=f&phone=" + phone;
        final http.Response response = await http.get(url);
        var data = json.decode(response.body);
        print(data);
        var result = data['code'];
        if (result == 0) {
          Toast.toast(context, '验证码发送成功！注意查收！');
          _tgo();
        } else {
          Toast.toast(context, data['msg']);
        }
      } else {
        Toast.toast(context, '请输入11位手机号！');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '重置密码',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('重置密码'),
        ),
        body: new ListView(
          children: <Widget>[
            new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 15.0),
                  child: new Stack(
                    alignment: new Alignment(1.0, 1.0),
                    //statck
                    children: <Widget>[
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new Padding(
                                padding:
                                new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                                child: Icon(Icons.phone_iphone)),
                            new Expanded(
                              child: new TextField(
                                controller: _phonecontroller,
                                keyboardType: TextInputType.phone,
                                decoration: new InputDecoration(
                                  hintText: '请输入手机号',
                                ),
                              ),
                            ),
                          ]),
                      new IconButton(
                        icon: new Icon(Icons.clear, color: Colors.black45),
                        onPressed: () {
                          _phonecontroller.clear();
                        },
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 30.0),
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new Padding(
                            padding:
                            new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                            child: Icon(Icons.lock)),
                        new Expanded(
                          child: new TextField(
                            controller: _pwdcontroller,
                            decoration: new InputDecoration(
                              hintText: '请输入密码',
                              suffixIcon: new IconButton(
                                icon: new Icon(Icons.clear,
                                    color: Colors.black45),
                                onPressed: () {
                                  _pwdcontroller.clear();
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
                            padding:
                            new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                            child: Icon(Icons.blur_circular)),
                        new Expanded(
                          child: new TextField(
                            controller: _codecontroller,
                            keyboardType: TextInputType.phone,
                            decoration: new InputDecoration(
                              hintText: '请输入验证码',
                              suffixIcon: new IconButton(
                                icon: new Icon(Icons.clear,
                                    color: Colors.black45),
                                onPressed: () {
                                  _pwdcontroller.clear();
                                },
                              ),
                            ),
                            obscureText: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: MaterialButton(
                            color: Colors.blueAccent,
                            onPressed: sendCode,
                            child: Text(
                              _sc,
                              style: TextStyle(color: Colors.white),
                            ),
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
                          '提交',
                          style: new TextStyle(
                              color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                      onPressed: () {
                        _checkStr = null;
                        _checkPhone();
                        _checkPwd();
                        _checkCode();
                        if (_phoneState && _pwdState && _codeState) {
//                                _checkStr = '页面跳转下期见咯！';
                        } else {
                          if (!_phoneState) {
                            _checkStr = '请输入11位手机号！';
                          } else if (!_pwdState) {
                            _checkStr = '请输入6-10位密码！';
                          } else if (!_codeState) {
                            _checkStr = '请输入4位数验证码！';
                          }
                        }
                        print(_checkStr);
                        if (_checkStr == null || _checkStr == "") {
                          register();
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
      ),
    );
  }
}
