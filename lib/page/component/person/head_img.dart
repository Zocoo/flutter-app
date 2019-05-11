import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/component/person/change_head/change_head.dart';
import 'package:flutter_wyz/page/component/person/change_back_img/change_back_img.dart';
import 'package:flutter_wyz/page/pojo/user.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeadImg extends StatefulWidget {
  @override
  _HeadImgState createState() => _HeadImgState();
}

class _HeadImgState extends State<HeadImg> {
  User user = new User(null, "", "");
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

  _HeadImgState() {
    _initData();
  }

  _initData() async {
    String id = await LocalStorage().get("userId");
    String token = await LocalStorage().get("token");
    String url = Config().host + "/user?id=" + id + "&token=" + token;
    final http.Response response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    Map data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    var result = data['code'];
    if (result == 0) {
      setState(() {
        user = new User.fromJson(data['data']);
      });
    } else {
      Toast.toast(context, data['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return user.id == null
        ? Container()
        : Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  colorFilter: ColorFilter.matrix(matrix),
                  image: user.backImg == null
                      ? AssetImage("img/pp.png")
                      : NetworkImage(user.backImg),
                  fit: BoxFit.cover),
            ),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (BuildContext context) {
                      return ChangeBackImg();
                    }));
                  },
                  child: Container(
                    height: 120,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(30.0, 0.0, 0, 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, new MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ChangeHead();
                              }));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(80))),
                              height: 80,
                              width: 80,
                              child: ClipOval(
                                child: Image.network(user.headUrl == null
                                    ? 'https://assets-store-cdn.48lu.cn/assets-store/5002cfc3bf41f67f51b1d979ca2bd637.png'
                                    : user.headUrl),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                            child: Container(
//                        color: Colors.red,
                              color: Color.fromARGB(0, 1, 1, 1),
                              height: 100,
                              child: Container(
                                height: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                        user.name == null ? '' : user.name,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        user.phone == null ? '' : user.phone,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      user.autograph == null ? '未签名' : user.autograph,
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
                )
              ],
            ),
          );
  }
}
