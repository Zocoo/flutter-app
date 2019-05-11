import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/component/chat/chat_home.dart';
import 'package:flutter_wyz/page/component/friend/friend_all.dart';
import 'package:flutter_wyz/page/component/msg/msg_info.dart';
import 'package:flutter_wyz/page/pojo/msg.dart';
import 'package:flutter_wyz/page/pojo/user.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FriendInfo extends StatefulWidget {
  FriendInfo({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _FriendInfoState createState() => _FriendInfoState(id);
}

class _FriendInfoState extends State<FriendInfo> {
  _FriendInfoState(id) {
    _userId = id;
    _initDataInfo();
    _initData();
    _initConn();
  }

  List<double> matrix = [
    0.5,
    0,
    0,
    0,
    0,
    0,
    0.5,
    0,
    0,
    0,
    0,
    0,
    0.5,
    0,
    0,
    0,
    0,
    1,
    0.9,
    0
  ];
  String _userId = "无";
  User _user = null;
  bool _loading = false;
  String _care = "un";
  String _friend = "";
  bool _loadingMsg = false;
  int _start = 0;
  int _length = 10;
  List<Msg> _list = [];
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  bool _hasMore = true;
  bool _ctj = true;

  _initConn() async {
    String userId = await LocalStorage().get("userId");
    if (userId == _userId) {
      return;
    }
    String token = await LocalStorage().get("token");
    String url = Config().host +
        "/userFriend/conn?friendId=" +
        _userId +
        "&token=" +
        token +
        "&userId=" +
        userId;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      if (data['data']['gz'] == 'no') {
        setState(() {
          _care = "no";
        });
      } else if (data['data']['bgz'] == 'yes') {
        setState(() {
          _care = "xh";
        });
      } else {
        setState(() {
          _care = "yes";
        });
      }
      setState(() {
        _friend = "关注" +
            data['data']['gzrs'].toString() +
            "|被关注" +
            data['data']['bgzrs'].toString();
      });
      _ctj = true;
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _initData() async {
    String token = await LocalStorage().get("token");
    String url = Config().host +
        "/msg/queryAll?start=" +
        _start.toString() +
        "&length=" +
        _length.toString() +
        "&token=" +
        token +
        "&userId=" +
        _userId;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      List<Msg> list = _list;
      List<dynamic> datas = data['data'];
      if (datas.length != _length) {
        _hasMore = false;
      }
      for (int i = 0; i < datas.length; i++) {
        list.add(Msg.fromJson(datas[i]));
      }
      setState(() {
        _list = list;
        isPerformingRequest = false;
        _loadingMsg = true;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _initDataInfo() async {
    String token = await LocalStorage().get("token");
    String url = Config().host + "/user?id=" + _userId + "&token=" + token;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _user = new User.fromJson(data['data']);
        _loading = true;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _uf() async {
    if (_ctj) {
      _ctj = false;
      String userId = await LocalStorage().get("userId");
      if (userId == _userId) {
        return;
      }
      String token = await LocalStorage().get("token");
      String url = Config().host +
          "/userFriend/uf?friendId=" +
          _userId +
          "&token=" +
          token +
          "&userId=" +
          userId;
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      Map data = json.decode(utf8decoder.convert(response.bodyBytes));
      print(data);
      var result = data['code'];
      if (result == 0) {
        _initConn();
      } else {
        Toast.toast(context, data['msg']);
      }
    } else {
      Toast.toast(context, '处理中...');
    }
  }

  Widget _info() {
    return _loading
        ? Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  colorFilter: ColorFilter.matrix(matrix),
                  image: _user.backImg == null
                      ? AssetImage("img/pp.png")
                      : NetworkImage(_user.backImg +
                          "?x-oss-process=image/resize,m_lfit,h_1000,w_1000"),
                  fit: BoxFit.cover),
            ),
            height: 240,
            child: Column(
              children: <Widget>[
                Container(
//                  color: Colors.red,
                  height: 150,
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 20, left: 20),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Color.fromARGB(255, 250, 250, 250),
                                      content: Container(
                                        child: Image.network(_user.headUrl),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(80))),
                                height: 80,
                                width: 80,
                                child: ClipOval(
                                  child: Image.network(_user.headUrl == null
                                      ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png'
                                      : _user.headUrl),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                _user.name,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, new MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return FriendAll(id: _userId);
                                }));
                              },
                              child: Container(
                                child: Text(
                                  _friend,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 200, 200, 200),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            _care == 'un'
                                ? Container()
                                : _care == 'no'
                                    ? Container(
                                        padding: EdgeInsets.only(right: 2),
                                        child: MaterialButton(
                                          onPressed: () {
                                            _uf();
                                          },
                                          height: 30,
                                          minWidth: 40,
                                          color: Colors.deepOrange,
                                          textColor: Color.fromARGB(
                                              255, 255, 255, 255),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.add,
                                                size: 14,
                                              ),
                                              Text(
                                                '关注',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : _care == "yes"
                                        ? Container(
                                            padding: EdgeInsets.only(right: 20),
                                            child: MaterialButton(
                                              onPressed: () {
                                                _uf();
                                              },
                                              height: 30,
                                              minWidth: 40,
                                              color: Color.fromARGB(
                                                  255, 240, 240, 240),
                                              textColor: Color.fromARGB(
                                                  255, 30, 30, 30),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    '取消关注',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.only(right: 20),
                                            child: MaterialButton(
                                              onPressed: () {
                                                _uf();
                                              },
                                              height: 30,
                                              minWidth: 40,
                                              color: Color.fromARGB(
                                                  255, 240, 240, 240),
                                              textColor: Color.fromARGB(
                                                  255, 30, 30, 30),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    '已相互关注',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                            _care == 'un'
                                ? Container()
                                : Container(
                                    child: MaterialButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            new MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return ChatHome(
                                              id: _userId, name: _user.name);
                                        }));
                                      },
//                                color: Colors.red,
                                      minWidth: 30,
                                      child: Icon(
                                        Icons.chat,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_user.autograph != null && _user.autograph.length > 0)
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Color.fromARGB(255, 250, 250, 250),
                              content: Container(
                                child: Text(_user.autograph),
                              ),
                            );
                          },
                        );
                    },
                    child: Container(
//                    color: Colors.red,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Text(
                            _user.autograph == null ? '未签名' : _user.autograph,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              height: 1.3,
                              color: Colors.white,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic,
                              decorationColor: Colors.deepOrange,
                              wordSpacing: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget _msg() {
    return _loadingMsg
        ? _list.length > -1
            ? Expanded(
                child: RefreshIndicator(
                  child: ListView.builder(
                    itemCount: _list.length + 2,
                    itemBuilder: (context, index) {
                      index = index - 1;
                      if (index == -1) {
                        return _info();
                      } else if (index == 0 && _list.length == 0) {
                        return Container(
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.only(top: 100),
                              child: Text(
                                '该用户未发表过任何动态！',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 100, 100, 100)),
                              ),
                            ),
                          ),
                        );
                      } else if (_list.length == index) {
                        print("xxxxxxxxxxxx");
                        return _buildProgressIndicator();
                      } else {
                        return _displayOneMsg(index);
                      }
                    },
                    controller: _scrollController,
                  ),
                  onRefresh: _flush,
                ),
              )
            : Expanded(
                child: Container(
                  child: Center(
                    child: Container(
                      child: Text(
                        '该用户未发表过任何动态！',
                        style: TextStyle(
                            color: Color.fromARGB(255, 100, 100, 100)),
                      ),
                    ),
                  ),
                ),
              )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("用户信息"),
        ),
        body: Column(
          children: <Widget>[
            _msg(),
          ],
        ));
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<Null> _flush() async {
    _list = [];
    _start = 0;
    _initData();
    return;
  }

  Widget _displayOneMsg(index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            new MaterialPageRoute(builder: (BuildContext context) {
          return MsgInfo(id: _list[index].id);
        })).then((result) {
          if (result != null) {
            _initData();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.only(top: 2),
        child: Card(
          child: Container(
            padding: EdgeInsets.only(left: 15),
            child: Column(
              children: <Widget>[
                _title(index),
                _content(index),
                _pic(index),
                _comment(index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMore) {
          setState(() => isPerformingRequest = true);
          _start = _start + _length;
          _initData();
        } else {
          Toast.toast(context, '已没有更多数据！');
        }
      }
    });
  }

  Widget _title(index) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                new MaterialPageRoute(builder: (BuildContext context) {
              return FriendInfo(id: _list[index].userId.toString());
            })).then((result) {
              if (result != null) {
                _initData();
              }
            });
          },
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.all(Radius.circular(70))),
            height: 70,
            width: 70,
            child: ClipOval(
              child: Image.network(_list[index].userHeadUrl == null
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
                    fontSize: 18, color: Color.fromARGB(255, 1, 1, 1)),
              ),
              Text(
                _list[index].autograph,
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 150, 150, 150)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 60,
            alignment: Alignment(0.8, -0.8),
            child: Text(DateTime.fromMicrosecondsSinceEpoch(
                    _list[index].createAt * 1000 * 1000)
                .toString()
                .substring(0, 19)),
          ),
        )
      ],
    );
  }

  Widget _content(index) {
    return (_list[index].content != null && _list[index].content.length > 0)
        ? LimitedBox(
            maxHeight: 200,
            child: Container(
              width: double.infinity,
//            height: 100,
              padding:
                  EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
              child: SingleChildScrollView(
                child: Text(
                  _list[index].content,
                  softWrap: true,
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
            ),
          )
        : Container(
            height: 1,
          );
  }

  Widget _pic(index) {
    if (_list[index].pics == null ||
        (_list[index].pics.length == 1 &&
            (_list[index].pics[0] == null || _list[index].pics[0] == ""))) {
      return Container();
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          height: 210,
          width: double.infinity,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _list[index].pics.length > 0
                  ? Container(
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[0] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 1
                  ? Container(
                      padding: EdgeInsets.only(left: 2),
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[1] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 2
                  ? Container(
                      padding: EdgeInsets.only(left: 2),
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[2] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 3
                  ? Container(
                      padding: EdgeInsets.only(left: 2),
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[3] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 4
                  ? Container(
                      padding: EdgeInsets.only(left: 2),
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[4] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 5
                  ? Container(
                      padding: EdgeInsets.only(left: 2),
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[5] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 6
                  ? Container(
                      padding: EdgeInsets.only(left: 2),
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[6] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 7
                  ? Container(
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[7] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
              _list[index].pics.length > 8
                  ? Container(
                      padding: EdgeInsets.only(left: 2),
                      height: 200,
                      child: CachedNetworkImage(
                          imageUrl: _list[index].pics[8] +
                              "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    }
  }

  Widget _comment(index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _love(_list[index].id);
          },
          child: Row(
            children: <Widget>[
              Container(
                height: 28,
                width: 28,
                child: Image.asset("img/love.png"),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, right: 2),
                height: 45,
                child: Text(_list[index].loveNumber.toString()),
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
          padding: EdgeInsets.only(top: 10, right: 20),
          height: 45,
          child: Text(_list[index].commentNumber.toString()),
        ),
      ],
    );
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
        "&msgId=" +
        id;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      Toast.toast(context, '爱心已收到！');
      for (int i = 0; i < _list.length; i++) {
        if (_list[i].id == id) {
          setState(() {
            _list[i].loveNumber++;
          });
        }
      }
    } else {
      Toast.toast(context, data['msg']);
    }
  }
}
