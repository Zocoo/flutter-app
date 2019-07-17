import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_wyz/config/all_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/content/airplay_screen.dart';
import 'package:flutter_wyz/page/content/email_screen.dart';
import 'package:flutter_wyz/page/content/home_screen.dart';
import 'package:flutter_wyz/page/content/pages_screen.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
//import 'package:local_notifications/local_notifications.dart'; //android only

class Index extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<Index> with WidgetsBindingObserver {

  String debugLable = 'Unknown';
  final JPush jpush = new JPush();
  String tsinit = "no";
  Future<void> initPlatformState() async {
    String platformVersion;

    String id = await LocalStorage().get("userId");
    print('-----------fff------------->>'+id);
    jpush.setAlias(id);
    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      setState(() {
        debugLable = "flutter getRegistrationID: $rid";
        print('000000000000000000000>>>'+rid);
      });
    });

    jpush.setup(
      appKey: "ce53da8fe966805f893421bb",
      channel: "theChannel",
      production: false,
      debug: true,
    );
    jpush.applyPushAuthority(new NotificationSettingsIOS(
        sound: true,
        alert: true,
        badge: true));

    try {

      jpush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("flutter onReceiveNotification: $message");
          setState(() {
            debugLable = "flutter onReceiveNotification: $message";
          });
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          print("flutter onOpenNotification: $message");
          setState(() {
            debugLable = "flutter onOpenNotification: $message";
          });
        },
        onReceiveMessage: (Map<String, dynamic> message) async {
          print("flutter onReceiveMessage: $message");
          setState(() {
            debugLable = "flutter onReceiveMessage: $message";
          });
        },
      );

    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      debugLable = platformVersion;
    });
  }
  final _bottomNavigationColor = Colors.blue;
  int _currentIndex = 0;
  List<Widget> list = List();

  IndexState() {
    initLabel();
    _idAndToken();
    _tgo();
  }

  Icon _msg = Icon(
    Icons.chat,
    color: Colors.blue,
  );

  Timer _ct;

  bool _onNew = false;

  String _token = "";

  String _id = "";

  static int _idX = 0;

  _idAndToken() async {
    _id = await LocalStorage().get("userId");
    _token = await LocalStorage().get("token");
  }

  void _tgo() {
    _ct = Timer.periodic(new Duration(seconds: 6), (timer) {
      if (!_onNew) {
        _chatNew();
      }
    });
  }

// android only
//  static _onNotificationClick(String payload) {
//    LocalNotifications.removeNotification(_idX);
//    print("消息已被阅读");
//  }
//
//  static const AndroidNotificationChannel channel =
//      const AndroidNotificationChannel(
//          id: 'default_notification',
//          name: 'Default',
//          description: 'Grant this app the ability to show notifications',
//          importance: AndroidNotificationImportance.HIGH);

  _chatNew() async {
    try {
      String url =
          Config().host + "/chat/newMsg?userId=" + _id + "&token=" + _token;
      final http.Response response = await http.get(url);
      Utf8Decoder utf8decoder = new Utf8Decoder();
      Map data = json.decode(utf8decoder.convert(response.bodyBytes));
//    print(data);
      var result = data['code'];
      if (result == 0) {
        await LocalStorage().set("havaNewMsg", '1');
        if (!Platform.isAndroid) {
        } else {
          var tz = await LocalStorage().get("tz101");
          if (tz == 'yes') {
            _idX++;

            //android only
//            await LocalNotifications.createAndroidNotificationChannel(
//                channel: channel);
//            await LocalNotifications.createNotification(
//              title: "遥不可及",
//              content: "您有新消息来了！",
//              id: _idX,
//              androidSettings: new AndroidSettings(channel: channel),
//              onNotificationClick: NotificationAction(
//                  actionText: "",
//                  callback: _onNotificationClick,
//                  payload: "接收成功！"),
//            );
          }
        }
        setState(() {
          _msg = Icon(
            Icons.speaker_notes,
            color: Colors.redAccent,
          );
          _onNew = false;
        });
      }
    } catch (e) {
      print('new msg get error');
    }
  }

  initLabel() async {
    String l = await LocalStorage().get("labelId");
    if (l != null && l.length == 1 && l != '0') {
      setState(() {
        _currentIndex = int.parse(l);
      });
      await LocalStorage().set("labelId", '0');
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    list
      ..add(HomeScreen())
      ..add(EmailScreen())
      ..add(PagesScreen())
      ..add(AirPlayScreen());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: list[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: _bottomNavigationColor,
                ),
                title: Text(
                  '主页',
                  style: TextStyle(color: _bottomNavigationColor),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.people,
                  color: _bottomNavigationColor,
                ),
                title: Text(
                  '好友',
                  style: TextStyle(color: _bottomNavigationColor),
                )),
            BottomNavigationBarItem(
              icon: _msg,
              title: Text(
                '消息',
                style: TextStyle(color: _bottomNavigationColor),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: _bottomNavigationColor,
              ),
              title: Text(
                '我的',
                style: TextStyle(color: _bottomNavigationColor),
              ),
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
              if (index == 2) {
                _msg = Icon(
                  Icons.chat,
                  color: Colors.blue,
                );
                _onNew = false;
              }
            });
          },
          type: BottomNavigationBarType.shifting,
        ),
      ),
      onWillPop: () {
        print("---------------------------------------------");
        if (Platform.isAndroid) backDeskTop();
      },
    );
  }

  static const String CHANNEL = "android/back/desktop";

  //设置回退到手机桌面
  static Future<bool> backDeskTop() async {
    final platform = MethodChannel(CHANNEL);
    //通知安卓返回,到手机桌面
    try {
      final bool out = await platform.invokeMethod('backDesktop');
      if (out) debugPrint('返回到桌面');
    } on PlatformException catch (e) {
      debugPrint("通信失败(设置回退到安卓手机桌面:设置失败)");
      print(e.toString());
    }
    return Future.value(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    setState(() {
      _notification = state;
      print(_notification);
      if (_notification == AppLifecycleState.paused) {
        print("xxxx1");
        _setN();
      }
      if (_notification == AppLifecycleState.resumed) {
        print("xxxxxxxxxxxx");
        _setNotN();
      }
    });
    super.didChangeAppLifecycleState(state);
  }

  _setNotN() async {
    await LocalStorage().set("tz101", 'no');
    jpush.stopPush();
  }

  _setN() async {
    await LocalStorage().set("tz101", 'yes');
    if (tsinit == 'no') {
       jpush.clearAllNotifications();
       jpush.resumePush();
      initPlatformState();
    }else{
      tsinit = 'yes';
       jpush.clearAllNotifications();
       jpush.resumePush();
      initPlatformState();
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;
}
