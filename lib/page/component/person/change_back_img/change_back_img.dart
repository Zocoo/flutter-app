import 'dart:io';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/index/index.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:image_crop/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class ChangeBackImg extends StatefulWidget {
  @override
  _ChangeBackImgState createState() => _ChangeBackImgState();
}

class _ChangeBackImgState extends State<ChangeBackImg> {
  String _imageUrl = null;
  File _image;
  final cropKey = GlobalKey<CropState>();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  uploadPic(data1) async {
    var url = Config().serverUrl + '/file/uploadBase64';
    try {
      final http.Response response = await http.post(url, body: data1);
      var data = json.decode(response.body);
      setState(() {
        _imageUrl = data['data'];
        print(_imageUrl);
        _updateHead();
      });
    } catch (e) {
      print("上传文件失败");
    }
  }

  _updateHead() async {
    String token = await LocalStorage().get("token");
    String id = await LocalStorage().get("userId");
    String url = Config().host + "/user?token=" + token;
    String datax = json.encode({'backImg': _imageUrl, 'id': id});
    print(datax);
    final http.Response response = await http.put(url, body: datax);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      await LocalStorage().set("labelId", '3');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Index()),
              (route) => route == null);
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  pic() async {
    final crop = cropKey.currentState;
    final scale = crop.scale;
    print(scale);
    final area = crop.area;
    print(area);
    if (area == null) {
      print("error");
    } else {
      final sampledFile = await ImageCrop.sampleImage(
        file: _image,
        preferredWidth: (512 / scale).round(),
        preferredHeight: (512 / scale).round(),
      );
      final croppedFile = await ImageCrop.cropImage(
        file: sampledFile,
        area: crop.area,
      );
      setState(() {
        _image = croppedFile;
        var image_base64 = base64.encode(_image.readAsBytesSync());
        uploadPic(image_base64);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改背景'),
      ),
      body: Column(
        children: <Widget>[
          Offstage(
            offstage: _imageUrl == null,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text('头像上传成功！！'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child:
                  _imageUrl == null ? Text("") : Image.network(_imageUrl),
                ),
              ],
            ),
          ),
          Offstage(
            offstage: _imageUrl != null,
            child: _image == null
                ? Center(
              child: Padding(
                padding: EdgeInsets.only(
                  right: 0,
                  left: 0,
                  bottom: 0,
                  top: 100,
                ),
                child: Text('未选择图片'),
              ),
            )
                : Container(
              padding: EdgeInsets.all(40),
              height: 300,
              width: 400,
              child: Crop(
                key: cropKey,
                image: FileImage(_image),
                aspectRatio: 4.0 / 2.0,
              ),
            ),
          ),
          Offstage(
            offstage: !(_imageUrl == null && _image != null),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  color: Colors.blue,
                  onPressed: pic,
                  child: Text(
                    '裁剪',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Offstage(
        offstage: _image != null,
        child: FloatingActionButton(
          isExtended: true,
          onPressed: getImage,
          tooltip: 'Pick Image',
          child: Icon(Icons.add_a_photo),
        ),
//        ),
      ),
    );
  }
}
