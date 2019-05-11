import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/component/friend/friend_info.dart';
import 'package:flutter_wyz/page/pojo/user.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyFriend extends StatefulWidget {
  MyFriend({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _MyFriendState createState() => _MyFriendState(id);
}

class _MyFriendState extends State<MyFriend> {
  List<User> _list = [];

  String _id = "";

  _MyFriendState(id) {
    _init(id);
  }

  _init(id) async {
    if (id == "0" || id == null)
      _id = await LocalStorage().get("userId");
    else
      _id = id;
    _initData();
  }

  _initData() async {
    String token = await LocalStorage().get("token");
    String url =
        Config().host + "/user/queryMyFriend?id=" + _id + "&token=" + token;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
//    print(data);
    var result = data['code'];
    if (result == 0) {
      List<User> list = new List();
      List<dynamic> datas = data['data'];
      for (int i = 0; i < datas.length; i++) {
        list.add(User.fromJson(datas[i]));
      }
      setState(() {
        _list = list;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, index) {
          return _displayOneUser(index);
        },
      ),
    );
  }

  Widget _displayOneUser(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            new MaterialPageRoute(builder: (BuildContext context) {
          return FriendInfo(id: _list[index].id);
        })).then((result) {
          _initData();
        });
      },
      child: Container(
        padding: EdgeInsets.only(top: 2),
        child: Card(
          child: Container(
            height: 80,
            padding: EdgeInsets.only(left: 15),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 1),
                  child: Container(
                    child: Container(
                      height: 60,
                      width: 60,
                      child: ClipOval(
                        child: Image.network(_list[index].headUrl == null
                            ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png'
                            : _list[index].headUrl +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Container(
                    child: Text(_list[index].name),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
