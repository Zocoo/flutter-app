import 'package:flutter/material.dart';

import 'package:flutter_wyz/page/component/friend/friend_my.dart';
import 'package:flutter_wyz/page/component/friend/my_friend.dart';

class FriendAll extends StatefulWidget {
  FriendAll({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _FriendAll createState() => _FriendAll(id);
}

class _FriendAll extends State<FriendAll> {
  final List<int> _m = [0, 1];
  final List<String> _ms = ['他关注的', '关注他的'];
  int _c = 0;
  String _id = "";

  _FriendAll(id) {
//    setState(() {
    _id = id;
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('他的好友'),
      ),
      body: Column(
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
                  child: Container(
                    color: Color.fromARGB(255, 255, 255, 255),
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
            ],
          ),
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 250, 250, 250),
              width: double.infinity,
              child: _c == 0 ? MyFriend(id: _id) : FriendMy(id: _id),
            ),
          )
        ],
      ),
    );
  }
}
