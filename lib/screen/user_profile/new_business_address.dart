import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:uwlaa/util/general.dart';
import 'package:http/http.dart' as http;

class NewBusinessAddress extends StatefulWidget {
  final bool isFirstAddress;
  final String shopId;

  NewBusinessAddress({
    Key key,
    @required this.isFirstAddress,
    @required this.shopId,
  }) : super(key: key);

  @override
  _NewBusinessAddressState createState() => _NewBusinessAddressState();
}

class _NewBusinessAddressState extends State<NewBusinessAddress> {
  String _state = "WP Kuala Lumpur";
  String _area = "Set Area";
  String _fullName = "";
  String _phoneNumber = "";
  String _postalCode = "";
  String _detailAddress = "";
  bool _defaultAddressSwitch = true;
  bool _pickUpAddressSwitch = true;
  bool _returnAddressSwitch = true;
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();
  TextEditingController _detailAddressController = TextEditingController();

  final FocusNode _nodeFullName = FocusNode();
  final FocusNode _nodePhoneNumber = FocusNode();
  final FocusNode _nodePostalCode = FocusNode();
  final FocusNode _nodeDetailAddress = FocusNode();

  List<Widget> _stateList = List<Widget>();
  List<Widget> _areaList = List<Widget>();

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

  String _validateForm() {
    _fullName = _fullNameController.text;
    _phoneNumber = _phoneNumberController.text;
    _postalCode = _postalCodeController.text;
    _detailAddress = _detailAddressController.text;
    print(_fullName.runtimeType.toString());
    if (_fullName == "") {
      return "Full name can't be empty";
    } else if (_fullName.length < 5) {
      return "Full name is too short";
    } else if (_phoneNumber == "") {
      return "Phone number can't be empty";
    } else if (!GeneralUtility.isNumeric(_phoneNumber) ||
        _phoneNumber.length < 10) {
      return "Invalid Phone Number";
    } else if (_area == "Set Area") {
      return "Area can't be empty";
    } else if (!GeneralUtility.isNumeric(_postalCode) ||
        _postalCode.length != 5) {
      return "Invalid Postal Code";
    } else if (_detailAddress == "") {
      return "Detailed address can't be empty";
    } else if (_detailAddress.length < 5) {
      return "Detailed address is too short";
    } else if (!_pickUpAddressSwitch &&
        !_defaultAddressSwitch &&
        !_returnAddressSwitch) {
      return "At least an option from default, pickup or return must be selected";
    } else {
      return "OK";
    }
  }

  Future<void> _submitBusinessAddress(YYDialog dialog) async {
    String validateResult = _validateForm();
    if (validateResult == "OK") {
      dialog.show();
      var url =
          "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/mobileCreateNewBusinessAddress";
      Map data = {
        "shop_id": widget.shopId,
        "full_name": _fullName,
        "phone_number": _phoneNumber,
        "state": _state,
        "area": _area,
        "detail_address": _detailAddress,
        "postal_code": _postalCode,
        "isDefaultAddress": _defaultAddressSwitch,
        "isPickupAddress": _pickUpAddressSwitch,
        "isReturnAddress": _returnAddressSwitch
      };
      var body = json.encode(data);
      http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .then((response) {
        dialog.dismiss();
        var resp = json.decode(response.body);
        if (resp["status"] == "OK") {
          Fluttertoast.showToast(
            msg: "Added address",
            fontSize: ScreenUtil().setSp(40.0),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Something went wrong",
            fontSize: ScreenUtil().setSp(40.0),
          );
        }
      }).catchError((onError) {
        dialog.dismiss();
        Fluttertoast.showToast(
          msg: "Something went wrong",
          fontSize: ScreenUtil().setSp(40.0),
        );
        print(onError.toString());
      });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                validateResult,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(
                    50.0,
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(50.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  void _createArea(List<dynamic> areas) {
    _areaList = [];
    for (var item in areas) {
      _areaList.add(
        ListTile(
          title: Text(
            item.toString(),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(48.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _area = item.toString();
            });
          },
        ),
      );
    }
  }

  Widget _createState(String state) {
    return ListTile(
      title: Text(
        state,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(48.0),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _getAreaList();
        setState(() {
          _area = "Set Area";
          _state = state;
        });
      },
    );
  }

  Future<void> _getStateList() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/malaysia_state_area.json");
    final jsonResult = json.decode(data);
    for (var item in jsonResult) {
      _stateList.add(_createState(item["state"]));
    }
  }

  Future<void> _getAreaList() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/malaysia_state_area.json");
    final jsonResult = json.decode(data);
    for (var item in jsonResult) {
      if (item["state"] == _state) {
        _createArea(item["areas"]);
      }
    }
  }

  void _showStateList() {
    showModalBottomSheet(
      // expand: true,
      context: context,
      // backgroundColor: Colors.transparent,
      builder: (context) {
        return ListView(
          children: _stateList,
        );
      },
    );
  }

  void _showAreaList() {
    showModalBottomSheet(
      // expand: true,
      context: context,
      // backgroundColor: Colors.transparent,
      builder: (context) {
        return ListView(
          children: _areaList,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getStateList();
    _getAreaList();
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    YYDialog.init(context);
    return Scaffold(
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
            "New Business Address",
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Form(
              child: Column(
                children: <Widget>[
                  // Full Name Field
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: TextFormField(
                              focusNode: _nodeFullName,
                              controller: _fullNameController,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40.0),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                isDense: false,
                                border: InputBorder.none,
                                hintText: "Set Full Name",
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                _nodeFullName.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_nodePhoneNumber);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Phone Number Field
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "Phone Number",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: TextFormField(
                              focusNode: _nodePhoneNumber,
                              controller: _phoneNumberController,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40.0),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                isDense: false,
                                border: InputBorder.none,
                                hintText: "Set Phone Number",
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                _nodePhoneNumber.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_nodePostalCode);
                              },
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // State Field
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "State",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    _showStateList();
                                  },
                                  child: Container(
                                    child: Text(
                                      _state,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40.0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    print("Set State");
                                    _showStateList();
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Area Field
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "Area",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    print("Set Area");
                                    _showAreaList();
                                  },
                                  child: Container(
                                    child: Text(
                                      _area,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40.0),
                                        fontWeight: FontWeight.w500,
                                        color: _area == "Set Area"
                                            ? Color(0xFF757575)
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    print("Set Area");
                                    _showAreaList();
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Postal Code Field
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "Postal Code",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: TextFormField(
                              focusNode: _nodePostalCode,
                              controller: _postalCodeController,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40.0),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                isDense: false,
                                border: InputBorder.none,
                                hintText: "Set Postal Code",
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                _nodePostalCode.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_nodeDetailAddress);
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Detail Address Field
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
                    padding: EdgeInsets.only(
                      top: 10.0,
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            "Detailed Address",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            "Unit number, house number, building, street name",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(35.0),
                              color: Color(0xFF757575),
                            ),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            focusNode: _nodeDetailAddress,
                            controller: _detailAddressController,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              isDense: false,
                              border: InputBorder.none,
                              hintText: "Set Detailed Address",
                            ),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  //Default address switch
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "Set As Default Address",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Switch(
                                value: _defaultAddressSwitch,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    if (widget.isFirstAddress) {
                                      _defaultAddressSwitch = true;
                                    } else {
                                      _defaultAddressSwitch = value;
                                    }
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                  //Pickup address switch
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "Set As Pickup Address",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Switch(
                                value: _pickUpAddressSwitch,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    if (widget.isFirstAddress) {
                                      _pickUpAddressSwitch = true;
                                    } else {
                                      _pickUpAddressSwitch = value;
                                    }
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                  //Return address switch
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
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Text(
                            "Set As Return Address",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Switch(
                              value: _returnAddressSwitch,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  if (widget.isFirstAddress) {
                                    _returnAddressSwitch = true;
                                  } else {
                                    _returnAddressSwitch = value;
                                  }
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(5.0),
        child: RaisedButton(
          elevation: 0.0,
          onPressed: () {
            var dialog = yyProgressDialogNoBody();
            _submitBusinessAddress(dialog);
          },
          color: Theme.of(context).primaryColor,
          child: Text(
            "SUBMIT",
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
