import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:uwlaa/model/wholesale_cart.dart';
import 'package:http/http.dart' as http;
import 'package:uwlaa/screen/payment_status.dart';
import 'package:uwlaa/screen/user_profile/business_address.dart';

class BusinessCheckOut extends StatefulWidget {
  final List<WholesaleShopCart> wholesaleShopList;
  final String fullAddress, fullName, phoneNumber, state, postalCode, area;

  BusinessCheckOut({
    Key key,
    @required this.wholesaleShopList,
    @required this.fullAddress,
    @required this.fullName,
    @required this.phoneNumber,
    @required this.state,
    @required this.postalCode,
    @required this.area,
  }) : super(key: key);

  @override
  _BusinessCheckOutState createState() => _BusinessCheckOutState();
}

class _BusinessCheckOutState extends State<BusinessCheckOut> {
  // TextEditingController _messageController = TextEditingController();

  List<TextEditingController> _messageControllerList =
      List<TextEditingController>();

  // Important for checkout
  List<WholesaleShopCart> wholesaleShopCartList = List<WholesaleShopCart>();
  List<dynamic> _shippingDetails;

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
        text: "Processing...",
        alignment: Alignment.center,
        color: Colors.orange[500],
        fontSize: 18.0,
      );
  }

  var dialog;

  double _merchandiseSubTotal = 0;
  double _shippingSubTotal = 0;
  double _totalPayment = 0;
  String shopId = "";

  initPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    shopId = prefs.getString('shop_id');
  }

  Future<void> _createOrder(String paymentId, YYDialog dialog) {
    var shopData = [];
    for (var item in wholesaleShopCartList) {
      var productData = [];
      for (var i in item.productsInCart) {
        var variationData = [];
        for (var j in i.variations) {
          variationData.add({
            "added_to_cart_quantity": j.addedToCartQuantity,
            "variation_id": j.variationId,
            "price": j.price
          });
        }
        var wholesaleDetails = [];
        for (var item in i.productDetails.wholesaleDetails) {
          wholesaleDetails.add({
            "min": item.min,
            "max": item.max,
            "price": item.price,
          });
        }
        productData.add({
          "product_id": i.productId,
          "halal_certificate_issue_country": i.productDetails.halalIssueCountry,
          "wholesale_details": wholesaleDetails,
          "product_type": i.productDetails.productType,
          "product_images": i.productDetails.productImages,
          "halal_cert_image": i.productDetails.halalCertImage,
          "shop_owner_id": i.productDetails.shopOwnerId,
          "product_name": i.productDetails.productName,
          "cover_image": i.productDetails.coverImage,
          "product_description": i.productDetails.productDescription,
          "price_display": i.productDetails.priceDisplay,
          "product_snapshot_id": i.productDetails.productId,
          "is_variation_mode": i.productDetails.isVariationMode,
          "is_variation2_enabled": i.productDetails.isVariation2Enabled,
          "variations": variationData,
        });
      }
      shopData.add({"shop_id": item.shopId, "products": productData});
    }

    var shippingDetails = []; // result
    for (var item in _shippingDetails) {
      shippingDetails.add({
        "shop_id": item["shop_id"],
        "delivery_type": item["delivery_type"],
        "products": item["products"]
      });
    }
    dialog.show();
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/createOrder";
    Map data = {
      "transaction_details": shopData,
      "shipping_details": shippingDetails,
      "payment_id": paymentId,
      "user_shop_id": shopId,
    };

    var body = json.encode(data);

    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      debugPrint(response.body.toString(), wrapWidth: 1024);
      // print(response.body.toString());
      var resp = json.decode(response.body);
      dialog.dismiss();
      if (resp["status"] == "OK") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => PaymentStatusScreen(
              paymentStatus: "Success",
            ),
          ),
        );
      } else {
        print(resp["status"]);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => PaymentStatusScreen(
              paymentStatus: "Error",
            ),
          ),
        );
      }
    }).catchError((onError) {
      print(onError.toString());
    });
    return null;
  }

  void confirmDialog(String clientSecret, PaymentMethod paymentMethod) {
    var confirm = AlertDialog(
      title: Text(
        "Confirm Payment ?",
        style: TextStyle(
          fontSize: ScreenUtil().setSp(
            50.0,
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(50.0),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            dialog.dismiss();
            print("Payment cancelled");
          },
        ),
        FlatButton(
          child: Text(
            'Confirm',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(50.0),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            confirmPayment(
              clientSecret,
              paymentMethod,
            );
          },
        ),
      ],
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return confirm;
        });
  }

  void confirmPayment(String sec, PaymentMethod paymentMethod) {
    StripePayment.confirmPaymentIntent(
            PaymentIntent(clientSecret: sec, paymentMethodId: paymentMethod.id))
        .then((value) {
      dialog.dismiss();
      if (value.status == "succeeded") {
        print("Payment successful");
        Future.delayed(Duration(milliseconds: 500)).then((response) {
          _createOrder(value.paymentIntentId, dialog);
        });
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => PaymentStatusScreen(
              paymentStatus: "Error",
            ),
          ),
        );
      }
    }).catchError((onError) {
      print(onError.toString());
      dialog.dismiss();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => PaymentStatusScreen(
            paymentStatus: "Error",
          ),
        ),
      );
    });
  }

  void _createPayment(YYDialog dialog) {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey:
            "pk_test_51H2ZL3EYPvkM1gayDFSHhFPimU4byVcdimSKQyhaVfHdOnTAEzaM5NEcrgbkENd3tlhTp5Bf2NZOv78qlvTsbeg500QmY5LPrf",
      ),
    );

    dialog.show();

    final HttpsCallable INTENT = CloudFunctions.instance
        .getHttpsCallable(functionName: 'createPaymentIntent');

    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      double amount = num.parse((_totalPayment * 100.0).toStringAsFixed(2));
      print(amount.toString());
      INTENT.call(<String, dynamic>{'amount': amount, 'currency': 'myr'}).then(
          (response) {
        confirmDialog(response.data["client_secret"], paymentMethod);
      }).catchError((onError) {
        print(onError.toString());
      });
    });
  }

  void _arrangeCheckoutList() {
    for (var item in widget.wholesaleShopList) {
      _messageControllerList.add(TextEditingController());
      List<ProductsCart> productCartList = List<ProductsCart>();
      for (var i in item.productsInCart) {
        List<CartVariation> cartVarationList = List<CartVariation>();
        for (var j in i.variations) {
          if (j.isChecked) {
            cartVarationList.add(CartVariation(
              variationId: j.variationId,
              addedToCartQuantity: j.addedToCartQuantity,
              status: j.status,
              stock: j.stock,
              price: j.price,
              isChecked: j.isChecked,
            ));
          }
        }
        if (cartVarationList.length > 0) {
          productCartList.add(ProductsCart(
            productId: i.productId,
            productDetails: i.productDetails,
            isChecked: i.isChecked,
            variations: cartVarationList,
          ));
        }
      }
      if (productCartList.length > 0) {
        wholesaleShopCartList.add(
          WholesaleShopCart(
            shopName: item.shopName,
            shopId: item.shopId,
            isChecked: item.isChecked,
            productsInCart: productCartList,
          ),
        );
      }
    }
    setState(() {});
    print("final length " + wholesaleShopCartList.length.toString());
  }

  List<Widget> _createCheckoutList() {
    print("checkout list");
    List<Widget> checkoutList = List<Widget>();
    int numberOfShop = 0;
    for (var item in wholesaleShopCartList) {
      List<Widget> productList = List<Widget>();
      int numberOfItem = 0;
      for (var i in item.productsInCart) {
        List<Widget> variationList = List<Widget>();
        // Only when selected item
        int totalVariationQuantity = 0;
        for (var j in i.variations) {
          if (j.isChecked) {
            totalVariationQuantity += j.addedToCartQuantity;
          }
        }
        print(totalVariationQuantity.toString());
        for (var j in i.variations) {
          if (j.isChecked) {
            // Variation Name
            var variationIndex = i.productDetails.variations
                .indexWhere((element) => element.variationId == j.variationId);
            String variationName = "";
            if (variationIndex > -1) {
              if (i.productDetails.variations[variationIndex].variationName2 ==
                  "") {
                variationName =
                    i.productDetails.variations[variationIndex].variationName1;
              } else {
                variationName = i.productDetails.variations[variationIndex]
                        .variationName1 +
                    ", " +
                    i.productDetails.variations[variationIndex].variationName2;
              }
            }
            // Unit Price
            double unitPrice = 0;
            if (i.productDetails.wholesaleDetails.length > 1) {
              for (int x = 0;
                  x < i.productDetails.wholesaleDetails.length;
                  x++) {
                if (x < i.productDetails.wholesaleDetails.length - 1) {
                  if (totalVariationQuantity >=
                          i.productDetails.wholesaleDetails[x].min &&
                      totalVariationQuantity <=
                          i.productDetails.wholesaleDetails[x].max) {
                    print("whosale price " +
                        i.productDetails.wholesaleDetails[x].price.runtimeType
                            .toString());
                    unitPrice = double.parse(
                        i.productDetails.wholesaleDetails[x].price.toString());
                  }
                } else {
                  if (totalVariationQuantity >=
                      i.productDetails.wholesaleDetails[x].min) {
                    unitPrice = double.parse(
                        i.productDetails.wholesaleDetails[x].price.toString());
                  }
                }
              }
            } else {
              unitPrice = double.parse(j.price.toString());
              print(j.price);
            }
            // How many item
            numberOfItem += j.addedToCartQuantity;
            variationList.add(
              Container(
                padding: EdgeInsets.only(
                  left: 5.0,
                  right: 5.0,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: 5.0,
                        right: 10.0,
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Variation    :",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(42.0),
                                      color: Colors.grey,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "   " + variationName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: ScreenUtil().setSp(42.0),
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  "RM" +
                                      (j.addedToCartQuantity * unitPrice)
                                          .toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(42.0),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Unit Price   :",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(42.0),
                                      color: Colors.grey,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "   RM" +
                                            unitPrice.toStringAsFixed(2) +
                                            "/PCS",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          fontSize: ScreenUtil().setSp(42.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  "x " +
                                      j.addedToCartQuantity.toString() +
                                      " PCS",
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(42.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        if (variationList.length > 0) {
          productList.add(
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 5.0,
                          bottom: 5.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                        width: 75.0,
                        child: Image(
                          image: NetworkImage(
                            i.productDetails.coverImage,
                          ),
                        ),
                      ),
                      Container(
                        width: 230.0,
                        margin: EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          top: 5.0,
                        ),
                        child: Text(
                          i.productDetails.productName.replaceRange(
                              49, i.productDetails.productName.length, "..."),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(42.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: variationList,
                ),
              ],
            ),
          );
        }
      }
      if (productList.length > 0) {
        checkoutList.add(
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            padding: EdgeInsets.only(
              top: 5.0,
              bottom: 5.0,
            ),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.store),
                      Container(
                        margin: EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Text(
                          item.shopName,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: ScreenUtil().setSp(42.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Column(
                  children: productList,
                ),
                // Shipping Fee
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    top: 10.0,
                    bottom: 15.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4FFFC),
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFB2DFDB),
                      ),
                      bottom: BorderSide(
                        color: Color(0xFFB2DFDB),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          "Shipping",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(42.0),
                            color: Color(0xFF4DB6AC),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Divider(),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Standard Delivery",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: ScreenUtil().setSp(
                                    42.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                // "",
                                _shippingFee.isNotEmpty
                                    ? "RM" +
                                        _shippingFee[numberOfShop]
                                            .toStringAsFixed(2)
                                    : "",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScreenUtil().setSp(
                                    42.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Message
                Container(
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    // top: 10.0,
                    // bottom: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Text(
                          "Message:",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(42.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 180.0,
                        child: Form(
                          child: TextFormField(
                            controller: _messageControllerList[numberOfShop],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(35.0),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              isDense: false,
                              border: InputBorder.none,
                              hintText: "Please leave a message",
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  height: 1.0,
                ),
                // Total price for the product
                Container(
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    top: 10.0,
                    bottom: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Text(
                          numberOfItem > 1
                              ? "Order Total ($numberOfItem items):"
                              : "Order Total ($numberOfItem item):",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(42.0),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          _totalPriceForShop.isEmpty
                              ? ""
                              : "RM" +
                                  _totalPriceForShop[numberOfShop]
                                      .toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(42.0),
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      numberOfShop++;
    }
    return checkoutList;
  }

  var _shippingFee = [];
  var _totalPriceForShop = [];

  Future<void> _calculateShipping() {
    var shopData = [];
    for (var item in wholesaleShopCartList) {
      var productData = [];
      for (var i in item.productsInCart) {
        var variationData = [];
        for (var j in i.variations) {
          if (j.isChecked) {
            variationData.add({
              "added_to_cart_quantity": j.addedToCartQuantity,
              "variation_id": j.variationId,
            });
          }
        }
        if (variationData.length > 0) {
          productData.add({
            "product_id": i.productId,
            "product_name": i.productDetails.productName,
            "variations": variationData,
          });
        }
      }
      if (productData.length > 0) {
        shopData.add({
          "shop_id": item.shopId,
          "products": productData,
        });
      }
    }
    _isCalculatingShippingFee = true;
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/calculateShippingFeeForCheckout";
    Map data = {
      "receiver_address_state": widget.state,
      "receiver_address_postal": widget.postalCode,
      "order_list": shopData
    };

    var body = json.encode(data);

    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      _isCalculatingShippingFee = false;
      var resp = json.decode(response.body);
      print(response.body);
      if (resp["status"] == "OK") {
        if (resp["message"] != "OK") {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  resp["message"],
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
                        fontSize: ScreenUtil().setSp(45.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // proceed
          _shippingDetails = resp["result"];
          for (var item in resp["result"]) {
            double totalShippingFee = 0;
            for (var i in item["products"]) {
              totalShippingFee += double.parse(i["actual_shipping_fee"]);
            }
            _shippingFee.add(totalShippingFee);
          }
        }
      } else {
        print(resp["message"]);
      }
      // Calculate overall
      int numberOfShop = 0;
      for (var item in wholesaleShopCartList) {
        double totalPriceForShop = 0;
        for (var i in item.productsInCart) {
          int totalVariationQuantity = 0;
          for (var j in i.variations) {
            if (j.isChecked) {
              totalVariationQuantity += j.addedToCartQuantity;
            }
          }
          for (var j in i.variations) {
            double unitPrice = 0;
            if (i.productDetails.wholesaleDetails.length > 1) {
              for (int x = 0;
                  x < i.productDetails.wholesaleDetails.length;
                  x++) {
                if (x < i.productDetails.wholesaleDetails.length - 1) {
                  if (totalVariationQuantity >=
                          i.productDetails.wholesaleDetails[x].min &&
                      totalVariationQuantity <=
                          i.productDetails.wholesaleDetails[x].max) {
                    print("whosale price " +
                        i.productDetails.wholesaleDetails[x].price.runtimeType
                            .toString());
                    unitPrice = double.parse(
                        i.productDetails.wholesaleDetails[x].price.toString());
                  }
                } else {
                  if (totalVariationQuantity >=
                      i.productDetails.wholesaleDetails[x].min) {
                    unitPrice = double.parse(
                        i.productDetails.wholesaleDetails[x].price.toString());
                  }
                }
              }
            } else {
              unitPrice = double.parse(j.price.toString());
            }
            totalPriceForShop += unitPrice * j.addedToCartQuantity;
          }
        }
        _totalPriceForShop.add(totalPriceForShop + _shippingFee[numberOfShop]);
        numberOfShop++;
      }
      // Merchant, shipping and total
      for (int x = 0; x < _shippingFee.length; x++) {
        _merchandiseSubTotal += _totalPriceForShop[x] - _shippingFee[x];
        _shippingSubTotal += _shippingFee[x];
        _totalPayment += _totalPriceForShop[x];
      }
      setState(() {});
    }).catchError((onError) {
      print(onError.toString());
    });
    return null;
  }

  bool _isCalculatingShippingFee = false;

  String _fullAddress = "";
  String _area = "";
  String _postalCode = "";
  String _state = "";
  String _fullName = "";
  String _phoneNumber = "";

  void _updateAddressInfo(String addressInfo) {
    var resp = json.decode(addressInfo);
    setState(() {
      _newAddressSelected = resp["new_address_selected"];
      if (_newAddressSelected) {
        _fullAddress = resp["detail_address"];
        _area = resp["area"];
        _postalCode = resp["postal_code"];
        _state = resp["state"];
        _fullName = resp["full_name"];
        _phoneNumber = resp["phone_number"];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initPreferences();
    _arrangeCheckoutList();
    _calculateShipping();
  }

  bool _newAddressSelected = false;

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);

    String _deliveryAddress = "";
    String _contactDetails = "";
    if (_newAddressSelected) {
      print("New address selected");
      _deliveryAddress = _fullAddress.replaceAll("\\n", "\n") +
          "\n" +
          _area +
          ",\n" +
          _postalCode +
          ", " +
          _state;
      _contactDetails = _fullName + " | " + _phoneNumber;
    } else {
      print("Old address selected");
      _deliveryAddress = widget.fullAddress.replaceAll("\\n", "\n") +
          "\n" +
          widget.area +
          ",\n" +
          widget.postalCode +
          ", " +
          widget.state;
      _contactDetails = widget.fullName + " | " + widget.phoneNumber;
    }

    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 3.0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Checkout",
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
            child: InkWell(
              onTap: () {
                print("clicked");
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Delivery Address",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40.0),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _contactDetails,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40.0),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            // margin: EdgeInsets.only(bottom: 5.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _deliveryAddress,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40.0),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_right),
                          color: Colors.grey,
                          onPressed: () async {
                            print("clicked");
                            final addressInfo =
                                await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    BusinessAddressScreen(
                                  type: "select",
                                ),
                              ),
                            );
                            _updateAddressInfo(addressInfo);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(
                top: 10.0,
              ),
              child: Column(
                children: _createCheckoutList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
              ),
              margin: EdgeInsets.only(
                bottom: 20.0,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          // bottom: 10.0,
                        ),
                        child: Text(
                          "Payment Option",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(42.0),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          // bottom: 10.0,
                        ),
                        child: Text(
                          "Credit Card / Debit Card >",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(42.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Container(
                    margin: EdgeInsets.only(
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            top: 2.0,
                            bottom: 2.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Merchandise Subtotal",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(35.0),
                                ),
                              ),
                              Text(
                                "RM" + _merchandiseSubTotal.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(35.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 2.0,
                            bottom: 2.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Shipping Subtotal",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(35.0),
                                ),
                              ),
                              Text(
                                "RM" + _shippingSubTotal.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(35.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 2.0,
                            bottom: 2.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Total Payment",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(42.0),
                                ),
                              ),
                              Text(
                                "RM" + _totalPayment.toStringAsFixed(2),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: ScreenUtil().setSp(42.0),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 3.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Text(
                          "Total Payment",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(40.0),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          "RM" + _totalPayment.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(42.0),
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _isCalculatingShippingFee
                      ? null
                      : () {
                          dialog = yyProgressDialogNoBody();
                          _createPayment(dialog);
                        },
                  child: Container(
                    height: 50.0,
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    color: _isCalculatingShippingFee
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    child: Center(
                      child: Text(
                        _isCalculatingShippingFee
                            ? "Calculating"
                            : "Place Order",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(50.0),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
