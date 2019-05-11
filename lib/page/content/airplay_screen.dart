import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/component/person/head_img.dart';
import 'package:flutter_wyz/page/component/person/menu.dart';

class AirPlayScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('个人中心'),),
      body: Column(
        children: <Widget>[
          HeadImg(),
          Menu(),
        ],
      ),
    );
  }
}