import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';

class DeviceHJ extends StatefulWidget {
  DeviceHJ({Key key, this.id, this.name, this.cid}) : super(key: key);
  final String id;
  final String name;
  final String cid;

  @override
  _DeviceHJState createState() => _DeviceHJState(id, name, cid);
}

class _DeviceHJState extends State<DeviceHJ> {

  @override
  void dispose(){
    if(null != _ctXl) _ctXl.cancel();
    super.dispose();
  }

  _DeviceHJState(id, name, cid) {
    _id = id;
    _name = name;
    _cid = cid;
    _readTH();
    _initData();
  }

  String _cid;
  String _id;
  String _name = '';
  Timer _ctXl;
  String _wd = "获取中";
  String _sd = "获取中";

  _initData() {
    _ctXlGx();
  }

  _ctXlGx() {
    _ctXl = Timer.periodic(new Duration(milliseconds: 10000), (timer) {
      _readTH();
    });
  }

  _readTH() async {
    String token = await LocalStorage().get("token");
    String url =
        Config().host + "/device/readTH?cid=" + _cid + "&token=" + token;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      double dt = double.parse(data['data']['data']['t'].toString());
      double dh = double.parse(data['data']['data']['h'].toString());
      print(dt);
      print(dh);
      if (dt > -100) {
        _wd = dt.toString();
      }
      if (dh > -100) {
        _sd = dh.toString();
      }
      setState(() {});
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
      body: Container(
        padding: EdgeInsets.only(top: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('温度'),
                Image.asset(
                  'img/wd.png',
                  height: 60,
                  width: 60,
                ),
                Text(_wd + '°C')
              ],
            ),
            Container(
              height: 60,
              width: double.infinity,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('湿度'),
                Image.asset(
                  'img/sd.png',
                  height: 60,
                  width: 60,
                ),
                Text(_sd + "%")
              ],
            ),
          ],
        ),
      ),
    );
  }
}
