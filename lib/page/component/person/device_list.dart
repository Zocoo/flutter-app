import 'package:flutter/material.dart';

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设备列表"),
      ),
      body: Container(
        child: Center(
          child: Text('设备列表'),
        ),
      ),
    );
  }
}
