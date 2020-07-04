import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:uwlaa/model/wholesale_cart.dart';

class BusinessCart extends StatefulWidget {
  BusinessCart({Key key}) : super(key: key);

  @override
  _BusinessCartState createState() => _BusinessCartState();
}

class _BusinessCartState extends State<BusinessCart> {
  List<WholesaleShopCart> _cartList = List<WholesaleShopCart>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 1.0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Wholesale Cart',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: ScreenUtil().setSp(55.0),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[],
      ),
    );
  }
}
