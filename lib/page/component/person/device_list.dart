import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/pojo/device.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';

import 'device_info.dart';

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  List<Device> _list = [];

  _DeviceListState() {
    _initData();
  }

  _initData() async {
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
        list.add(Device.fromJson(datas[i]));
      }
      setState(() {
        _list = list;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  Widget _displayOneDevice(index) {
    List<String> _c = _list[index].remark.split("&&");
    print(_c);
    String url = _c[2];
    String status = _c[0];
    String name = _c[1];
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            new MaterialPageRoute(builder: (BuildContext context) {
          return DeviceInfo(
              id: _list[index].id, name: name, cid: _list[index].sn);
        })).then((result) {
          _initData();
        });
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(5),
          height: 80,
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                      imageUrl:
                          url + "?x-oss-process=image/resize,m_lfit,h_60,w_60"),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(_list[index].sn),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 15),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主页'),
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {
          Navigator.push(context,
                  new MaterialPageRoute(builder: (BuildContext context) {
//                return MsgAdd();
          }))
              .then((result) {
            _initData();
          });
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getBody() {
    return (_list == null || _list.length < 1)
        ? Container(
            child: Center(
              child: Text('暂无设备'),
            ),
          )
        : Container(
            child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, index) {
                return _displayOneDevice(index);
              },
            ),
          );
  }
}
