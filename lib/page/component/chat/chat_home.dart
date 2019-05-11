import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/pojo/chat.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:exifdart/exifdart.dart';

class ChatHome extends StatefulWidget {
  ChatHome({Key key, this.id, this.name}) : super(key: key);

  final String id;
  final String name;

  @override
  _ChatHomeState createState() => _ChatHomeState(id, name);
}

class _ChatHomeState extends State<ChatHome> {
  _ChatHomeState(id, name) {
    _id = id;
    _name = name;
    _init();
    _initDhk();
    _ctXlGx();
  }

  bool _f = true;
  String _myHeadUrl = null;
  String _fHeadUrl = null;
  String _id = "";
  String _token = "";
  String _userId = "";
  TextEditingController _msgController = new TextEditingController();
  String _name = "";
  List<Chat> _list = [];
  List<Chat> _listH = [];
  bool _hasMore = true;
  var _controller = new ScrollController();
  Timer _ct;
  bool _xs = false;
  bool _tb = true;
  Timer _ctinit;
  Timer _ctXl;
  bool _xztp = false;
  List<String> _mrPic = [];

  _initPic() async {
    String url =
        Config().host + "/config/queryByType?token=" + _token + "&type=4";
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        for (int i = 0; i < data['data'].length; i++) {
          _mrPic.add(data['data'][i]['content']);
        }
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _ctXlGx() {
    _ctXl = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      if (_listH != null && _listH.length > 0) if (_controller != null &&
          _controller.positions.isNotEmpty) {
        double n = _controller.position.minScrollExtent;
//        print(n);
        if (n != null && n < 50) {
          Chat c = _listH[_listH.length - 1];
          _listH.remove(c);
          List<Chat> list = [];
          list.add(c);
          for (int i = 0; i < _list.length; i++) {
            list.add(_list[i]);
          }
          setState(() {
            _list = list;
          });
        }
      }
    });
  }

  _initDhk() {
    _ctinit = Timer.periodic(new Duration(milliseconds: 100), (timer) {
//      print(_tb);
      if (_tb) if (_controller != null && _controller.positions.isNotEmpty) {
        double n = _controller.position.maxScrollExtent;
        if (n != null && n > 0) {
          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: new Duration(milliseconds: 8), // 300ms
            curve: Curves.bounceIn,
          );
        }
      }
    });
  }

  _init() async {
    _userId = await LocalStorage().get("userId");
    _token = await LocalStorage().get("token");
    _initMyHeadImg();
    _initFHeadImg();
    _initChatData(0, 0);
    _initPic();
  }

  Future<Null> _flush() async {
    if (_hasMore) {
      double h = _controller.position.maxScrollExtent;
      _initChatData(1, h);
    } else {
      Toast.toast(context, '已没有更多数据！');
    }
    return;
  }

  _getNewChatData(int type) async {
    String url = Config().host +
        "/chat/chat?&token=" +
        _token +
        "&userId=" +
        _userId +
        "&friendId=" +
        _id +
        "&chatId=" +
        _getEndId();
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
//    print(data);
    var result = data['code'];
    if (result == 0) {
      if (data['data'] != null) {
        List<dynamic> datas = data['data'];
        for (int i = 0; i < datas.length; i++) {
          setState(() {
            _list.add(Chat.fromJson(datas[i]));
          });
          if (type == 1 || type == 0) {
            _tb = true;
            _maxN = 0;
            _minM = 0;
          }
        }
      }
    }
  }

  _xunhuan() {
    _ct = Timer.periodic(new Duration(seconds: 6), (timer) {
      _getNewChatData(0);
    });
  }

  _initChatData(int type, double hh) async {
    String url = Config().host +
        "/chat/history?&token=" +
        _token +
        "&userId=" +
        _userId +
        "&friendId=" +
        _id +
        "&chatId=" +
        _getStartId();
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
//    print(data);
    var result = data['code'];
    if (result == 0) {
      if (data['data'] != null && data['data'].length > 0) {
        List<Chat> list = [];
        List<dynamic> datas = data['data'];
        if (datas.length != 20) {
          _hasMore = false;
        }
        for (int i = 0; i < datas.length; i++) {
          list.add(Chat.fromJson(datas[i]));
        }
        setState(() {
          if (type == 0) {
            _list = list;
          } else {
            _listH = list;
          }
          if (_f) {
            _f = false;
            _xunhuan();
          }
        });
      }
    }
  }

  String _getStartId() {
    if (_list == null || _list.length < 1) {
      return "919042513011751332";
    } else {
      return _list[0].id;
    }
  }

  String _getEndId() {
    if (_list == null || _list.length < 1) {
      return "0";
    } else {
      return _list[_list.length - 1].id;
    }
  }

  Future getImage() async {
    _tb = true;
    _maxN = 0;
    _minM = 0;
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (null != image) {
      print(image.path);
//    print(image.h);
      if (image.path.endsWith("jpg") ||
          image.path.endsWith("jpeg") ||
          image.path.endsWith("png")) {
        if (image.lengthSync() > 214061) {
          testCompressFile(image);
        } else {
          var image_base64 = base64.encode(image.readAsBytesSync());
          uploadPic(image_base64);
        }
      } else {
        var image_base64 = base64.encode(image.readAsBytesSync());
        uploadPic(image_base64);
      }
//    testCompressFile(image);
//    var image_base64 = base64.encode(image.readAsBytesSync());
//    uploadPic(image_base64);
    }
  }

  Future<List<int>> testCompressFile(File file) async {
    int r = await getImageRotateAngular(file.readAsBytesSync());
    print(r);
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 94,
      rotate: r,
    );
    print(file.lengthSync());
    print(result.length);
    var image_base64 = base64.encode(result);
    uploadPic(image_base64);
//    return result;
  }

  Future<int> getImageRotateAngular(List<int> bytes) async {
    Map<String, dynamic> tags = await readExif(MemoryBlobReader(bytes));
    if (tags == null || tags['Orientation'] == null) return 0;
    var orientation = tags['Orientation']; //获取该照片的拍摄方向
    switch (orientation) {
      case 3:
        return 180;
      case 6:
        return 90;
      case 8:
        return -90;
      default:
        return 0;
    }
  }

  uploadPic(data1) async {
    var url = Config().serverUrl + '/file/uploadBase64';
    try {
      final http.Response response = await http.post(url, body: data1);
      var data = json.decode(response.body);
      print(data);
      _sendImgMsg(data['data']);
    } catch (e) {
      print("上传文件失败");
    }
  }

  _sendImgMsg(url1) async {
    String url = Config().host + "/chat?&token=" + _token;
    String datax = json.encode(
        {'content': url1, 'userId': _userId, 'friendId': _id, 'type': 2});
    final http.Response response = await http.post(url, body: datax);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _getNewChatData(1);
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _sendTextMsg() async {
    String m = _msgController.text;
    print(m);
    _msgController.text = "";
    String url = Config().host + "/chat?&token=" + _token;
    String datax = json
        .encode({'content': m, 'userId': _userId, 'friendId': _id, 'type': 1});
    final http.Response response = await http.post(url, body: datax);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _getNewChatData(1);
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _initMyHeadImg() async {
    String url = Config().host + "/user?id=" + _userId + "&token=" + _token;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _myHeadUrl = data['data']['headUrl'];
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  _initFHeadImg() async {
    String url = Config().host + "/user?id=" + _id + "&token=" + _token;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        _fHeadUrl = data['data']['headUrl'];
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          width: double.infinity,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
//                width: 50,
                padding: EdgeInsets.only(right: 1),
                child: MaterialButton(
                  minWidth: 10,
                  onPressed: () {
//                    getImage();
                    setState(() {
                      _xztp = true;
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  child: Icon(Icons.image),
                ),
              ),
//              Container(
//                width: 50,
////            color: Colors.red,
//                padding: EdgeInsets.only(right: 1),
//                child: MaterialButton(
//                  minWidth: 1,
//                  onPressed: () {
//                    print('xxxx');
//                    FocusScope.of(context).requestFocus(FocusNode());
//                    setState(() {
//                      _xztp = true;
//                    });
//                  },
//                  child: Icon(Icons.image),
//                ),
//              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    right: 1,
                  ),
                  child: TextField(
                    onTap: () {
                      _tb = true;
                      _maxN = 0;
                      _minM = 0;
                      setState(() {
                        _xztp = false;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '输入',
                      suffixIcon: new IconButton(
                        icon: new Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          if (_msgController.text == null ||
                              _msgController.text == '') {
                            Toast.toast(context, '不能发送空消息！');
                          } else {
                            _sendTextMsg();
                          }
                        },
                      ),
                    ),
                    controller: _msgController,
                  ),
                ),
              ),
            ],
          ),
        ),
        Offstage(
          offstage: !_xztp,
          child: Container(
            padding: EdgeInsets.only(bottom: 20, left: 15, right: 15),
            height: 140,
            width: double.infinity,
            child: ListView.builder(
                itemCount: _mrPic.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _onePic(index);
                }),
//            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _onePic(index) {
    return GestureDetector(
        onTap: () {
          print(index);
          if (index == 0) {
            getImage();
          } else {
            _sendImgMsg(_mrPic[index]);
          }
        },
        child: Container(
          height: 100,
          padding: EdgeInsets.only(left: 5),
          child: CachedNetworkImage(imageUrl: _mrPic[index] +
              "?x-oss-process=image/resize,m_lfit,h_200,w_200"),
        ));
  }

  Widget _chatList(index) {
    if (_list[index].userId == _id) {
      // 收到的消息
      if (_list[index].type == 1) {
        // 收到的文字消息
        return Offstage(
          offstage: _xs,
          child: Container(
            padding: EdgeInsets.all(10),
//          color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  child: new ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: CachedNetworkImage(
                        imageUrl: _fHeadUrl == null
                            ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png' +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"
                            : _fHeadUrl +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                  ),
                ),
                Flexible(
                    child: Container(
                  padding: EdgeInsets.only(left: 10, right: 80),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 10, top: 10, bottom: 3, right: 10),
//                      height:1,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 7),
                          child: Text(
                            _list[index].content,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 240, 240, 240),
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            DateTime.fromMicrosecondsSinceEpoch(
                                    _list[index].createAt * 1000 * 1000)
                                .toString()
                                .substring(0, 19),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 200, 200, 200)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      } else {
        // 收到的图片消息
        return Offstage(
          offstage: _xs,
          child: Container(
            padding: EdgeInsets.all(10),
//          color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  child: new ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: CachedNetworkImage(
                        imageUrl: _fHeadUrl == null
                            ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png' +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"
                            : _fHeadUrl +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    width: 200,
                    child: Column(
                      children: <Widget>[
                        new ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: CachedNetworkImage(
                              imageUrl: _list[index].content +
                                  "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                        ),
                        Container(
                          child: Text(
                            DateTime.fromMicrosecondsSinceEpoch(
                                    _list[index].createAt * 1000 * 1000)
                                .toString()
                                .substring(0, 19),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 200, 200, 200)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // 发送的消息
      if (_list[index].type == 1) {
        // 发送的文字消息
        return Offstage(
          offstage: _xs,
          child: Container(
            padding: EdgeInsets.all(10),
//          color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(right: 10, left: 80),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 10, top: 10, bottom: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 7),
                            child: Text(
                              _list[index].content,
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 240, 240, 240),
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              DateTime.fromMicrosecondsSinceEpoch(
                                      _list[index].createAt * 1000 * 1000)
                                  .toString()
                                  .substring(0, 19),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 200, 200, 200)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  child: new ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: CachedNetworkImage(
                        imageUrl: _myHeadUrl == null
                            ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png' +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"
                            : _myHeadUrl +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Offstage(
          offstage: _xs,
          child: Container(
            padding: EdgeInsets.all(10),
//          color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(right: 10),
                    width: 200,
                    child: Column(
                      children: <Widget>[
                        new ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: CachedNetworkImage(
                              imageUrl: _list[index].content +
                                  "?x-oss-process=image/resize,m_lfit,h_500,w_500"),
                        ),
                        Container(
                          child: Text(
                            DateTime.fromMicrosecondsSinceEpoch(
                                    _list[index].createAt * 1000 * 1000)
                                .toString()
                                .substring(0, 19),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 200, 200, 200)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  child: new ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: CachedNetworkImage(
                        imageUrl: _myHeadUrl == null
                            ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png' +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"
                            : _myHeadUrl +
                                "?x-oss-process=image/resize,m_lfit,h_100,w_100"),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  int _maxN = 0;

  int _minM = 0;

  int _endT = 0;

  Widget _msg() {
    return _list.length < 1
        ? Expanded(
            child: Container(
              child: Center(
                child: Text('暂无消息'),
              ),
            ),
          )
        : Expanded(
            child: GestureDetector(
              child: Container(
                child: RefreshIndicator(
                  child: NotificationListener(
                    onNotification: (ScrollNotification note) {
                      int n = note.metrics.pixels.toInt();
                      if (n >= _maxN) {
                        _maxN = n;
                        _minM = 0;
                      } else {
                        _minM++;
                      }
                      if (_minM > 3) {
                        _tb = false;
                        _minM = 0;
                      }
                    },
                    child: ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        return _chatList(index);
                      },
                      controller: _controller,
                    ),
                  ),
                  onRefresh: _flush,
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_name),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              _msg(),
              _input(),
            ],
          ),
        ),
      ),
      onWillPop: () {
        if (_ct != null) _ct.cancel();
        if (_ctinit != null) _ctinit.cancel();
        if (_ctXl != null) _ctXl.cancel();
        Navigator.pop(context);
        return new Future.value(false);
      },
    );
  }
}
