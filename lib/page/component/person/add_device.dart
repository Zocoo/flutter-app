import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/pojo/device.dart';


class AddDevice extends StatefulWidget {
  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  _AddDeviceState() {
    _ctXlGx();
  }

  int _cg = 0;
  Timer _ctXl;
  Timer _ctX2;
  int _cd = 0;
  String _tishi1 = "正在同步数据，请确认手机能上网！";
  String _cid = 'no';
  int _cdd = 0;
  String _tishi = '请先连接设备，打开手机WiFi设置，找到以SW开头的WIFI，并连接，密码为12344321';
  TextEditingController _pwdcontroller1 = new TextEditingController();
  TextEditingController _pwdcontroller2 = new TextEditingController();

  _ctXlGx() async {
    _ctXl = Timer.periodic(new Duration(milliseconds: 3000), (timer) {
      if (_cdd == 0) {
        _checkDevice();
      }
    });
  }

  _ctXlGx1() async {
    _ctX2 = Timer.periodic(new Duration(milliseconds: 3000), (timer) {
      if (_cdd == 1) {
        if (_cg == 0)
          _initData();
        else {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    if (_ctXl != null) _ctXl.cancel();
    if (_ctX2 != null) _ctX2.cancel();
    super.dispose();
  }

  _initData() async {
    try {
      String id = await LocalStorage().get("userId");
      String token = await LocalStorage().get("token");
      String url = Config().host +
          "/device/queryByUserId?userId=" +
          id +
          "&token=" +
          token;
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      Map data = json.decode(utf8decoder.convert(response.bodyBytes));
      print(data);
      var result = data['code'];
      if (result == 0) {
        List<Device> list = [];
        List<dynamic> datas = data['data'];
        for (int i = 0; i < datas.length; i++) {
          Device d = Device.fromJson(datas[i]);
          if (d.sn == _cid) {
            setState(() {
              _tishi1 = '绑定成功，即将退出！';
              _cg = 1;
            });
          }
        }
      } else {
        Toast.toast(context, data['msg']);
      }
    } catch (e) {
      print("未能连接上外网");
    }
  }

  _setWifi() async {
    try {
      if (_pwdcontroller1.text == null || _pwdcontroller1.text.length < 1) {
        Toast.toast(context, '请先填写wifi名称');
        return;
      }
      if (_pwdcontroller2.text == null || _pwdcontroller2.text.length < 8) {
        Toast.toast(context, '请先填写8位以上密码');
        return;
      }
      String url = 'http://192.168.4.1:8079/setWifi?ssid=' +
          _pwdcontroller1.text +
          "&pwd=" +
          _pwdcontroller2.text +
          "OVERPWDWYZ";
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      String data = utf8decoder.convert(response.bodyBytes);
      print(data);
      if (null != data) {
        setState(() {
          _cd = 1;
          if (data != '5') {
            _tishi = '设备连接成功！请输入wifi名称（不支持中文名称wifi），并且输入wifi对应的密码！最后提交！';
          } else {
            _tishi = '设备已经连接上wifi！正在同步数据到服务器！！';
          }
        });
      }
    } catch (e) {
      setState(() {
        _cd = 0;
        _tishi = '请先连接设备，打开手机WiFi设置，找到以SW开头的WIFI，并连接，密码为12344321';
      });
      print('conn error');
    }
  }

  _checkDevice() async {
    try {
      String url = 'http://192.168.4.1:8079/getWifiStatus';
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      String data = utf8decoder.convert(response.bodyBytes);
      print(data);
      if (null != data) {
        setState(() {
          _cd = 1;
          if (data != '5') {
            _tishi = '设备连接成功！请输入wifi名称（不支持中文名称wifi），并且输入wifi对应的密码！最后提交！';
          } else {
            _tishi = '设备已经连接上wifi！正在同步数据到服务器！！';
            _getCid();
          }
        });
      }
    } catch (e) {
      setState(() {
        _cd = 0;
        _tishi = '请先连接设备，打开手机WiFi设置，找到以SW开头的WIFI，并连接，密码为12344321';
      });
      print('conn error');
    }
  }

  _getCid() async {
    try {
      String url = 'http://192.168.4.1:8079/getcid';
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      String data = utf8decoder.convert(response.bodyBytes);
      print(data);
      if (null != data) {
        _cid = data;
        _bindUserId();
      }
    } catch (e) {
      setState(() {
        _cd = 0;
        _tishi = '请先连接设备，打开手机WiFi设置，找到以SW开头的WIFI，并连接，密码为12344321';
      });
      print('conn error');
    }
  }

  _over() async {
    try {
      String url = 'http://192.168.4.1:8079/overconfig';
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      String data = utf8decoder.convert(response.bodyBytes);
      print(data);
      if (null != data) {
        setState(() {
          _cdd = 1;
          _ctXlGx1();
        });
      }
    } catch (e) {
      setState(() {
        _cd = 0;
        _tishi = '请先连接设备，打开手机WiFi设置，找到以SW开头的WIFI，并连接，密码为12344321';
      });
      print('conn error');
    }
  }

  _bindUserId() async {
    String id = await LocalStorage().get("userId");
    try {
      String url = 'http://192.168.4.1:8079/setUserId?userId=' + id + "&tmp=1";
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      String data = utf8decoder.convert(response.bodyBytes);
      print(data);
      if (null != data) {
        if (data == id) {
          _over();
        } else {
          setState(() {
            _cd = 0;
            _tishi = '请先连接设备，打开手机WiFi设置，找到以SW开头的WIFI，并连接，密码为12344321';
          });
        }
      }
    } catch (e) {
      setState(() {
        _cd = 0;
        _tishi = '请先连接设备，打开手机WiFi设置，找到以SW开头的WIFI，并连接，密码为12344321';
      });
      print('conn error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加设备'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: _cdd == 1
            ? Center(
                child: Text(_tishi1),
              )
            : Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60,
                      width: double.infinity,
                    ),
                    Text(_tishi),
                    _cd == 0
                        ? Container()
                        : Column(
                            children: <Widget>[
                              Container(
                                height: 10,
                                width: double.infinity,
                              ),
                              new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    new Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            0.0, 0.0, 5.0, 0.0),
                                        child: Icon(Icons.wifi)),
                                    new Expanded(
                                      child: new TextField(
                                        controller: _pwdcontroller1,
                                        decoration: new InputDecoration(
                                          hintText: '请输入wifi名称',
                                          suffixIcon: new IconButton(
                                            icon: new Icon(Icons.clear,
                                                color: Colors.black45),
                                            onPressed: () {
                                              _pwdcontroller1.clear();
                                            },
                                          ),
                                        ),
                                        obscureText: false,
                                      ),
                                    ),
                                  ]),
                              Container(
                                height: 10,
                                width: double.infinity,
                              ),
                              new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    new Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            0.0, 0.0, 5.0, 0.0),
                                        child: Icon(Icons.lock)),
                                    new Expanded(
                                      child: new TextField(
                                        controller: _pwdcontroller2,
                                        decoration: new InputDecoration(
                                          hintText: '请输入wifi密码',
                                          suffixIcon: new IconButton(
                                            icon: new Icon(Icons.clear,
                                                color: Colors.black45),
                                            onPressed: () {
                                              _pwdcontroller2.clear();
                                            },
                                          ),
                                        ),
                                        obscureText: false,
                                      ),
                                    ),
                                  ]),
                              Container(
                                height: 10,
                                width: double.infinity,
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
                                            color: Colors.white,
                                            fontSize: 16.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      _setWifi();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                  ],
                ),
              ),
      ),
    );
  }
}
