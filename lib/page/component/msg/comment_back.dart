import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/component/friend/friend_info.dart';
import 'package:flutter_wyz/page/pojo/comment.dart';
import 'package:flutter_wyz/page/pojo/msg.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentBack extends StatefulWidget {
  CommentBack({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _CommentBackState createState() => _CommentBackState(id);
}

class _CommentBackState extends State<CommentBack> {
  _CommentBackState(id) {
    _id = id;
    _initData();
    _initComment();
  }

  bool _databack = false;

  String _id;

  Comment _msg;
  List<Comment> _list = [];

  _commitComment() async {
    String token = await LocalStorage().get("token");
    String userId = await LocalStorage().get("userId");
    String url = Config().host + "/comment?token=" + token;
    String datax = json.encode(
        {'content': _phonecontroller.text, 'userId': userId, "commentId": _id});
    final http.Response response = await http.post(url, body: datax);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      _phonecontroller.text = '';
      setState(() {
        Navigator.pop(context);
        _initComment();
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  TextEditingController _phonecontroller = new TextEditingController();

  _uploadIng() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 250, 250, 250),
          content: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: TextField(
                  maxLines: 6,
                  autofocus: true,
                  decoration: InputDecoration(hintText: '评论'),
                  controller: _phonecontroller,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: MaterialButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    _commitComment();
                  },
                  child: Text(
                    '提交',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              )
            ],
          )),
        );
      },
    );
  }

  Widget _input() {
    return GestureDetector(
      onTap: () {
        _uploadIng();
      },
      child: Container(
        color: Color.fromARGB(255, 222, 222, 222),
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                '评论',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  _initComment() async {
    String token = await LocalStorage().get("token");
    String url = Config().host + "/comment?token=" + token + "&fid=" + _id;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      List<Comment> list = [];
      List<dynamic> datas = data['data'];
      print(datas.length);
      for (int i = 0; i < datas.length; i++) {
        list.add(Comment.fromJson(datas[i]));
      }
      setState(() {
        _list = list;
//        print(_list[0].userName);
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _initData() async {
    String token = await LocalStorage().get("token");
    String url = Config().host + "/comment/info?token=" + token + "&id=" + _id;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _msg = Comment.fromJson(data['data']);
        _databack = true;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  Widget _comments() {
    return Expanded(
      child: Card(
        child: Container(
//        color: Color.fromARGB(255, 44, 99, 137),
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (BuildContext context) {
                    return CommentBack(id: _list[index].id);
                  })).then((result) {
//                                        if (result != null) {
                    _initComment();
//                                        }
                  });
                },
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, new MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return FriendInfo(
                                      id: _list[index].userId.toString());
                                }));
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                height: 50,
                                width: 50,
                                child: ClipOval(
                                  child: Image.network(_list[index]
                                              .userHeadUrl ==
                                          null
                                      ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png'
                                      : _list[index].userHeadUrl +
                                          "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _list[index].userName,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 1, 1, 1)),
                                  ),
                                  Text(
                                    DateTime.fromMicrosecondsSinceEpoch(
                                            _list[index].createAt * 1000 * 1000)
                                        .toString()
                                        .substring(0, 19),
                                    style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 150, 150, 150)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment(0.8, -0.8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        _loveC(_list[index].id);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            height: 28,
                                            width: 28,
                                            child: Image.asset("img/love.png"),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, right: 2),
                                            height: 45,
                                            child: Text(_list[index]
                                                .loveNumber
                                                .toString()),
                                          ),
                                          Container(
                                            width: 15,
                                            height: 30,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          )
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            new MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return CommentBack(
                                              id: _list[index].id);
                                        })).then((result) {
//                                        if (result != null) {
                                          _initComment();
//                                        }
                                        });
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.only(left: 1),
//                                      height: 40,
//                                      width: 40,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            child: Icon(Icons.message),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, right: 2),
                                            height: 45,
                                            child: Text(_list[index]
                                                .commentNumber
                                                .toString()),
                                          ),
                                          Container(
                                            width: 15,
                                            height: 30,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      children: <Widget>[
                      Container(
//                          height: 200,
                        width: double.infinity,
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        child: Text(
                          _list[index].content,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          style: TextStyle(
                            color: Color.fromARGB(
                              255,
                              40,
                              40,
                              40,
                            ),
                            fontSize: 20,
                          ),
                        ),
                      ),
//                      ],
//                    ),
                      Divider(
                        height: 2,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _comment() {
    return _databack
        ? Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) {
                            return FriendInfo(id: _msg.userId.toString());
                          }));
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(70))),
                          height: 70,
                          width: 70,
                          child: ClipOval(
                            child: Image.network(_msg.userHeadUrl == null
                                ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png'
                                : _msg.userHeadUrl +
                                    "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _msg.userName,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 1, 1, 1)),
                            ),
                            Text(
                              DateTime.fromMicrosecondsSinceEpoch(
                                      _msg.createAt * 1000 * 1000)
                                  .toString()
                                  .substring(0, 19),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 150, 150, 150)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment(0.8, -0.8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  _love(_msg.id);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      height: 28,
                                      width: 28,
                                      child: Image.asset("img/love.png"),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 10, right: 2),
                                      height: 45,
                                      child: Text(_msg.loveNumber.toString()),
                                    ),
                                    Container(
                                      width: 15,
                                      height: 30,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.message),
                              Container(
                                padding: EdgeInsets.only(top: 10, right: 15),
                                height: 45,
                                child: Text(_msg.commentNumber.toString()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      children: <Widget>[
                Container(
//                          height: 200,
                  width: double.infinity,
                  padding:
                      EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  child: Text(
                    _msg.content,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 8,
                    style: TextStyle(
                      color: Color.fromARGB(
                        255,
                        40,
                        40,
                        40,
                      ),
                      fontSize: 20,
                    ),
                  ),
                ),
//                      ],
//                    ),
                Divider(
                  height: 2,
                )
              ],
            ),
          )
        : Container();
  }

  _love(String id) async {
    print("id=" + id);
    String token = await LocalStorage().get("token");
    String userId = await LocalStorage().get("userId");
    String url = Config().host +
        "/userLove/love?token=" +
        token +
        "&userId=" +
        userId +
        "&commentId=" +
        id;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      Toast.toast(context, '爱心已收到！');
      setState(() {
        _msg.loveNumber++;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _loveC(String id) async {
    print("id=" + id);
    String token = await LocalStorage().get("token");
    String userId = await LocalStorage().get("userId");
    String url = Config().host +
        "/userLove/love?token=" +
        token +
        "&userId=" +
        userId +
        "&commentId=" +
        id;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      Toast.toast(context, '爱心已收到！');
      setState(() {
        for (int i = 0; i < _list.length; i++) {
          if (_list[i].id == id) {
            _list[i].loveNumber++;
          }
        }
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评论'),
      ),
      body: Column(
        children: <Widget>[
          _comment(),
          _comments(),
          _input(),
        ],
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
