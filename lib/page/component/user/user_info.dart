import 'dart:io';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:image_crop/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {

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
      });
    } catch (e) {
      print("上传文件失败");
    }
  }

  pic() async {
    final crop = cropKey.currentState;
    final scale = crop.scale;
    final area = crop.area;
    if (area == null) {
      print("error");
    } else {
//      final permissionsGranted = await ImageCrop.requestPermissions();
//      print("error");
//      print(permissionsGranted);
      final sampledFile = await ImageCrop.sampleImage(
        file: _image,
        preferredWidth: (512 / crop.scale).round(),
        preferredHeight: (512 / crop.scale).round(),
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
        title: Text('Image Picker Example'),
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
                    padding: EdgeInsets.all(50),
                    height: 400,
                    width: 400,
                    child: Crop(
                      key: cropKey,
                      image: FileImage(_image),
                      aspectRatio: 1.0 / 1.0,
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
