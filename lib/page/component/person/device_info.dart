import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';

class DeviceInfo extends StatefulWidget {
  DeviceInfo({Key key, this.id, this.name, this.cid}) : super(key: key);
  final String id;
  final String name;
  final String cid;

  @override
  _DeviceInfoState createState() => _DeviceInfoState(id, name, cid);
}

class _DeviceInfoState extends State<DeviceInfo> {
  _DeviceInfoState(id, name, cid) {
    _id = id;
    _name = name;
    _cid = cid;
    _initData();
  }

  String _cid;
  String _id;
  String _name = '';
  int _over = 0;
  String _power = '';

  _initData() async {
    String token = await LocalStorage().get("token");
    String url = Config().host +
        "/device/readPower?cid=" +
        _cid +
        "&pin=4" +
        "&token=" +
        token;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _power = data['data'];
        _over = 1;
      });
    } else {
      setState(() {
        _power = '未知';
        _over = 1;
      });
    }
  }

  _setPower() async {
    String token = await LocalStorage().get("token");
    int f = 0;
    if(_power =='OFF')
      f = 1;
    String url = Config().host +
        "/device/setPower?cid=" +
        _cid +
        "&pin=4" +
        "&token=" +
        token+"&fun="+f.toString();
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _initData();
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(_name),
      ),
      body: _over == 0
          ? Container(
              child: Container(
                child: Center(
                  child: Image.asset('img/ld.gif'),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 30),
                    height: 300,
                    child: Image.asset(_power == 'ON'
                        ? 'img/on.png'
                        : _power == 'OFF' ? 'img/off.png' : 'img/lx.png'),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    child: IconButton(
                        iconSize: 50,
                        icon: Icon(Icons.settings_power),
                        onPressed: () {
                          _setPower();
                        }),
                  )
                ],
              ),
            ),
    );
  }
}
