import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/component/chat/chat_home.dart';
import 'package:flutter_wyz/page/pojo/chat.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Timer _ctXl;

  _ctXlGx() async {
    _ctXl = Timer.periodic(new Duration(milliseconds: 5000), (timer) {
      checkNew();
    });
  }

  String _id = null;
  List<Chat> _list = [];

  _ChatListState() {
    _initData();
    _ctXlGx();
  }

  checkNew() async {
    String result = await LocalStorage().get("havaNewMsg");
    if (result == "1") {
      await LocalStorage().set("havaNewMsg", "0");
      _initData();
    }
  }

  _initData() async {
    String token = await LocalStorage().get("token");
    if (_id == null) {
      _id = await LocalStorage().get("userId");
    }
    String url =
        Config().host + "/chat/chatTo?token=" + token + "&userId=" + _id;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      List<Chat> list = [];
      List<dynamic> datas = data['data'];
      if (data['data'] != null) {
        for (int i = 0; i < datas.length; i++) {
          list.add(Chat.fromJson(datas[i]));
        }
        setState(() {
          _list = list;
        });
      }
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  Widget _displayOne(index) {
    String content = _list[index].content;
    if (_list[index].type == 2) {
      content = '图片';
    }
    if (_list[index].type == 3) {
      content = '语音';
    }
    String url = _list[index].userHeadUrl;
    if (_id == _list[index].friendId) {
      url = _list[index].myHeadUrl;
    }
//    if (content.length >17) {
//      content = content.substring(0, 16);
//    }
//    if (content.length > 10) {
//      content = content.substring(0, 9);
//    }
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            new MaterialPageRoute(builder: (BuildContext context) {
          print(_id);
          return ChatHome(
              id: _list[index].friendId == _id
                  ? _list[index].userId
                  : _list[index].friendId,
              name: _list[index].userName);
        })).then((result) {
          _initData();
        });
      },
      child: Container(
        height: 90,
        child: Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Container(
                  width: 66,
                  child: ClipOval(
                    child: Image.network(url == null
                        ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png'
                        : url +
                            "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: Text(
                          _id == _list[index].friendId
                              ? _list[index].myName
                              : _list[index].userName,
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      Container(
                        child: Text(
                          content,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              color: _list[index].type == 2
                                  ? Colors.blue
                                  : Color.fromARGB(255, 100, 100, 100)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
//              Expanded(
//                child:
              Container(
                height: 60,
                width: 70,
                alignment: Alignment(0.8, -0.8),
                child: Text(
                  DateTime.fromMicrosecondsSinceEpoch(
                          _list[index].createAt * 1000 * 1000)
                      .toString()
                      .substring(0, 19),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color.fromARGB(255, 120, 120, 120)),
                ),
              ),
//              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _flush() async {
    _list = [];
    _initData();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return (_list == null || _list.length < 1)
        ? Container(
            child: Center(
              child: Text("暂无数据"),
            ),
          )
        : Container(
            child: RefreshIndicator(
              child: ListView.builder(
                itemCount: _list.length,
                itemBuilder: (context, index) {
                  return _displayOne(index);
                },
              ),
              onRefresh: _flush,
            ),
          );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("---------------------------------------------1111");
    if (null != _ctXl) {
      _ctXl.cancel();
    }
    super.dispose();
  }
}
