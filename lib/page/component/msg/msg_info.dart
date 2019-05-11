import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/component/friend/friend_info.dart';
import 'package:flutter_wyz/page/component/msg/comment_back.dart';
import 'package:flutter_wyz/page/pojo/comment.dart';
import 'package:flutter_wyz/page/pojo/msg.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class MsgInfo extends StatefulWidget {
  MsgInfo({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _MsgInfoState createState() => _MsgInfoState(id);
}

class _MsgInfoState extends State<MsgInfo> {
  _MsgInfoState(id) {
    _id = id;
    _initMsg();
    _initComment();
  }

  String _id = "-1";
  Msg _msg;
  bool _loadinged = false;
  List<Comment> _list = [];
  String _showPic = "";

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

  _initMsg() async {
    String token = await LocalStorage().get("token");
    String url = Config().host + "/msg?token=" + token + "&id=" + _id;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _msg = Msg.fromJson(data['data']);
        _loadinged = true;
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  Widget _displayOneMsg() {
    return _loadinged
        ? Container(
            padding: EdgeInsets.only(top: 2),
            child: Container(
              child: Column(
                children: <Widget>[
                  _commentList(),
                  _input(),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget _title() {
    return Container(
      padding: EdgeInsets.only(left: 15),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (BuildContext context) {
                return FriendInfo(id: _msg.userId);
              }));
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
                      fontSize: 18, color: Color.fromARGB(255, 1, 1, 1)),
                ),
                Text(
                  _msg.autograph,
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
                      _msg.createAt * 1000 * 1000)
                  .toString()
                  .substring(0, 19)),
            ),
          )
        ],
      ),
    );
  }

  Widget _content() {
    return (_msg.content != null && _msg.content.length > 0)
        ? LimitedBox(
            maxHeight: ((_msg.pics == null ||
                    (_msg.pics.length == 1 &&
                        (_msg.pics[0] == null || _msg.pics[0] == ""))))
                ? 250
                : 150,
            child: Container(
              width: double.infinity,
//            height: 100,
              padding:
                  EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
              child: SingleChildScrollView(
                child: Text(
                  _msg.content,
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

  double _m = 0;
  int _i = 0;

  _loadPic(i) {
    _i = i;
    _showPic = _msg.pics[i];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String url;
        return StatefulBuilder(
          builder: (context, state) {
            return AlertDialog(
//          backgroundColor: Color.fromARGB(255, 250, 250, 250),
              content: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                onDoubleTap: () {
                  print("hia hia");
                },
                onHorizontalDragStart: (startDetails) {
                  _m = 0;
                },
                onHorizontalDragUpdate: (d) {
                  _m = _m + d.delta.dx;
                },
                onHorizontalDragEnd: (endDetails) {
                  if (_m > 0) {
                    print('left');
                    if (_i < 1) {
                      Toast.toast(context, '这是第一张了！');
                    } else {
                      _i--;
                      state(() {
                        _showPic = _msg.pics[_i];
                      });
                    }
                  } else {
                    print('left' + _i.toString());
                    if (_i >= _msg.pics.length - 1) {
                      Toast.toast(context, '这是最后一张了！');
                    } else {
                      _i++;
                      state(() {
                        _showPic = _msg.pics[_i];
                      });
                    }
                  }
                },
                child: getP(),
              ),
            );
          },
        );
      },
    );
  }

  Widget getP() {
    return Container(
      height: 400,
      width: 400,
      child: CachedNetworkImage(
        imageUrl: _showPic,
      ),
    );
  }

  Widget _pic() {
    if (_msg.pics == null ||
        (_msg.pics.length == 1 &&
            (_msg.pics[0] == null || _msg.pics[0] == ""))) {
      return Container();
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 10, left: 15),
        child: Container(
          height: 210,
          width: double.infinity,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _msg.pics.length > 0
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(0);
                      },
                      child: Container(
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[0] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 1
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(1);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 2),
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[1] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 2
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(2);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 2),
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[2] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 3
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(3);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 2),
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[3] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 4
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(4);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 2),
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[4] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 5
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(5);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 2),
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[5] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 6
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(6);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 2),
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[6] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 7
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(7);
                      },
                      child: Container(
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[7] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
              _msg.pics.length > 8
                  ? GestureDetector(
                      onTap: () {
                        _loadPic(8);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 2),
                        height: 200,
                        child: CachedNetworkImage(
                            imageUrl: _msg.pics[8] +
                                "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    }
  }

  Widget _comment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
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
                padding: EdgeInsets.only(top: 10, right: 2),
                height: 45,
                child: Text(_msg.loveNumber.toString()),
              ),
              Container(
                width: 15,
                height: 30,
                color: Color.fromARGB(255, 250, 250, 250),
              ),
            ],
          ),
        ),
        Icon(Icons.message),
        Container(
          padding: EdgeInsets.only(top: 10, right: 20),
          height: 45,
          child: Text(_msg.commentNumber.toString()),
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

  Widget _commentList() {
    return Expanded(
      child: Container(
//        color: Color.fromARGB(255, 44, 99, 137),
        child: ListView.builder(
          itemCount: _list.length + 2,
          itemBuilder: (context, index) {
            index = index - 1;
            if (index == -1) {
              return Column(
                children: <Widget>[
                  _title(),
                  _content(),
                  _pic(),
                  _comment(),
                ],
              );
            } else if (index == 0 && _list.length == 0) {
              return Container(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                  child: Text('暂无评论'),
                ),
              );
            } else if(index == _list.length)
              {
                return Container();
              }else
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
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        new MaterialPageRoute(
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50))),
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
                                  )),
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
                                              _list[index].createAt *
                                                  1000 *
                                                  1000)
                                          .toString()
                                          .substring(0, 19),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromARGB(
                                              255, 150, 150, 150)),
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
                                              child:
                                                  Image.asset("img/love.png"),
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
                                            ),
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
                                            Icon(Icons.message),
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
                                            ),
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
                            left: 15,
                            right: 15,
                            top: 5,
                            bottom: 5,
                          ),
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
                ),
              );
          },
        ),
      ),
    );
  }

  TextEditingController _phonecontroller = new TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("详情"),
      ),
      body: Container(
        child: _displayOneMsg(),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

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

  _commitComment() async {
    String token = await LocalStorage().get("token");
    String userId = await LocalStorage().get("userId");
    String url = Config().host + "/comment?token=" + token;
    String datax = json.encode(
        {'content': _phonecontroller.text, 'userId': userId, "msgId": _id});
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
}
