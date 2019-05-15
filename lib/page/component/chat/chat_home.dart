import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http_parser/http_parser.dart';
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
import 'package:flutter_sound/flutter_sound.dart';

//import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

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
//    _ctXlGxx();
  }

  @override
  void dispose() {
    try {
      if (null != _ctXl1) _ctXl1.cancel();
    } catch (e) {}
    try {
      if (null != _ctXl) _ctXl.cancel();
    } catch (e) {}
    try {
      if (null != _ctinit) _ctinit.cancel();
    } catch (e) {}
    try {
      if (null != _ctXl2) _ctXl2.cancel();
    } catch (e) {}
    super.dispose();
  }

  FlutterSound flutterSound = new FlutterSound();
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
  Timer _ctXl2;
  Timer _ctXl1;
  int _xztp = 2;
  List<String> _mrPic = [];

  _ctXlGxx() {
    _bofangStr = '.';
    _ctXl2 = Timer.periodic(new Duration(milliseconds: 500), (timer) {
      if (_bofangStr == '.') {
        _bofangStr = '..';
      } else if (_bofangStr == '..') {
        _bofangStr = '...';
      } else if (_bofangStr == '...') {
        _bofangStr = '....';
      } else if (_bofangStr == '....') {
        _bofangStr = '.....';
      } else if (_bofangStr == '.....') {
        _bofangStr = '......';
      } else if (_bofangStr == '......') {
        _bofangStr = '.';
      }
    });
  }

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

  _luying() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('语音'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('语音录制完毕！'),
                IconButton(
                  onPressed: () {
                    startPlayer(dataxx);
                  },
                  icon: Icon(Icons.play_circle_outline),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('发送'),
                  onPressed: () {
                    Navigator.pop(context);
                    _sendTextVoid(dataxx);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
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
    var url = Config().host + '/file/uploadBase64';
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

  _sendTextVoid(String dataxx) async {
    if ((_endTime - _startTime) > 1000) {
      _msgController.text = "";
      String url = Config().host + "/chat?&token=" + _token;
      String datax = json.encode({
        'content': dataxx + "-" + (_endTime - _startTime).toString(),
        'userId': _userId,
        'friendId': _id,
        'type': 3
      });
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
    } else {
      Toast.toast(context, '语音时间太短！');
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

  bool _luyining = false;

  int _startTime = 0;

  int _endTime = 0;

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
                      _xztp = 1;
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  child: Icon(Icons.image),
                ),
              ),
              Container(
//                width: 50,
                padding: EdgeInsets.only(right: 1),
                child: MaterialButton(
                  minWidth: 10,
                  onPressed: () {
//                    getImage();
                    setState(() {
                      _xztp = 3;
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  child: Icon(Icons.keyboard_voice),
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
                        _xztp = 2;
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
          offstage: 1 != _xztp,
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
        Offstage(
          offstage: 3 != _xztp,
          child: Container(
            padding: EdgeInsets.only(bottom: 0, left: 0, right: 0),
            height: 140,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
//    onLongPressDragUp: (r) { //flutter sdk 1.2.1
                  onLongPressUp: () {// flutter sdk 1.54
                    _endTime = DateTime.now().millisecondsSinceEpoch;
                    print(_endTime);
                    print(_endTime - _startTime);
                    this.stopRecorder();
                    setState(() {
                      _luyining = false;
                    });
//                    Navigator.pop(context);
//                    if (_ctXl1 != null) _ctXl1.cancel();
                  },
//    onLongPressDragStart: (r) {  // flutter sdk 1.2.1
                  onLongPressStart: (r) {// flutter sdk 1.5.4
                    _startTime = DateTime.now().millisecondsSinceEpoch;
                    print(_startTime);
                    this.startRecorder();
                    setState(() {
                      _luyining = true;
                    });
//                    _luying();
//                    _ctXl1 = Timer.periodic(
//                        new Duration(milliseconds: 100), (timer) {});
                  },
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              _luyining ? "img/luyin.gif" : "img/luyin.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
//                ListView(
//              children: <Widget>[
//                Column(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Container(
//                      margin: EdgeInsets.only(top: 24.0, bottom: 16.0),
//                      child: Text(
//                        this._recorderTxt,
//                        style: TextStyle(
//                          fontSize: 48.0,
//                          color: Colors.black,
//                        ),
//                      ),
//                    ),
//                    _isRecording
//                        ? LinearProgressIndicator(
//                            value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
//                            valueColor:
//                                AlwaysStoppedAnimation<Color>(Colors.green),
//                            backgroundColor: Colors.red,
//                          )
//                        : Container()
//                  ],
//                ),
//                Row(
//                  children: <Widget>[
//                    Container(
//                      width: 56.0,
//                      height: 56.0,
//                      child: ClipOval(
//                        child: FlatButton(
//                          onPressed: () {
//                            if (!this._isRecording) {
//                              return this.startRecorder();
//                            }
//                            this.stopRecorder();
//                          },
//                          padding: EdgeInsets.all(8.0),
//                          child: Image(
//                            image: this._isRecording
//                                ? AssetImage('img/ic_stop.png')
//                                : AssetImage('img/ic_mic.png'),
//                          ),
//                        ),
//                      ),
//                    ),
//                  ],
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                ),
//                Column(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Container(
//                      margin: EdgeInsets.only(top: 60.0, bottom: 16.0),
//                      child: Text(
//                        this._playerTxt,
//                        style: TextStyle(
//                          fontSize: 48.0,
//                          color: Colors.black,
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//                Row(
//                  children: <Widget>[
//                    Container(
//                      width: 56.0,
//                      height: 56.0,
//                      child: ClipOval(
//                        child: FlatButton(
//                          onPressed: () {
//                            startPlayer('');
//                          },
//                          padding: EdgeInsets.all(8.0),
//                          child: Image(
//                            image: AssetImage('img/ic_play.png'),
//                          ),
//                        ),
//                      ),
//                    ),
//                    Container(
//                      width: 56.0,
//                      height: 56.0,
//                      child: ClipOval(
//                        child: FlatButton(
//                          onPressed: () {
//                            pausePlayer();
//                          },
//                          padding: EdgeInsets.all(8.0),
//                          child: Image(
//                            width: 36.0,
//                            height: 36.0,
//                            image: AssetImage('img/ic_pause.png'),
//                          ),
//                        ),
//                      ),
//                    ),
//                    Container(
//                      width: 56.0,
//                      height: 56.0,
//                      child: ClipOval(
//                        child: FlatButton(
//                          onPressed: () {
//                            stopPlayer();
//                          },
//                          padding: EdgeInsets.all(8.0),
//                          child: Image(
//                            width: 28.0,
//                            height: 28.0,
//                            image: AssetImage('img/ic_stop.png'),
//                          ),
//                        ),
//                      ),
//                    ),
//                  ],
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                ),
//                Container(
//                    height: 56.0,
//                    child: Slider(
//                        value: slider_current_position,
//                        min: 0.0,
//                        max: max_duration,
//                        onChanged: (double value) async {
//                          await flutterSound.seekToPlayer(value.toInt());
//                        },
//                        divisions: max_duration.toInt()))
//              ],
//            ),
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
          child: CachedNetworkImage(
              imageUrl: _mrPic[index] +
                  "?x-oss-process=image/resize,m_lfit,h_200,w_200"),
        ));
  }

  int _bofangId = 0;
  String _bofangStr = '....';

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
      } else if (_list[index].type == 2) {
        // 收到的图片消息
        print("xx");
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
      } else {
        print("xxx");
        String t = _list[index].content.split('-')[1];
        t = t.substring(0, t.length - 3);
//        print(t);
        return Offstage(
          offstage: _xs,
          child: GestureDetector(
            onTap: () {
              print(_bofangId);
              if (_bofangId == 0) {
                _bofangId = int.parse(_list[index].id);
                startPlayer(_list[index].content.split("-")[0]);
              } else if (_bofangId.toString() == _list[index].id)
                stopPlayer();
              else {
                stopPlayer();
                _bofangId = int.parse(_list[index].id);
                startPlayer(_list[index].content.split("-")[0]);
              }
            },
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
                            width: 100,
                            padding: EdgeInsets.only(bottom: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(
                                    'img/yyl.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 240, 240, 240),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    _bofangId.toString() == _list[index].id
                                        ? _bofangStr
                                        : '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 240, 240, 240),
                                    ),
                                  ),
                                ),
                              ],
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
      } else if (_list[index].type == 2) {
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
      } else {
        String t = _list[index].content.split('-')[1];
        t = t.substring(0, t.length - 3);
//        print(t);
        return Offstage(
          offstage: _xs,
          child: GestureDetector(
            onTap: () {
              if (_bofangId == 0) {
                _bofangId = int.parse(_list[index].id);
                startPlayer(_list[index].content.split("-")[0]);
              } else if (_bofangId.toString() == _list[index].id)
                stopPlayer();
              else {
                stopPlayer();
                _bofangId = int.parse(_list[index].id);
                startPlayer(_list[index].content.split("-")[0]);
              }
            },
            child: Container(
              width: 100,
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
                              width: 100,
                              padding: EdgeInsets.only(bottom: 7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      _bofangId.toString() == _list[index].id
                                          ? _bofangStr
                                          : '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            Color.fromARGB(255, 240, 240, 240),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            Color.fromARGB(255, 240, 240, 240),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      'img/yyr.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
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

  void startRecorder() async {
    bool res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    print(res);
    if (!res) {
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
    }
    if (res) {
      try {
        String path = await flutterSound.startRecorder(null);
        print('startRecorder: $path');
        _path = path;
        _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
//        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
//            e.currentPosition.toInt(),
//            isUtc: true);
//        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
//
//

          String d = DateTime.fromMicrosecondsSinceEpoch(
                  DateTime.now().millisecondsSinceEpoch * 1000)
              .toString()
              .substring(0, 19);
          this.setState(() {
            this._recorderTxt = d;
          });
        });
        _dbPeakSubscription =
            flutterSound.onRecorderDbPeakChanged.listen((value) {
          print("got update -> $value");
          setState(() {
            this._dbLevel = value;
          });
        });

        this.setState(() {
          this._isRecording = true;
        });
      } catch (err) {
        print('startRecorder error: $err');
      }
    }
  }

  String _path = '';

  void stopRecorder() async {
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
      File v = new File(_path);
      print(v.readAsBytesSync());
      String s = base64.encode(v.readAsBytesSync());
      this.dataxx = s;
      if ((_endTime - _startTime) > 1000) {
        _luying();
      } else {
        Toast.toast(context, '语音时间太短！');
      }
//      await _sendTextVoid(s);
//      List<int> a = base64.decode(s);
//      print(a);
//      ff.writeAsBytesSync(a);
//      print(ff.readAsBytesSync());
//      _uf();
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  String dataxx;

  void startPlayer(String data) async {
    _ctXlGxx();
//    if (_isPlaying) {
//      stopPlayer();
//      return;
//    }
    bool res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    print(res);
    if (!res) {
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
    }
    if (res) {
      List<int> a = base64.decode(data);
      var directory = await getExternalStorageDirectory();
      File ff = new File(directory.path + "/bofang.m4a");
      ff.writeAsBytesSync(a);
      String path = await flutterSound.startPlayer(ff.path);
      await flutterSound.setVolume(1.0);
      print('startPlayer: $path');

      try {
        _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
          if (e != null) {
            slider_current_position = e.currentPosition;
            max_duration = e.duration;

            String d = DateTime.fromMicrosecondsSinceEpoch(
                    DateTime.now().millisecondsSinceEpoch * 1000)
                .toString()
                .substring(0, 19);
            this.setState(() {
              this._isPlaying = true;
              this._playerTxt = d;
            });
          } else {
            _bofangId = 0;
            _ctXl2.cancel();
          }
        });
//        _bofangId = 0;
//        _ctXl2.cancel();
      } catch (err) {
        print('error: $err');
      }
    }
  }

  void stopPlayer() async {
    _bofangId = 0;
    _ctXl2.cancel();
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        this._isPlaying = false;
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async {
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }

  void resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async {
    String result = await flutterSound.seekToPlayer(milliSecs);
    print('seekToPlayer: $result');
  }

  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;

  double slider_current_position = 0.0;
  double max_duration = 1.0;

  static String _boundaryString() {
    var prefix = "---DartFormBoundary";
    var list = new List<int>.generate(
        _BOUNDARY_LENGTH - prefix.length,
        (index) =>
            _BOUNDARY_CHARACTERS[_random.nextInt(_BOUNDARY_CHARACTERS.length)],
        growable: false);
    return "$prefix${new String.fromCharCodes(list)}";
  }

  static String randomStr(
      [int len = 8, List<int> chars = _BOUNDARY_CHARACTERS]) {
    var list = new List<int>.generate(
        len, (index) => chars[_random.nextInt(chars.length)],
        growable: false);
    return new String.fromCharCodes(list);
  }

  static const List<int> _BOUNDARY_CHARACTERS = const <int>[
    0x30,
    0x31,
    0x32,
    0x33,
    0x34,
    0x35,
    0x36,
    0x37,
    0x38,
    0x39,
    0x61,
    0x62,
    0x63,
    0x64,
    0x65,
    0x66,
    0x67,
    0x68,
    0x69,
    0x6A,
    0x6B,
    0x6C,
    0x6D,
    0x6E,
    0x6F,
    0x70,
    0x71,
    0x72,
    0x73,
    0x74,
    0x75,
    0x76,
    0x77,
    0x78,
    0x79,
    0x7A,
    0x41,
    0x42,
    0x43,
    0x44,
    0x45,
    0x46,
    0x47,
    0x48,
    0x49,
    0x4A,
    0x4B,
    0x4C,
    0x4D,
    0x4E,
    0x4F,
    0x50,
    0x51,
    0x52,
    0x53,
    0x54,
    0x55,
    0x56,
    0x57,
    0x58,
    0x59,
    0x5A
  ];
  static const int _BOUNDARY_LENGTH = 48;
  static final Random _random = new Random();

  static Map _makeHttpHeaders(
      [String contentType,
      String accept,
      String token,
      String XRequestWith,
      String XMethodOverride]) {
    Map headers = new Map<String, String>();
    int i = 0;

    if (contentType != null && contentType.length > 0) {
      i++;
      headers["Content-Type"] = contentType;
    }

    if (accept != null && accept.length > 0) {
      i++;
      headers["Accept"] = accept;
    }

    if (token != null && token.length > 0) {
      i++;
      headers["Authorization"] = "bearer " + token;
    }

    if (XRequestWith != null && XRequestWith.length > 0) {
      i++;
      headers["X-Requested-With"] = XRequestWith;
    }

    if (XMethodOverride != null && XMethodOverride.length > 0) {
      i++;
      headers["X-HTTP-Method-Override"] = XMethodOverride;
    }

    if (i == 0) return null;
    // print(headers.toString());
    return headers;
  }

  static MediaType getMediaType(final String fileExt) {
    switch (fileExt) {
      case ".jpg":
      case ".jpeg":
      case ".jpe":
        return new MediaType("image", "jpeg");
      case ".png":
        return new MediaType("image", "png");
      case ".bmp":
        return new MediaType("image", "bmp");
      case ".gif":
        return new MediaType("image", "gif");
      case ".json":
        return new MediaType("application", "json");
      case ".svg":
      case ".svgz":
        return new MediaType("image", "svg+xml");
      case ".mp3":
        return new MediaType("audio", "mpeg");
      case ".m4a":
        return new MediaType("audio", "mpeg");
      case ".mp4":
        return new MediaType("video", "mp4");
      case ".htm":
      case ".html":
        return new MediaType("text", "html");
      case ".css":
        return new MediaType("text", "css");
      case ".csv":
        return new MediaType("text", "csv");
      case ".txt":
      case ".text":
      case ".conf":
      case ".def":
      case ".log":
      case ".in":
        return new MediaType("text", "plain");
    }
    return null;
  }
}
