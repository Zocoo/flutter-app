import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/component/msg/msg_list.dart';
import 'package:flutter_wyz/page/component/msg/msg_my.dart';
import 'package:flutter_wyz/page/component/msg/msg_my_care.dart';

class MsgHome extends StatefulWidget {
  @override
  _MsgHomeState createState() => _MsgHomeState();
}

class _MsgHomeState extends State<MsgHome> {
  final List<int> _m = [0, 1, 2];
  final List<String> _ms = ['关注', '所有', '我的'];
  int _c = 1;

  getContent(int c) {
    if (c == 0) {
      return MsgMyCare();
    } else if (c == 1) {
      return MsgList();
    } else if (c == 2) {
      return MsgMy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _c = 0;
                  });
                },
                child: Container(
                  color: Color.fromARGB(255, 255, 255, 255),
                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      _ms[0],
                      style: TextStyle(
                        fontSize: _c == 0 ? 20 : 18,
                        color: _c == 0
                            ? Color.fromARGB(255, 1, 1, 1)
                            : Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _c = 1;
                  });
                },
                child: Container(color: Color.fromARGB(255, 255, 255, 255),
                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      _ms[1],
                      style: TextStyle(
                        fontSize: _c == 1 ? 20 : 18,
                        color: _c == 1
                            ? Color.fromARGB(255, 1, 1, 1)
                            : Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _c = 2;
                  });
                },
                child: Container(color: Color.fromARGB(255, 255, 255, 255),
                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      _ms[2],
                      style: TextStyle(
                        fontSize: _c == 2 ? 20 : 18,
                        color: _c == 2
                            ? Color.fromARGB(255, 1, 1, 1)
                            : Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 2,
                color: _c == 0 ? Colors.blue : Colors.black26,
                width: double.infinity,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: _c == 1 ? Colors.blue : Colors.black26,
                width: double.infinity,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: _c == 2 ? Colors.blue : Colors.black26,
                width: double.infinity,
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 3),
            color: Color.fromARGB(255, 250, 250, 250),
            width: double.infinity,
            child: getContent(_c),
          ),
        )
      ],
    );
  }
}
