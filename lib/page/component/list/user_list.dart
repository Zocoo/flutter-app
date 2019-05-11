import 'package:flutter/material.dart';
import 'package:flutter_wyz/page/pojo/user.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> _users = [
    User('吴易泽1', '10', '杭州'),
    User('吴易泽2', '10', '杭州'),
    User('吴易泽3', '10', '杭州'),
    User('吴易泽4', '10', '杭州'),
    User('吴易泽5', '10', '杭州'),
    User('吴易泽6', '10', '杭州'),
    User('吴易泽7', '10', '杭州'),
    User('吴易泽8', '10', '杭州'),
    User('吴易泽9', '10', '杭州'),
    User('吴易泽10', '10', '杭州')
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            return _displayUser(index);
          },
        ),
      ),
    );
  }

  Widget _displayUser(int index) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Card(
        child: Container(
          height: 80,
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
            bottom: 15.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(_users[index].name),
              Text(_users[index].age),
              Text(_users[index].address),
            ],
          ),
        ),
        margin: EdgeInsets.only(
          top: 0,
          left: 8,
          right: 8,
          bottom: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(0),
          ),
        ),
      ),
    );
  }
}
