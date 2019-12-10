import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_wyz/config/config.dart';
import 'package:flutter_wyz/page/login/login.dart';
import 'package:flutter_wyz/util/Toast.dart';
import 'package:flutter_wyz/util/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';

class Version extends StatefulWidget {
  @override
  _VersionState createState() => _VersionState();
}

class _VersionState extends State<Version> with SingleTickerProviderStateMixin {
  String versionInfo = "检查版本中...";
  AnimationController _controller;
  Animation _animation;
  String _url = "";
  String _fileName = "";
  bool _a_status = false;
  bool _v_status = false;
  BuildContext _b = null;
  Timer _ctXl;
  @override
  void dispose() {
    if (null != _ctXl) _ctXl.cancel();
    super.dispose();
  }
  _ctXlGx() async {
    checkVersion();
    _ctXl = Timer.periodic(new Duration(milliseconds: 6000), (timer) {
      checkVersion();
    });
  }
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        seconds: 1,
      ),
      vsync: this,
    );
    _animation = Tween(begin: 0, end: 1).animate(_controller);

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_v_status)
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Login()),
              (route) => route == null);
        else {
          _b = context;
          _a_status = true;
        }
      }
    });

    _controller.forward();
  }

  _VersionState() {
    _ctXlGx();
  }

  notUpdate() {
    if (_a_status)
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => Login()),
          (route) => route == null);
    else
      Navigator.of(context).pop();
  }

  nowUpdate() async {
    Navigator.of(context).pop();
    print(Platform.isAndroid);
    print(Platform.isIOS);
    print(Platform.isMacOS);
    if (Platform.isAndroid) {
      bool res = await SimplePermissions.checkPermission(
          Permission.WriteExternalStorage);
      print(res);
      if (!res) {
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
      }
      print("xxxxxxxxxxxxxx");
      if (true) {
        try {
          var directory = await getExternalStorageDirectory();
          print(directory.path);
          FlutterDownloader.initialize();
          FlutterDownloader.registerCallback((id, status, progress) {
            print(
                'Download task ($id) is in status ($status) and process ($progress)');
            if (status == DownloadTaskStatus.complete) {
              print(directory.path);
              print(_fileName);
              OpenFile.open(directory.path + "/" + _fileName);
              FlutterDownloader.open(taskId: id);
            }
          });
          final taskId = await FlutterDownloader.enqueue(
//          url: "https://assets-store-cdn.48lu.cn/assets-store/c3ba1aa37bdbb78386416c703ee7eb14.apk",
//          url: "https://assets-store-cdn.48lu.cn/assets-store/395845999373aa6588c7659d54a92b0c.pdf",
//          url: "https://assets-store-cdn.48lu.cn/assets-store/6845eee23f7ec0036eed7935f827f9e5.jpg",
            url: _url,
            savedDir: directory.path,
            showNotification:
                true, // show download progress in status bar (for Android)
            openFileFromNotification:
                true, // click on notification to open downloaded file (for Android)
          );
        } catch (e) {
          Toast.toast(context, '更新失败，请去官网下载！');
          notUpdate();
        }
        final tasks = await FlutterDownloader.loadTasks();
      } else {
        notUpdate();
      }
    } else if (Platform.isIOS) {
      notUpdate();
    }
  }

  Widget choiceUpdate(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('提示'),
          content: SingleChildScrollView(
            child: Text('发现新版本，需要更新吗？'),
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    notUpdate();
                  },
                ),
                FlatButton(
                  child: Text('确定'),
                  onPressed: () {
                    nowUpdate();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  checkVersion() async {
    await LocalStorage().set("tz101", 'no');
    var url = Config().host + '/config/selectById?id=1';
    var downloadUrl = "";
    var fileName = "";
    int result;
    try {
      final http.Response response = await http.get(url);
      var data = json.decode(response.body);
      result = data['data']['code'];
      print(result);
      downloadUrl = data['data']['content'];
      print(downloadUrl);
      if (downloadUrl.length > 10) {
        List<String> list = downloadUrl.split("/");
        fileName = list[list.length - 1];
      }
      _fileName = fileName;
      _url = downloadUrl;
//      PackageInfo packageInfo = await PackageInfo.fromPlatform();
//      String version = packageInfo.version;
//      print(version);
      if (Config().version < result) {
        choiceUpdate(context);
        _ctXl.cancel();
      } else {
        if (_a_status)
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Login()),
              (route) => route == null);
        else
          _v_status = true;
      }
    } catch (exception) {
      result = -1;
    }
    if (!mounted) return;
    setState(() {
      versionInfo = result.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Image.asset(
        'img/back.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
