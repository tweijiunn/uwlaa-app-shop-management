import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'package:uwlaa/model/business_product.dart';
import 'package:uwlaa/model/http_request_response.dart';
import 'package:uwlaa/model/slider.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uwlaa/screen/business_cart.dart';
import 'package:http/http.dart' as http;

class BusinessBusinessProductDetail extends StatefulWidget {
  final String productName;
  final String displayPrice;
  final String isPreOrder;
  final bool isVariationMode;
  final bool isVariation2Enabled;
  final String coverImage;
  final String productDescription;
  final int minimumLot;
  var productRating;
  var productPrice;
  final String productId;
  final bool isFavourite;
  final String shopName;
  var shopRating;
  final String shopLogo;
  final int unitSold;
  final List<dynamic> productImages;
  final List<ExtraQuestion> extraQuestionForm;
  final List<WholesaleDetail> wholesaleDetails;
  final List<Variations> variations;
  final int daysToShip;
  final String productType;
  final String halalCertImage;
  final String halalIssueCountry;
  final int numberOfProduct;
  final int totalStock;
  final String shopOwnerId;

  BusinessBusinessProductDetail({
    Key key,
    @required this.productName,
    @required this.displayPrice,
    @required this.isPreOrder,
    @required this.isVariationMode,
    @required this.isVariation2Enabled,
    @required this.coverImage,
    @required this.productDescription,
    @required this.minimumLot,
    @required this.productRating,
    @required this.productPrice,
    @required this.productId,
    @required this.isFavourite,
    @required this.shopName,
    @required this.shopRating,
    @required this.shopLogo,
    @required this.unitSold,
    @required this.productImages,
    @required this.extraQuestionForm,
    @required this.wholesaleDetails,
    @required this.variations,
    @required this.daysToShip,
    @required this.productType,
    @required this.halalCertImage,
    @required this.halalIssueCountry,
    @required this.numberOfProduct,
    @required this.totalStock,
    @required this.shopOwnerId,
  }) : super(key: key);

  @override
  _BusinessBusinessProductDetailState createState() =>
      _BusinessBusinessProductDetailState();
}

class _BusinessBusinessProductDetailState
    extends State<BusinessBusinessProductDetail>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<prefix0.Slider> _sliderList = [];

  List<Variations> _variationListV2 = List<Variations>();

  void _initVariation() {
    for (var item in widget.variations) {
      _variationListV2.add(item);
    }
  }

  double _userRating = 3.5;
  int _howManyReview = 40;
  int _numberOfVariation = 0;
  String _shopAddressState = "Sri Petaling, Kuala Lumpur";
  List<String> _variationImageList = [];
  int _totalAmountSelected = 0;
  double _totalAmountPrice = 0;

  Widget _buildVariationImage(String imageUrl, int option) {
    if (option == 1) {
      return Flexible(
        flex: 1,
        child: Container(
          // height: 50.0,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          margin: EdgeInsets.all(4.0),
          child: Image(
            image: NetworkImage(imageUrl),
          ),
        ),
      );
    } else if (option == 2) {
      return Flexible(
        flex: 1,
        child: Container(
          margin: EdgeInsets.all(4.0),
          child: Stack(
            children: <Widget>[
              Image(
                color: Colors.black45,
                image: NetworkImage(imageUrl),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Text(
                    (_numberOfVariation - 5).toString() + " more",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(35.0),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
    return null;
  }

  List<Widget> _variationList = List<Widget>();

  void _buildVariationImageList() {
    int difference = 6 - _variationImageList.length;
    if (difference == 0) {
      for (var item in _variationImageList) {
        _variationList.add(_buildVariationImage(item, 1));
      }
    } else if (difference > 0) {
      for (var item in _variationImageList) {
        _variationList.add(_buildVariationImage(item, 1));
      }
      for (int i = 0; i < difference; i++) {
        _variationList.add(Flexible(
          flex: 1,
          child: Container(),
        ));
      }
    } else {
      for (int i = 0; i < 5; i++) {
        _variationList.add(_buildVariationImage(_variationImageList[i], 1));
      }
      _variationList.add(_buildVariationImage(_variationImageList[5], 2));
    }
  }

  Future<bool> _onFavouriteButtonTapped(bool isLiked) async {
    print(isLiked);
    return !isLiked;
  }

  void _addSlider() {
    _sliderList.add(prefix0.Slider(
      imageUrl: widget.coverImage,
      linkTo: widget.coverImage,
    ));
    // Add product images to slider
    for (var item in widget.productImages) {
      _sliderList.add(prefix0.Slider(
        imageUrl: item,
        linkTo: item,
      ));
    }
    // Add variation images
    String tempTag = "";
    for (var item in widget.variations) {
      if (tempTag == "") {
        _numberOfVariation++;
        tempTag = item.tag;
        _sliderList.add(prefix0.Slider(
          imageUrl: item.imageUrl,
          linkTo: item.imageUrl,
        ));
        _variationImageList.add(item.imageUrl);
      } else if (tempTag != item.tag) {
        tempTag = item.tag;
        _numberOfVariation++;
        _sliderList.add(prefix0.Slider(
          imageUrl: item.imageUrl,
          linkTo: item.imageUrl,
        ));
        _variationImageList.add(item.imageUrl);
      }
    }
  }

  List<Widget> _createExtraForm() {
    List<Widget> extraForms = List<Widget>();
    // print(widget.productDescription.replaceAll('\\n', '\n'));
    extraForms.add(
      Container(
        padding: EdgeInsets.all(15.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Product Details",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: ScreenUtil().setSp(45.0),
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
    extraForms.add(
      Divider(
        height: 3.0,
      ),
    );
    for (var item in widget.extraQuestionForm) {
      if (item.answer != "") {
        extraForms.add(
          Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  flex: 3,
                  child: Container(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(45.0),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 7,
                  child: Container(
                    child: Text(
                      item.answer,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(45.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    extraForms.add(
      Divider(
        height: 3.0,
      ),
    );
    extraForms.add(
      Container(
        padding: EdgeInsets.all(15.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.productDescription.replaceAll('\\n', '\n'),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(45.0),
            ),
          ),
        ),
      ),
    );
    return extraForms;
  }

  String _variationDefaultImage = "";

  List<Widget> _initVariationTab() {
    List<Widget> tabList = List<Widget>();
    if (widget.isVariation2Enabled) {
      String tempTag = "";
      for (var item in widget.variations) {
        if (tempTag == "") {
          tempTag = item.tag;
          tabList.add(
            Tab(
              text: item.variationName1,
            ),
          );
        } else if (tempTag != item.tag) {
          tempTag = item.tag;
          tabList.add(
            Tab(
              text: item.variationName1,
            ),
          );
        }
      }
    }
    return tabList;
  }

  int _quantityDefault = 0;

  List<Widget> _initTabView(StateSetter mystate) {
    List<Widget> tabList = List<Widget>();
    List<Widget> tileList = List<Widget>();
    if (!widget.isVariationMode) {
      // Produce list tile
      tileList.add(
        ListTile(
          leading: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    "Default",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(40.0),
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    "RM" + widget.productPrice.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(35.0),
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
          title: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    "Stock: " + widget.totalStock.toString(),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(35.0),
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  child: SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: Icon(
                        Icons.remove,
                        size: 12.0,
                      ),
                      onPressed: _quantityDefault == 0
                          ? null
                          : () {
                              mystate(() {
                                _quantityDefault -= widget.minimumLot;
                                _totalAmountSelected -= widget.minimumLot;
                                if (widget.wholesaleDetails.length > 1 &&
                                    _totalAmountSelected > 0) {
                                  for (int i = 0;
                                      i < widget.wholesaleDetails.length;
                                      i++) {
                                    if (i <
                                        widget.wholesaleDetails.length - 1) {
                                      if (_totalAmountSelected >=
                                              widget.wholesaleDetails[i].min &&
                                          _totalAmountSelected <=
                                              widget.wholesaleDetails[i].max) {
                                        _totalAmountPrice =
                                            _totalAmountSelected *
                                                double.parse(widget
                                                    .wholesaleDetails[i].price
                                                    .toString());
                                        return;
                                      }
                                    } else {
                                      if (_totalAmountSelected >=
                                          widget.wholesaleDetails[i].min) {
                                        _totalAmountPrice =
                                            _totalAmountSelected *
                                                double.parse(widget
                                                    .wholesaleDetails[i].price
                                                    .toString());
                                        return;
                                      }
                                    }
                                  }
                                } else {
                                  _totalAmountPrice = _totalAmountSelected *
                                      widget.productPrice;
                                }
                              });
                            },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  child: SizedBox(
                    height: 30.0,
                    width: 60.0,
                    child: Container(
                      child: Center(
                        child: Text(
                          _quantityDefault.toString(),
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(40.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  child: SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: Icon(
                        Icons.add,
                        size: 12.0,
                      ),
                      onPressed: _quantityDefault == widget.totalStock ||
                              _quantityDefault + widget.minimumLot >
                                  widget.totalStock
                          ? null
                          : () {
                              print(widget.productId);
                              mystate(() {
                                _quantityDefault += widget.minimumLot;
                                _totalAmountSelected += widget.minimumLot;
                                if (widget.wholesaleDetails.length > 1) {
                                  for (int i = 0;
                                      i < widget.wholesaleDetails.length;
                                      i++) {
                                    if (i <
                                        widget.wholesaleDetails.length - 1) {
                                      if (_totalAmountSelected >=
                                              widget.wholesaleDetails[i].min &&
                                          _totalAmountSelected <=
                                              widget.wholesaleDetails[i].max) {
                                        _totalAmountPrice =
                                            _totalAmountSelected *
                                                double.parse(widget
                                                    .wholesaleDetails[i].price
                                                    .toString());
                                        return;
                                      }
                                    } else {
                                      if (_totalAmountSelected >=
                                          widget.wholesaleDetails[i].min) {
                                        _totalAmountPrice =
                                            _totalAmountSelected *
                                                double.parse(widget
                                                    .wholesaleDetails[i].price
                                                    .toString());
                                        return;
                                      }
                                    }
                                  }
                                } else {
                                  _totalAmountPrice = _totalAmountSelected *
                                      widget.productPrice;
                                }
                              });
                            },
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: null,
        ),
      );
      tabList.add(
        ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: tileList,
          ).toList(),
        ),
      );
    } else if (widget.isVariationMode && !widget.isVariation2Enabled) {
      for (var item in _variationListV2) {
        tileList.add(
          ListTile(
            leading: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      item.variationName1,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(40.0),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      "RM" + item.price.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(35.0),
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
            ),
            title: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Text(
                      "Stock: " + item.stock.toString(),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(35.0),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                    child: SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(
                          Icons.remove,
                          size: 12.0,
                        ),
                        onPressed: item.quantity == 0
                            ? null
                            : () {
                                mystate(() {
                                  _variationDefaultImage = item.imageUrl;
                                  item.quantity -= widget.minimumLot;
                                  _totalAmountSelected -= widget.minimumLot;
                                  _totalAmountPrice = 0;
                                  for (var item in _variationListV2) {
                                    if (widget.wholesaleDetails.length > 1 &&
                                        _totalAmountSelected > 0) {
                                      for (int i = 0;
                                          i < widget.wholesaleDetails.length;
                                          i++) {
                                        if (i <
                                            widget.wholesaleDetails.length -
                                                1) {
                                          if (_totalAmountSelected >=
                                                  widget.wholesaleDetails[i]
                                                      .min &&
                                              _totalAmountSelected <=
                                                  widget.wholesaleDetails[i]
                                                      .max) {
                                            _totalAmountPrice =
                                                _totalAmountSelected *
                                                    double.parse(widget
                                                        .wholesaleDetails[i]
                                                        .price
                                                        .toString());
                                            return;
                                          }
                                        } else {
                                          if (_totalAmountSelected >=
                                              widget.wholesaleDetails[i].min) {
                                            _totalAmountPrice =
                                                _totalAmountSelected *
                                                    double.parse(widget
                                                        .wholesaleDetails[i]
                                                        .price
                                                        .toString());
                                            return;
                                          }
                                        }
                                      }
                                    } else {
                                      _totalAmountPrice +=
                                          item.quantity * item.price;
                                    }
                                  }
                                });
                              },
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                    child: SizedBox(
                      height: 30.0,
                      width: 60.0,
                      child: Container(
                        child: Center(
                          child: Text(
                            item.quantity.toString(),
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(40.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                    child: SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(
                          Icons.add,
                          size: 12.0,
                        ),
                        onPressed: _quantityDefault == item.stock ||
                                item.quantity + widget.minimumLot > item.stock
                            ? null
                            : () {
                                mystate(() {
                                  _variationDefaultImage = item.imageUrl;
                                  item.quantity += widget.minimumLot;
                                  _totalAmountSelected += widget.minimumLot;
                                  _totalAmountPrice = 0;
                                  for (var item in _variationListV2) {
                                    if (widget.wholesaleDetails.length > 1) {
                                      for (int i = 0;
                                          i < widget.wholesaleDetails.length;
                                          i++) {
                                        if (i <
                                            widget.wholesaleDetails.length -
                                                1) {
                                          if (_totalAmountSelected >=
                                                  widget.wholesaleDetails[i]
                                                      .min &&
                                              _totalAmountSelected <=
                                                  widget.wholesaleDetails[i]
                                                      .max) {
                                            _totalAmountPrice =
                                                _totalAmountSelected *
                                                    double.parse(widget
                                                        .wholesaleDetails[i]
                                                        .price
                                                        .toString());
                                            return;
                                          }
                                        } else {
                                          if (_totalAmountSelected >=
                                              widget.wholesaleDetails[i].min) {
                                            _totalAmountPrice =
                                                _totalAmountSelected *
                                                    double.parse(widget
                                                        .wholesaleDetails[i]
                                                        .price
                                                        .toString());
                                            return;
                                          }
                                        }
                                      }
                                    } else {
                                      _totalAmountPrice +=
                                          item.quantity * item.price;
                                    }
                                  }
                                });
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: null,
          ),
        );
      }
      tabList.add(
        ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: tileList,
          ).toList(),
        ),
      );
    } else if (widget.isVariation2Enabled) {
      var tempTag = "";
      var counter = 0;
      for (var item in _variationListV2) {
        if (tempTag == "") {
          tempTag = item.tag;
          tileList.add(
            ListTile(
              leading: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        item.variationName2,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "RM" + item.price.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(35.0),
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              title: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Text(
                        "Stock: " + item.stock.toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(35.0),
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.remove,
                            size: 12.0,
                          ),
                          onPressed: item.quantity == 0
                              ? null
                              : () {
                                  mystate(() {
                                    _variationDefaultImage = item.imageUrl;
                                    item.quantity -= widget.minimumLot;
                                    _totalAmountSelected -= widget.minimumLot;
                                    _totalAmountPrice = 0;
                                    for (var item in _variationListV2) {
                                      if (widget.wholesaleDetails.length > 1 &&
                                          _totalAmountSelected > 0) {
                                        for (int i = 0;
                                            i < widget.wholesaleDetails.length;
                                            i++) {
                                          if (i <
                                              widget.wholesaleDetails.length -
                                                  1) {
                                            if (_totalAmountSelected >=
                                                    widget.wholesaleDetails[i]
                                                        .min &&
                                                _totalAmountSelected <=
                                                    widget.wholesaleDetails[i]
                                                        .max) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          } else {
                                            if (_totalAmountSelected >=
                                                widget
                                                    .wholesaleDetails[i].min) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          }
                                        }
                                      } else {
                                        _totalAmountPrice +=
                                            item.quantity * item.price;
                                      }
                                    }
                                  });
                                },
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        height: 30.0,
                        width: 60.0,
                        child: Container(
                          child: Center(
                            child: Text(
                              item.quantity.toString(),
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.add,
                            size: 12.0,
                          ),
                          onPressed: _quantityDefault == item.stock ||
                                  item.quantity + widget.minimumLot > item.stock
                              ? null
                              : () {
                                  mystate(() {
                                    _variationDefaultImage = item.imageUrl;
                                    item.quantity += widget.minimumLot;
                                    _totalAmountSelected += widget.minimumLot;
                                    _totalAmountPrice = 0;
                                    for (var item in _variationListV2) {
                                      if (widget.wholesaleDetails.length > 1) {
                                        for (int i = 0;
                                            i < widget.wholesaleDetails.length;
                                            i++) {
                                          if (i <
                                              widget.wholesaleDetails.length -
                                                  1) {
                                            if (_totalAmountSelected >=
                                                    widget.wholesaleDetails[i]
                                                        .min &&
                                                _totalAmountSelected <=
                                                    widget.wholesaleDetails[i]
                                                        .max) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          } else {
                                            if (_totalAmountSelected >=
                                                widget
                                                    .wholesaleDetails[i].min) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          }
                                        }
                                      } else {
                                        _totalAmountPrice +=
                                            item.quantity * item.price;
                                      }
                                    }
                                  });
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: null,
            ),
          );
        } else if (tempTag != item.tag) {
          tempTag = item.tag;
          tabList.add(
            ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: tileList,
              ).toList(),
            ),
          );
          tileList.length = 0;
          tileList.add(
            ListTile(
              leading: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        item.variationName2,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "RM" + item.price.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(35.0),
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              title: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Text(
                        "Stock: " + item.stock.toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(35.0),
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.remove,
                            size: 12.0,
                          ),
                          onPressed: item.quantity == 0
                              ? null
                              : () {
                                  mystate(() {
                                    item.quantity -= widget.minimumLot;
                                    _variationDefaultImage = item.imageUrl;
                                    _totalAmountSelected -= widget.minimumLot;
                                    _totalAmountPrice = 0;
                                    for (var item in _variationListV2) {
                                      if (widget.wholesaleDetails.length > 1 &&
                                          _totalAmountSelected > 0) {
                                        for (int i = 0;
                                            i < widget.wholesaleDetails.length;
                                            i++) {
                                          if (i <
                                              widget.wholesaleDetails.length -
                                                  1) {
                                            if (_totalAmountSelected >=
                                                    widget.wholesaleDetails[i]
                                                        .min &&
                                                _totalAmountSelected <=
                                                    widget.wholesaleDetails[i]
                                                        .max) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          } else {
                                            if (_totalAmountSelected >=
                                                widget
                                                    .wholesaleDetails[i].min) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          }
                                        }
                                      } else {
                                        _totalAmountPrice +=
                                            item.quantity * item.price;
                                      }
                                    }
                                  });
                                },
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        height: 30.0,
                        width: 60.0,
                        child: Container(
                          child: Center(
                            child: Text(
                              item.quantity.toString(),
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.add,
                            size: 12.0,
                          ),
                          onPressed: _quantityDefault == item.stock ||
                                  item.quantity + widget.minimumLot > item.stock
                              ? null
                              : () {
                                  mystate(
                                    () {
                                      item.quantity += widget.minimumLot;
                                      _variationDefaultImage = item.imageUrl;
                                      _totalAmountSelected += widget.minimumLot;
                                      _totalAmountPrice = 0;
                                      for (var item in _variationListV2) {
                                        if (widget.wholesaleDetails.length >
                                            1) {
                                          for (int i = 0;
                                              i <
                                                  widget
                                                      .wholesaleDetails.length;
                                              i++) {
                                            if (i <
                                                widget.wholesaleDetails.length -
                                                    1) {
                                              if (_totalAmountSelected >=
                                                      widget.wholesaleDetails[i]
                                                          .min &&
                                                  _totalAmountSelected <=
                                                      widget.wholesaleDetails[i]
                                                          .max) {
                                                _totalAmountPrice =
                                                    _totalAmountSelected *
                                                        double.parse(widget
                                                            .wholesaleDetails[i]
                                                            .price
                                                            .toString());
                                                return;
                                              }
                                            } else {
                                              if (_totalAmountSelected >=
                                                  widget.wholesaleDetails[i]
                                                      .min) {
                                                _totalAmountPrice =
                                                    _totalAmountSelected *
                                                        double.parse(widget
                                                            .wholesaleDetails[i]
                                                            .price
                                                            .toString());
                                                return;
                                              }
                                            }
                                          }
                                        } else {
                                          _totalAmountPrice +=
                                              item.quantity * item.price;
                                        }
                                      }
                                    },
                                  );
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: null,
            ),
          );
        } else {
          tileList.add(
            ListTile(
              leading: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        item.variationName2,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "RM" + item.price.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(35.0),
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              title: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Text(
                        "Stock: " + item.stock.toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(35.0),
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.remove,
                            size: 12.0,
                          ),
                          onPressed: item.quantity == 0
                              ? null
                              : () {
                                  mystate(() {
                                    item.quantity -= widget.minimumLot;
                                    _variationDefaultImage = item.imageUrl;
                                    _totalAmountSelected -= widget.minimumLot;
                                    _totalAmountPrice = 0;
                                    for (var item in _variationListV2) {
                                      if (widget.wholesaleDetails.length > 1 &&
                                          _totalAmountSelected > 0) {
                                        for (int i = 0;
                                            i < widget.wholesaleDetails.length;
                                            i++) {
                                          if (i <
                                              widget.wholesaleDetails.length -
                                                  1) {
                                            if (_totalAmountSelected >=
                                                    widget.wholesaleDetails[i]
                                                        .min &&
                                                _totalAmountSelected <=
                                                    widget.wholesaleDetails[i]
                                                        .max) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          } else {
                                            if (_totalAmountSelected >=
                                                widget
                                                    .wholesaleDetails[i].min) {
                                              _totalAmountPrice =
                                                  _totalAmountSelected *
                                                      double.parse(widget
                                                          .wholesaleDetails[i]
                                                          .price
                                                          .toString());
                                              return;
                                            }
                                          }
                                        }
                                      } else {
                                        _totalAmountPrice +=
                                            item.quantity * item.price;
                                      }
                                    }
                                  });
                                },
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        height: 30.0,
                        width: 60.0,
                        child: Container(
                          child: Center(
                            child: Text(
                              item.quantity.toString(),
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.add,
                            size: 12.0,
                          ),
                          onPressed: _quantityDefault == item.stock ||
                                  item.quantity + widget.minimumLot > item.stock
                              ? null
                              : () {
                                  mystate(
                                    () {
                                      item.quantity += widget.minimumLot;
                                      _variationDefaultImage = item.imageUrl;
                                      _totalAmountSelected += widget.minimumLot;
                                      _totalAmountPrice = 0;
                                      for (var item in _variationListV2) {
                                        if (widget.wholesaleDetails.length >
                                            1) {
                                          for (int i = 0;
                                              i <
                                                  widget
                                                      .wholesaleDetails.length;
                                              i++) {
                                            if (i <
                                                widget.wholesaleDetails.length -
                                                    1) {
                                              if (_totalAmountSelected >=
                                                      widget.wholesaleDetails[i]
                                                          .min &&
                                                  _totalAmountSelected <=
                                                      widget.wholesaleDetails[i]
                                                          .max) {
                                                _totalAmountPrice =
                                                    _totalAmountSelected *
                                                        double.parse(widget
                                                            .wholesaleDetails[i]
                                                            .price
                                                            .toString());
                                                return;
                                              }
                                            } else {
                                              if (_totalAmountSelected >=
                                                  widget.wholesaleDetails[i]
                                                      .min) {
                                                _totalAmountPrice =
                                                    _totalAmountSelected *
                                                        double.parse(widget
                                                            .wholesaleDetails[i]
                                                            .price
                                                            .toString());
                                                return;
                                              }
                                            }
                                          }
                                        } else {
                                          _totalAmountPrice +=
                                              item.quantity * item.price;
                                        }
                                      }
                                    },
                                  );
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: null,
            ),
          );
        }

        if (counter == _variationListV2.length - 1) {
          tabList.add(
            ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: tileList,
              ).toList(),
            ),
          );
        }
        counter++;
      }
    }
    return tabList;
  }

  List<Widget> _initWholesaleDisplayPrice() {
    List<Widget> wholesalePrice = List<Widget>();
    for (var item in widget.wholesaleDetails) {
      wholesalePrice.add(
        Column(
          children: <Widget>[
            Container(
              child: Text(
                "RM" + item.price.toStringAsFixed(2),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: ScreenUtil().setSp(45.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              child: Text(
                "≥ " + item.min.toString() + " PCS",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: ScreenUtil().setSp(45.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return wholesalePrice;
  }

  bool _isStockEnough() {
    if (!widget.isVariationMode) {
      if (_totalAmountSelected + widget.variations[0].addedToCartQuantity >
          widget.variations[0].stock) {
        return false;
      } else {
        return true;
      }
    } else if (widget.isVariationMode && !widget.isVariation2Enabled) {
      for (var item in widget.variations) {
        if (item.quantity + item.addedToCartQuantity > item.stock) {
          return false;
        } else {
          return true;
        }
      }
    } else if (widget.isVariation2Enabled) {
      for (var item in widget.variations) {
        if (item.quantity + item.addedToCartQuantity > item.stock) {
          return false;
        } else {
          return true;
        }
      }
    }
    return true;
  }

  Future<void> _addToCart(YYDialog dialog) async {
    var variationIdList = [];

    if (_totalAmountSelected > 0) {
      if (_isStockEnough()) {
        dialog.show();
        var url =
            "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/mobileAddToBusinessCart";
        if (!widget.isVariationMode) {
          variationIdList.add({
            'variation_id': widget.productId,
            'quantity': _totalAmountSelected,
          });
        } else if (widget.isVariationMode && !widget.isVariation2Enabled) {
          for (var item in widget.variations) {
            if (item.quantity > 0) {
              variationIdList.add({
                'variation_id': item.variationId,
                'quantity': item.quantity,
              });
            }
          }
        } else if (widget.isVariation2Enabled) {
          for (var item in widget.variations) {
            if (item.quantity > 0) {
              variationIdList.add({
                'variation_id': item.variationId,
                'quantity': item.quantity,
              });
            }
          }
        }
        // TODO: The shop_id should get from shared preferences
        Map data = {
          'user_shop_id': 'Utt59m46wLMb2lyyWhDG',
          'selected_product_id': widget.productId,
          'variation_id_list': variationIdList,
          'selected_product_shop_id': widget.shopOwnerId
        };
        var body = json.encode(data);

        http
            .post(url,
                headers: {"Content-Type": "application/json"}, body: body)
            .then((response) {
          print(response.body);
          HttpRequestResponse httpRequestResponse = HttpRequestResponse();
          httpRequestResponse =
              HttpRequestResponse.fromJson(json.decode(response.body));
          if (httpRequestResponse.status == 'OK') {
            print('Added to cart');
          } else {
            print('Failed to add to cart');
          }
          if (!widget.isVariationMode) {
            widget.variations[0].addedToCartQuantity += _totalAmountSelected;
          } else if (widget.isVariationMode && !widget.isVariation2Enabled) {
            for (var item in widget.variations) {
              item.addedToCartQuantity += item.quantity;
            }
          } else if (widget.isVariation2Enabled) {
            for (var item in widget.variations) {
              item.addedToCartQuantity += item.quantity;
            }
          }
          _totalAmountSelected = 0;
          _totalAmountPrice = 0;
          for (var item in widget.variations) {
            item.quantity = 0;
          }
          dialog.dismiss();

          Navigator.pop(context);
          Fluttertoast.showToast(
            msg: "Added to cart",
            fontSize: ScreenUtil().setSp(40.0),
          );
        }).catchError((onError) {
          print(onError.toString());
        });
      } else {
        Fluttertoast.showToast(
          msg: "Not enough stock!",
          toastLength: Toast.LENGTH_LONG,
          fontSize: ScreenUtil().setSp(30.0),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    YYDialog.init(context);
    _initVariation();
    _addSlider();
    _buildVariationImageList();
    _variationDefaultImage = widget.coverImage;
    _tabController = TabController(length: _numberOfVariation, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _getRequests() async {
    print("I am here");
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);

    GlobalKey _scaffoldKey = GlobalKey();

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
          text: "Please wait...",
          alignment: Alignment.center,
          color: Colors.orange[500],
          fontSize: 18.0,
        );
    }

    double _top = 120;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              elevation: 1.0,
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              expandedHeight: 370.0,
              floating: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: InkWell(
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      _scaffoldKey.currentContext,
                      MaterialPageRoute(
                        builder: (context) => BusinessCart(
                          from: 'product',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: InkWell(
                    child: Icon(
                      Icons.more,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: null,
                )
              ],
              flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return FlexibleSpaceBar(
                  centerTitle: false,
                  title: _top < 110
                      ? Text(
                          widget.productName.replaceRange(
                              17, widget.productName.length, "..."),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(55.0),
                          ),
                        )
                      : null,
                  background: CarouselSlider(
                    options: CarouselOptions(
                      height: 500.0,
                      viewportFraction: 1.0,
                    ),
                    items: _sliderList.map((prefix0.Slider slider) {
                      return Builder(
                        builder: (BuildContext context) {
                          _top = constraints.biggest.height;
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  slider.imageUrl,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.productName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(52.0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.wholesaleDetails.length < 2,
                      child: Container(
                        margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.displayPrice,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: ScreenUtil().setSp(52.0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.wholesaleDetails.length > 1,
                      child: Container(
                        margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _initWholesaleDisplayPrice(),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              widget.productRating >= 1
                                  ? RatingBarIndicator(
                                      rating: widget.productRating,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 18.0,
                                      unratedColor: Colors.amber.withAlpha(50),
                                      direction: Axis.horizontal,
                                    )
                                  : Container(
                                      child: Text("No review yet"),
                                    ),
                              Visibility(
                                visible: widget.productRating >= 1,
                                child: Container(
                                  margin: EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    widget.productRating.toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(40.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 15.0),
                                child: Text(
                                  widget.unitSold.toString() + " Sold",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ScreenUtil().setSp(40.0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          LikeButton(
                            isLiked: widget.isFavourite,
                            size: 25.0,
                            onTap: _onFavouriteButtonTapped,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Visibility(
                visible: widget.isVariationMode,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    print("clicked");
                    showModalBottomSheet(
                      isDismissible: true,
                      isScrollControlled: false,
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter mystate) {
                          return Scaffold(
                            body: Container(
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 100.0,
                                            child: Image(
                                              image: NetworkImage(
                                                _variationDefaultImage,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(left: 10.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        widget.productName
                                                                    .length >
                                                                80
                                                            ? widget.productName
                                                                .replaceRange(
                                                                    80,
                                                                    widget
                                                                        .productName
                                                                        .length,
                                                                    "...")
                                                            : widget
                                                                .productName,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: ScreenUtil()
                                                              .setSp(45.0),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        widget.displayPrice,
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: ScreenUtil()
                                                              .setSp(52.0),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10.0),
                                      child: Divider(
                                        height: 5.0,
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.isVariation2Enabled,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0.0,
                                        ),
                                        child: TabBar(
                                          controller: _tabController,
                                          indicatorWeight: 2.0,
                                          indicatorColor:
                                              Theme.of(context).primaryColor,
                                          unselectedLabelColor:
                                              Colors.grey[700],
                                          isScrollable: true,
                                          labelStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(45.0),
                                            letterSpacing: 1.0,
                                          ),
                                          labelColor:
                                              Theme.of(context).primaryColor,
                                          tabs: _initVariationTab(),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.isVariation2Enabled,
                                      child: Container(
                                        child: Divider(
                                          height: 0.0,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.isVariation2Enabled,
                                      child: Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: _initTabView(mystate),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !widget.isVariation2Enabled,
                                      child: Expanded(
                                        child: _initTabView(mystate)[0],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            bottomNavigationBar: Container(
                              // color: Colors.black,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Color(0xFFEEEEEE),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      right: 15.0,
                                      left: 15.0,
                                      bottom: 5.0,
                                      top: 5.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "One lot is " +
                                                widget.minimumLot.toString() +
                                                " unit",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize:
                                                  ScreenUtil().setSp(40.0),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: RichText(
                                            text: TextSpan(
                                              text: "Total ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    ScreenUtil().setSp(45.0),
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: "$_totalAmountSelected",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                TextSpan(text: " pcs  "),
                                                TextSpan(
                                                  text: "RM " +
                                                      _totalAmountPrice
                                                          .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: ButtonTheme(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      height: 45.0,
                                      child: RaisedButton(
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          Future.delayed(Duration.zero)
                                              .then((value) {
                                            var dialog =
                                                yyProgressDialogNoBody();
                                            _addToCart(dialog);
                                          });
                                        },
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(40.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0),
                    color: Colors.white,
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                text: "Select variation ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenUtil().setSp(45.0),
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "($_numberOfVariation)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 15.0,
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 10.0,
                          ),
                          child: Row(
                            children: _variationList,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 10.0),
                color: Colors.white,
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFE0E0E0)),
                              ),
                              width: 60.0,
                              child: Image(
                                image: NetworkImage(widget.shopLogo),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      widget.shopName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: ScreenUtil().setSp(45.0),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 5.0, bottom: 5.0),
                                    child: Text(
                                      _shopAddressState,
                                      style: TextStyle(
                                        color: Color(0xFF757575),
                                        fontSize: ScreenUtil().setSp(35.0),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          child: FlatButton(
                            onPressed: () {},
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Text(
                              "View Shop",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40.0),
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                widget.numberOfProduct.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: ScreenUtil().setSp(45.0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "Products",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil().setSp(45.0),
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                widget.shopRating >= 1
                                    ? widget.shopRating.toString()
                                    : "-",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: ScreenUtil().setSp(45.0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                widget.shopRating >= 1
                                    ? "Shop Rating"
                                    : "No Rating",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil().setSp(45.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 10.0),
                color: Colors.white,
                child: Column(
                  children: _createExtraForm(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                ),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Product Ratings",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: ScreenUtil().setSp(45.0),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 5.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    RatingBarIndicator(
                                      rating: _userRating,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 18.0,
                                      unratedColor: Colors.amber.withAlpha(50),
                                      direction: Axis.horizontal,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        _userRating.toString() + "/5",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: ScreenUtil().setSp(40.0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        "($_howManyReview Reviews)",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: ScreenUtil().setSp(40.0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Container(
                            child: InkWell(
                              onTap: () {},
                              child: Text(
                                "See All >",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: ScreenUtil().setSp(45.0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 3.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 15.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.store,
                    color: Colors.grey,
                  ),
                  Container(
                    child: Text(
                      "Shop",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(40.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: 15.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.message,
                    color: Colors.grey,
                  ),
                  Container(
                    child: Text(
                      "Contact",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(40.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: 10.0,
                ),
                child: RaisedButton(
                  elevation: 0,
                  onPressed: () {
                    showModalBottomSheet(
                      isDismissible: true,
                      isScrollControlled: false,
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter mystate) {
                          return Scaffold(
                            body: Container(
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 100.0,
                                            child: Image(
                                              image: NetworkImage(
                                                  _variationDefaultImage),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(left: 10.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        widget.productName
                                                                    .length >
                                                                80
                                                            ? widget.productName
                                                                .replaceRange(
                                                                    80,
                                                                    widget
                                                                        .productName
                                                                        .length,
                                                                    "...")
                                                            : widget
                                                                .productName,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: ScreenUtil()
                                                              .setSp(45.0),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        widget.displayPrice,
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: ScreenUtil()
                                                              .setSp(52.0),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10.0),
                                      child: Divider(
                                        height: 5.0,
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.isVariation2Enabled,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0.0,
                                        ),
                                        child: TabBar(
                                          controller: _tabController,
                                          // indicatorPadding: EdgeInsets.all(5.0),
                                          indicatorWeight: 2.0,
                                          indicatorColor:
                                              Theme.of(context).primaryColor,
                                          unselectedLabelColor:
                                              Colors.grey[700],
                                          isScrollable: true,
                                          labelStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(45.0),
                                            letterSpacing: 1.0,
                                          ),
                                          labelColor:
                                              Theme.of(context).primaryColor,
                                          tabs: _initVariationTab(),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.isVariation2Enabled,
                                      child: Container(
                                        child: Divider(
                                          height: 0.0,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.isVariation2Enabled,
                                      child: Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: _initTabView(mystate),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !widget.isVariation2Enabled,
                                      child: Expanded(
                                        child: _initTabView(mystate)[0],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            bottomNavigationBar: Container(
                              // color: Colors.black,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Color(0xFFEEEEEE),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      right: 15.0,
                                      left: 15.0,
                                      bottom: 5.0,
                                      top: 5.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "One lot is " +
                                                widget.minimumLot.toString() +
                                                " unit",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize:
                                                  ScreenUtil().setSp(40.0),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: RichText(
                                            text: TextSpan(
                                              text: "Total ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    ScreenUtil().setSp(45.0),
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: "$_totalAmountSelected",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                TextSpan(text: " pcs  "),
                                                TextSpan(
                                                  text: "RM " +
                                                      _totalAmountPrice
                                                          .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: ButtonTheme(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      height: 45.0,
                                      child: RaisedButton(
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          Future.delayed(Duration.zero)
                                              .then((value) {
                                            var dialog =
                                                yyProgressDialogNoBody();
                                            _addToCart(dialog);
                                          });
                                        },
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(40.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  },
                  color: Color(0xFFFFF3E0),
                  child: Text(
                    "Add To Cart",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: ScreenUtil().setSp(45.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: RaisedButton(
                  elevation: 0,
                  onPressed: () {},
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    "Purchase Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(45.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
