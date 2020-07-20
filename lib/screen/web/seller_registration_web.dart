import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class SellerRegistrationWeb extends StatefulWidget {
  SellerRegistrationWeb({Key key}) : super(key: key);

  @override
  _SellerRegistrationWebState createState() => _SellerRegistrationWebState();
}

class _SellerRegistrationWebState extends State<SellerRegistrationWeb> {
  // Completer<WebViewController> _controller = Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);

    return WebviewScaffold(
      url: "https://uwlaamart.web.app/login",
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 1.0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              FlutterStatusbarcolor.setStatusBarColor(
                  Theme.of(context).primaryColor);
            },
          ),
          title: Text(
            'Seller Registration',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: ScreenUtil().setSp(55.0),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
    // Scaffold(
    //   appBar: PreferredSize(
    //     preferredSize: Size.fromHeight(50.0),
    //     child: AppBar(
    //       brightness: Brightness.light,
    //       iconTheme: IconThemeData(color: Colors.black),
    //       backgroundColor: Colors.white,
    //       elevation: 1.0,
    //       centerTitle: false,
    //       leading: IconButton(
    //         icon: Icon(Icons.arrow_back),
    //         onPressed: () {
    //           Navigator.pop(context);
    //           FlutterStatusbarcolor.setStatusBarColor(
    //               Theme.of(context).primaryColor);
    //         },
    //       ),
    //       title: Text(
    //         'Seller Registration',
    //         style: TextStyle(
    //           fontWeight: FontWeight.bold,
    //           color: Colors.black,
    //           fontSize: ScreenUtil().setSp(55.0),
    //           letterSpacing: 0.5,
    //         ),
    //       ),
    //     ),
    //   ),
    //   body:
    //   WebView(
    //     initialUrl: 'https://uwlaamart.web.app/login',
    //     javascriptMode: JavascriptMode.unrestricted,
    //     onWebViewCreated: (WebViewController webViewController) {
    //       _controller.complete(webViewController);
    //     },
    //   ),
    // );
  }
}
