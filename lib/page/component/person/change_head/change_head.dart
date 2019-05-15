import 'dart:io';
import 'package:exifdart/exifdart.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/index/index.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:image_crop/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

class ChangeHead extends StatefulWidget {
  @override
  _ChangeHeadState createState() => _ChangeHeadState();
}

class _ChangeHeadState extends State<ChangeHead> {
  bool _tjz = false;
  String _imageUrl = null;
  File _image;
  final cropKey = GlobalKey<CropState>();

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    int r = await getImageRotateAngular(image.readAsBytesSync());
    print(r);
    if (r == 0) {
      setState(() {
        _image = image;
      });
    } else {
      var directory = await getExternalStorageDirectory();
      bool res = await SimplePermissions.checkPermission(
          Permission.WriteExternalStorage);
      if (!res)
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
      print(res);
      print(directory.path + "/tmp.jpg");
      image =
          await testCompressAndGetFile(image, directory.path + "/tmp.jpg", r);
      setState(() {
        _image = image;
      });
    }
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

  Future<File> testCompressAndGetFile(
      File file, String targetPath, int r) async {
    File result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 94,
      rotate: r,
    );
    print(file.lengthSync());
    print(result.lengthSync());
    return result;
  }

  uploadPic(data1) async {
    var url = Config().host + '/file/uploadBase64';
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
    String datax = json.encode({'headUrl': _imageUrl, 'id': id});
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
    if (!_tjz) {
      _tjz = true;
      final crop = cropKey.currentState;
      final scale = crop.scale;
      final area = crop.area;
      if (area == null) {
        print("error");
      } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改头像'),
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
