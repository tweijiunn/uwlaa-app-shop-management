import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwlaa/screen/user_profile/new_business_address.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BusinessAddressScreen extends StatefulWidget {
  final String type;
  BusinessAddressScreen({Key key, @required this.type}) : super(key: key);

  @override
  _BusinessAddressScreenState createState() => _BusinessAddressScreenState();
}

class _BusinessAddressScreenState extends State<BusinessAddressScreen> {
  final RefreshController _refreshController = RefreshController();

  String shopId = "";
  List<Widget> _addressWidgetList = List<Widget>();

  YYDialog yyProgressDialogNoBody() {
    return YYDialog().build()
      ..width = 200
      ..borderRadius = 4.0
      ..circularProgress(
        padding: EdgeInsets.all(24.0),
        valueColor: Colors.orange[500],
      )
      ..barrierDismissible = false
      ..text(
        padding: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 12.0),
        text: "Loading...",
        alignment: Alignment.center,
        color: Colors.orange[500],
        fontSize: 18.0,
      );
  }

  initPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    shopId = prefs.getString('shop_id');
    setState(() {});
    var dialog = yyProgressDialogNoBody();
    _getAllAddresses(dialog);
  }

  Future<void> _getAllAddresses(YYDialog dialog) async {
    _addressWidgetList = [];
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/mobileGetBusinessAddresses";
    Map data = {"shop_id": shopId};
    var body = json.encode(data);
    dialog.show();
    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      dialog.dismiss();
      var resp = json.decode(response.body);
      setState(() {
        if (resp["status"] == "OK") {
          for (var item in resp["result"]) {
            String tag = "";
            if (item["default"]) {
              tag += "[Default] ";
            }
            if (item["pickup"]) {
              tag += "[Pickup] ";
            }
            if (item["return"]) {
              tag += "[Return] ";
            }
            String fullAddress = "";
            fullAddress +=
                item["detail_address"].toString().replaceAll("\\n", "\n") +
                    "\n";
            fullAddress += item["area"] + "\n";
            fullAddress += item["postal_code"] + ", " + item["state"];
            _addressWidgetList.add(
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFEEEEEE),
                      width: 1.0,
                    ),
                  ),
                ),
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(top: 7.0),
                child: InkWell(
                  onTap: () {
                    print(item["id"]);
                    if (widget.type == "select") {
                      var addressInfo = {
                        "new_address_selected": true,
                        "full_name": item["full_name"],
                        "area": item["area"],
                        "state": item["state"],
                        "detail_address": item["detail_address"],
                        "phone_number": item["phone_number"],
                        "postal_code": item["postal_code"],
                      };
                      Navigator.pop(context, json.encode(addressInfo));
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            item["full_name"].toString().length > 15
                                ? item["full_name"].toString().replaceRange(15,
                                    item["full_name"].toString().length, "...")
                                : item["full_name"].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            fullAddress,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      });
    }).catchError((onError) {
      dialog.dismiss();
      print(onError.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      initPreferences();
    });
  }

  Future<bool> _onBackPressed() async {
    if (widget.type == "select") {
      var addressInfo = {
        "new_address_selected": false,
      };
      Navigator.pop(context, json.encode(addressInfo));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    YYDialog.init(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
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
                if (widget.type == "select") {
                  var addressInfo = {
                    "new_address_selected": false,
                  };
                  Navigator.pop(context, json.encode(addressInfo));
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              widget.type == "select" ? "Select Address" : "Business Address",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: ScreenUtil().setSp(
                  50.0,
                ),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          header: MaterialClassicHeader(
            color: Colors.orange,
            backgroundColor: Colors.white,
          ),
          onRefresh: () {
            _refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Visibility(
                  visible: _addressWidgetList.length > 0,
                  child: Column(
                    children: _addressWidgetList,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Visibility(
                  visible: widget.type == "create",
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 3.0,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(top: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewBusinessAddress(
                              shopId: shopId,
                              isFirstAddress:
                                  _addressWidgetList.length > 0 ? false : true,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Add a new address",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(45.0),
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.add,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
