import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/index/index.dart';
import 'package:flutter_wyz/page/login/forget_password.dart';
import 'package:flutter_wyz/page/login/register.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TapGestureRecognizer recognizer = TapGestureRecognizer();
  final TapGestureRecognizer recognizer1 = TapGestureRecognizer();
  bool _checkLogin = true;
  bool _isLogin = false;
  bool _phoneState, _pwdState = false;
  String _checkStr;
  TextEditingController _pwdcontroller = new TextEditingController();
  TextEditingController _phonecontroller = new TextEditingController();

  void initState() {
    super.initState();
    recognizer1.onTap = () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ForgetPassword()),
      );
    };
    recognizer.onTap = () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => Register()),
      );
    };
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

  _LoginState() {
    _checkLoginStatus();
    _loadCachePhone();
  }

  _login() async {
    String url = Config().host + "/user/login";
    String datax = json.encode(
        {'phone': _phonecontroller.text, 'password': _pwdcontroller.text});
    print(datax);
    final http.Response response = await http.post(url, body: datax);
    var data = json.decode(response.body);
    print(data['msg']);
    var result = data['code'];
    if (result == 0) {
      await LocalStorage().set("token", data['data']['token']);
      await LocalStorage().set("userId", data['data']['id'].toString());
      await LocalStorage().set("phoneLogin", _phonecontroller.text);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Index()),
              (route) => route == null);
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _loadCachePhone() async {
    String phone = await LocalStorage().get("phoneLogin");
    if (phone != null && phone.length == 11) {
      setState(() {
        _phonecontroller.text = phone;
      });
    }
  }

  _checkLoginStatus() async {
    String token = await LocalStorage().get("token");
    print(token);
    if (token == null || token == "") {
      setState(() {
        _checkLogin = false;
      });
    } else {
      _checkToken(token);
    }
  }

  _checkToken(String token) async {
    String url = Config().host + "/user/flushToken?token=" + token;
    final http.Response response = await http.get(url);
    var data = json.decode(response.body);
    var result = data['code'];
    if (result == 0) {
      await LocalStorage().set("token", data['data']['token']);
      await LocalStorage().set("userId", data['data']['id']);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Index()),
              (route) => route == null);
    } else {
      setState(() {
        _checkLogin = false;
      });
    }
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return _checkLogin
        ? Scaffold(
            backgroundColor: Color.fromARGB(255, 54, 195, 229),
            body: Center(
              child: Container(
                height: 300,
                width: 300,
                child: Image.asset("img/loading.gif"),
              ),
            ),
          )
        : new MaterialApp(
            title: '登录',
            home: new Scaffold(
              appBar: new AppBar(
                title: new Text('登录'),
              ),
              body: new ListView(
                children: <Widget>[
                  new Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding:
                            new EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 15.0),
                        child: new Stack(
                          alignment: new Alignment(1.0, 1.0),
                          //statck
                          children: <Widget>[
                            new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  new Padding(
                                      padding: new EdgeInsets.fromLTRB(
                                          0.0, 0.0, 5.0, 0.0),
                                      child: Icon(Icons.phone_iphone)),
                                  new Expanded(
                                    child: new TextField(
                                      controller: _phonecontroller,
                                      keyboardType: TextInputType.phone,
                                      decoration: new InputDecoration(
                                        hintText: '请输入用户名',
                                      ),
                                    ),
                                  ),
                                ]),
                            new IconButton(
                              icon:
                                  new Icon(Icons.clear, color: Colors.black45),
                              onPressed: () {
                                _phonecontroller.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding:
                            new EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 40.0),
                        child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              new Padding(
                                  padding: new EdgeInsets.fromLTRB(
                                      0.0, 0.0, 5.0, 0.0),
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
                      new Container(
                        width: 340.0,
                        child: new Card(
                          color: Colors.blue,
                          elevation: 16.0,
                          child: new FlatButton(
                            child: new Padding(
                              padding: new EdgeInsets.all(10.0),
                              child: new Text(
                                '登录',
                                style: new TextStyle(
                                    color: Colors.white, fontSize: 16.0),
                              ),
                            ),
                            onPressed: () {
                              _checkStr = null;
                              _checkPhone();
                              _checkPwd();
                              if (_phoneState && _pwdState) {
//                                _checkStr = '页面跳转下期见咯！';
                              } else {
                                if (!_phoneState) {
                                  _checkStr = '请输入11位手机号！';
                                } else if (!_pwdState) {
                                  _checkStr = '请输入6-20位密码！';
                                }
                              }
//                              print(_checkStr);
                              if (_checkStr == null || _checkStr == "") {
                                _login();
                                Toast.toast(context, '登录中');
                              } else {
                                Toast tt = new Toast();
                                Toast.toast(this.context, _checkStr);
                              }
                            },
                          ),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.all(30),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                  text: '忘记密码',
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.blue),
                                  recognizer: recognizer1),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: '立即注册',
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.blue),
                                  recognizer: recognizer),
                            ),
                          ],
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
