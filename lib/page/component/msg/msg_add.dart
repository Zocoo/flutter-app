import 'dart:io';
import 'dart:convert';
import 'package:exifdart/exifdart.dart';
import 'package:flutter_wyz/page/index/index.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MsgAdd extends StatefulWidget {
  @override
  _MsgAddState createState() => _MsgAddState();
}

class _MsgAddState extends State<MsgAdd> {
  TextEditingController _pwdcontroller1 = new TextEditingController();
  List<String> _listPic = [];

  Future getImage1() async {
    _uploadIng();
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    print(image.path);
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

  Future getImage() async {
    _uploadIng();
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.path);
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

  Future<List<int>> testCompressFile(File file) async {
    int r = await getImageRotateAngular(file.readAsBytesSync());
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

  _uploadIng() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 54, 195, 229),
            content: SingleChildScrollView(
              child: Image.asset("img/loading.gif"),
            ),
          );
        });
  }

  uploadPic(data1) async {
    var url = Config().host + '/file/uploadBase64';
    try {
      final http.Response response = await http.post(url, body: data1);
      var data = json.decode(response.body);
      setState(() {
        _listPic.add(data['data']);
        print(data['data']);
        Navigator.pop(context);
      });
    } catch (e) {
      print("上传文件失败");
    }
  }

  Widget choice(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('提示'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    getImage1();
                  },
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          getImage1();
                        },
                        icon: Icon(Icons.camera_alt),
                      ),
                      Text('拍照'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    getImage();
                  },
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          getImage();
                        },
                        icon: Icon(Icons.image),
                      ),
                      Text('相册'),
                    ],
                  ),
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
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _getPic(int i) {
    print(_listPic.length);
    if (i == _listPic.length && _listPic.length != 9) {
      return GestureDetector(
        onTap: () {
          choice(context);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
          ),
          child: Image.asset("img/add.png"),
        ),
      );
    } else if (i <= _listPic.length) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _listPic.removeAt(i);
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
          ),
          child: Image.network((_listPic.length <= i || _listPic[i] == null)
              ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png'
              : _listPic[i] + "?x-oss-process=image/resize,m_lfit,h_800,w_800"),
        ),
      );
    } else {
      return Container();
    }
  }

  _commit() async {
    if (_pwdcontroller1.text.isNotEmpty &&
        (_listPic == null && _listPic.length < 1)) {
      Toast.toast(context, '请先输入文字或者上传图片！');
    } else {
      String token = await LocalStorage().get("token");
      String id = await LocalStorage().get("userId");
      String url = Config().host + "/msg?token=" + token;
      String picUrls = "";
      for (int i = 0; i < _listPic.length; i++) {
        if (i < _listPic.length - 1)
          picUrls = picUrls + _listPic[i] + ",";
        else
          picUrls = picUrls + _listPic[i] + "";
      }
      String datax = json.encode(
          {'content': _pwdcontroller1.text, 'userId': id, "picUrls": picUrls});
      print(datax);
      final http.Response response = await http.post(url, body: datax);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      Map data = json.decode(utf8decoder.convert(response.bodyBytes));
      var result = data['code'];
      if (result == 0) {
        await LocalStorage().set("labelId", '0');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Index()),
            (route) => route == null);
      } else {
        Toast.toast(context, data['msg']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("发布消息"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 140,
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: '输入框...', border: InputBorder.none),
                    controller: _pwdcontroller1,
                    maxLines: 6,
//                    autofocus: true,
                    obscureText: false,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Container(
                height:
                    _listPic.length < 3 ? 170 : _listPic.length < 6 ? 340 : 510,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 170,
                            child: _getPic(0),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 170,
                            child: _getPic(1),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 170,
                            child: _getPic(2),
                          ),
                        ),
                      ],
                    ),
                    _listPic.length >= 3
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height: 170,
                                  child: _getPic(3),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 170,
                                  child: _getPic(4),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 170,
                                  child: _getPic(5),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    _listPic.length >= 6
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height: 170,
                                  child: _getPic(6),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 170,
                                  child: _getPic(7),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 170,
                                  child: _getPic(8),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
              new Container(
                width: 340.0,
                child: new Card(
                  color: Colors.blue,
//                  elevation: 16.0,
                  child: new FlatButton(
                    child: new Padding(
                      padding: new EdgeInsets.all(10.0),
                      child: new Text(
                        '提交',
                        style:
                            new TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                    onPressed: _commit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
