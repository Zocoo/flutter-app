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
  void dispose() {
    if (null != _ctXl) _ctXl.cancel();
    super.dispose();
  }

  _DeviceHJState(id, name, cid) {
    _id = id;
    _name = name;
    _cid = cid;
    _readTH();
    _initData();
  }

  List<Map<String, String>> _list = [];
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
    _ctXl = Timer.periodic(new Duration(milliseconds: 5000), (timer) {
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
      Map<String, String> md = new Map();
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
      if (dt > -100 && dh > -100) {
        md['wd'] = dt.toString().replaceAll('.0', '');
        md['sd'] = dh.toString().replaceAll('.0', '');
        String at = DateTime.fromMicrosecondsSinceEpoch(
                DateTime.now().microsecondsSinceEpoch)
            .toString()
            .substring(0, 19);
        at = at.substring(11,at.length);

        md['time'] = at;
      }
      if(_list.length > 7){
        _list.removeAt(0);
      }
      setState(() {
        _list.add(md);
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  Widget _displayOneDevice(index) {
    return Container(
      height: 40,
      child: Card(
        child: Center(
          child: Text('检测时间：' + _list[index]['time'] + "温度：" + _list[index]['wd'] +"°C湿度：" +_list[index]['sd']+"%"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: Text(_name),
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 80,
                          child: Center(
                            child: Text('温度'),
                          ),
                        ),
                        Image.asset(
                          'img/wd.png',
                          height: 60,
                          width: 60,
                        ),
                        Container(
                          width: 80,
                          child: Center(
                            child: Text(_wd.replaceAll('.0', '') + '°C'),
                          ),
                        ),
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
                        Container(
                          width: 80,
                          child: Center(
                            child: Text('湿度'),
                          ),
                        ),
                        Image.asset(
                          'img/sd.png',
                          height: 60,
                          width: 60,
                        ),
                        Container(
                          width: 80,
                          child: Center(
                            child: Text(_sd.replaceAll(".0", '') + "%"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 15),
                child: ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    return _displayOneDevice(index);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
