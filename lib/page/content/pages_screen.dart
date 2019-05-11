import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/component/chat/chat_list.dart';

class PagesScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('消息中心'),
      ),
      body: ChatList(),
    );
  }

}