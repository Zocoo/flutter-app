import 'package:flutter/material.dart';
//import 'package:qrscan/qrscan.dart' as scanner;
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:barcode_scan/barcode_scan.dart';
class Qrcode extends StatefulWidget {
  @override
  _QrcodeState createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  String _qrcode = '未扫码';

  @override
  Widget build(BuildContext context) {
//    scan() async {
//      bool res = await SimplePermissions.checkPermission(Permission.Camera);
//      print(res);
//      if (!res) {
//        await SimplePermissions.requestPermission(Permission.Camera);
//        res = await SimplePermissions.checkPermission(Permission.Camera);
//      }
//      print(res);
//      if (res) {
//        String result = await scanner.scan();
//        print(result);
//        if (!mounted) return;
//        setState(() {
//          _qrcode = result;
//        });
//      }
//    }

    scan() async {
      print('start qr code');
      try {
        String barcode = await BarcodeScanner.scan();
        setState(() {
          _qrcode = barcode;
        });
      } catch (e) {
        setState(() {
          _qrcode ='error';
        });
      }
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_qrcode),
            MaterialButton(
              color: Colors.blue,
              onPressed: scan,
              child: Text(
                "扫码",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
