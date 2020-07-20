import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwlaa/model/business_product.dart';
import 'package:uwlaa/model/http_request_response.dart';
import 'package:uwlaa/model/wholesale_cart.dart';
import 'package:http/http.dart' as http;
import 'package:uwlaa/screen/user_profile/business_address.dart';

import 'business_business_product_details.dart';
import 'business_check_out.dart';

class BusinessCart extends StatefulWidget {
  final String from;

  BusinessCart({Key key, @required this.from}) : super(key: key);

  @override
  _BusinessCartState createState() => _BusinessCartState();
}

class _BusinessCartState extends State<BusinessCart> {
  BusinessCartList _businessCartList = BusinessCartList();
  List<WholesaleShopCart> _wholesaleShopCart = List<WholesaleShopCart>();

  bool _isEditing = false;
  String shopId = "";

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

  initPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    shopId = prefs.getString('shop_id');
    var dialog = yyProgressDialogNoBody();
    _initCartList(dialog);
  }

  Future<void> _initCartList(YYDialog dialog) async {
    _wholesaleShopCart = [];
    _price = 0;
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/mobileGetBusinessCart";
    // TODO: The shop_id should get from shared preferences
    Map data = {'shop_id': shopId};
    var body = json.encode(data);
    dialog.show();
    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      dialog.dismiss();
      _businessCartList = BusinessCartList.fromJson(json.decode(response.body));
      if (_businessCartList.status == 'OK') {
        if (_businessCartList.cartList.length > 0) {
          for (var item in _businessCartList.cartList) {
            var shopId, shopName, productsInCart, isChecked;
            List<ProductsCart> _productsInCartList = List<ProductsCart>();
            for (String key in item.keys) {
              if (key == "shop_name") {
                shopName = item[key];
              } else if (key == "shop_id") {
                shopId = item[key];
              } else if (key == "is_checked") {
                isChecked = item[key];
              } else if (key == "products_in_cart") {
                productsInCart = item[key];
                for (var i in productsInCart) {
                  var productId, variations, productDetails, isChecked;
                  List<CartVariation> _variationsList = List<CartVariation>();
                  BusinessProduct _productDetails = BusinessProduct();
                  for (String key1 in i.keys) {
                    if (key1 == "product_id") {
                      productId = i[key1];
                    } else if (key1 == "is_checked") {
                      isChecked = i[key1];
                    } else if (key1 == "variations") {
                      variations = i[key1];
                      for (var j in variations) {
                        var variationId,
                            addedToCartQuantity,
                            status,
                            stock,
                            price,
                            isChecked;
                        for (String key2 in j.keys) {
                          if (key2 == "variation_id") {
                            variationId = j[key2];
                          } else if (key2 == "is_checked") {
                            isChecked = j[key2];
                          } else if (key2 == "added_to_cart_quantity") {
                            addedToCartQuantity = j[key2];
                          } else if (key2 == "status") {
                            status = j[key2];
                          } else if (key2 == "stock") {
                            stock = j[key2];
                          } else if (key2 == "price") {
                            price = j[key2];
                          }
                        }
                        _variationsList.add(CartVariation(
                          variationId: variationId,
                          addedToCartQuantity: addedToCartQuantity,
                          status: status,
                          stock: stock,
                          price: price,
                          isChecked: isChecked,
                        ));
                      }
                    } else if (key1 == "product_details") {
                      productDetails = i[key1];
                      var isPreOrder,
                          isVariationMode,
                          isVariation2Enabled,
                          productName,
                          coverImage,
                          productDescription,
                          minimumLot,
                          productRating,
                          productPrice,
                          productId,
                          isFavourite,
                          priceDisplay,
                          shopName,
                          shopRating,
                          shopLogo,
                          unitSold,
                          productImages,
                          extraQuestionForm,
                          wholesaleDetails,
                          variations,
                          daysToShip,
                          productType,
                          halalCertImage,
                          numberOfProduct,
                          totalStock,
                          shopOwnerId,
                          shippingOptions;
                      List<ShippingOptions> _shippingOptionList =
                          List<ShippingOptions>();
                      List<ExtraQuestion> _extraQuestionList =
                          List<ExtraQuestion>();
                      List<WholesaleDetail> _wholeSaleList =
                          List<WholesaleDetail>();
                      List<Variations> _variationList = List<Variations>();
                      for (String key2 in productDetails.keys) {
                        if (key2 == "is_pre_order") {
                          isPreOrder = productDetails[key2];
                        } else if (key2 == "is_variation_mode") {
                          isVariationMode = productDetails[key2];
                        } else if (key2 == "is_variation2_enabled") {
                          isVariation2Enabled = productDetails[key2];
                        } else if (key2 == "product_name") {
                          productName = productDetails[key2];
                        } else if (key2 == "cover_image") {
                          coverImage = productDetails[key2];
                        } else if (key2 == "product_description") {
                          productDescription = productDetails[key2];
                        } else if (key2 == "minimum_lot") {
                          minimumLot = productDetails[key2];
                        } else if (key2 == "product_rating") {
                          productRating = productDetails[key2];
                        } else if (key2 == "product_price") {
                          productPrice = productDetails[key2];
                        } else if (key2 == "id") {
                          productId = productDetails[key2];
                        } else if (key2 == "is_favourite") {
                          isFavourite = productDetails[key2];
                        } else if (key2 == "price_display") {
                          priceDisplay = productDetails[key2];
                        } else if (key2 == "shop_name") {
                          shopName = productDetails[key2];
                        } else if (key2 == "shop_rating") {
                          shopRating = productDetails[key2];
                        } else if (key2 == "shop_logo") {
                          shopLogo = productDetails[key2];
                        } else if (key2 == "unit_sold") {
                          unitSold = productDetails[key2];
                        } else if (key2 == "product_images") {
                          productImages = productDetails[key2];
                        } else if (key2 == "extra_question_form") {
                          extraQuestionForm = productDetails[key2];
                          for (var i in extraQuestionForm) {
                            var title, answer;
                            for (String key3 in i.keys) {
                              if (key3 == "title") {
                                title = i[key3];
                              } else if (key3 == "answer") {
                                answer = i[key3];
                              }
                            }
                            _extraQuestionList.add(
                                ExtraQuestion(title: title, answer: answer));
                          }
                        } else if (key2 == "shipping_options") {
                          shippingOptions = productDetails[key2];
                          for (var i in shippingOptions) {
                            var options,
                                shippingMultiplier,
                                id,
                                category,
                                shippingFee,
                                title,
                                isEnabled;
                            for (String key3 in i.keys) {
                              if (key3 == "options") {
                                options = i[key3];
                              } else if (key3 == "shipping_multiplier") {
                                shippingMultiplier = i[key3];
                              } else if (key3 == "id") {
                                id = i[key3];
                              } else if (key3 == "category") {
                                category = i[key3];
                              } else if (key3 == "shipping_fee") {
                                shippingFee = i[key3];
                              } else if (key3 == "title") {
                                title = i[key3];
                              } else if (key3 == "isEnabled") {
                                isEnabled = i[key3];
                              }
                            }
                            _shippingOptionList.add(ShippingOptions(
                              options: options,
                              shippingMultiplier: shippingMultiplier,
                              id: id,
                              category: category,
                              shippingFee: shippingFee,
                              title: title,
                              isEnabled: isEnabled,
                            ));
                          }
                        } else if (key2 == "wholesale_details") {
                          wholesaleDetails = productDetails[key2];
                          for (var i in wholesaleDetails) {
                            var min, max, price;
                            for (String key3 in i.keys) {
                              if (key3 == "min") {
                                min = i[key3];
                              } else if (key3 == "max") {
                                max = i[key3];
                              } else if (key3 == "price") {
                                price = i[key3];
                              }
                            }
                            _wholeSaleList.add(WholesaleDetail(
                                min: min, max: max, price: price));
                          }
                        } else if (key2 == "variation_list") {
                          variations = productDetails[key2];
                          for (var i in variations) {
                            var variationName1,
                                variationName2,
                                stock,
                                price,
                                imageUrl,
                                quantity,
                                tag,
                                variationId,
                                addedToCartQuantity;
                            for (String key3 in i.keys) {
                              if (key3 == "variation_name_1") {
                                variationName1 = i[key3];
                              } else if (key3 == "variation_name_2") {
                                variationName2 = i[key3];
                              } else if (key3 == "stock") {
                                stock = i[key3];
                              } else if (key3 == "price") {
                                price = i[key3];
                              } else if (key3 == "image_url") {
                                imageUrl = i[key3];
                              } else if (key3 == "quantity") {
                                quantity = i[key3];
                              } else if (key3 == "tag") {
                                tag = i[key3];
                              } else if (key3 == "variation_id") {
                                variationId = i[key3];
                              } else if (key3 == "added_to_cart_quantity") {
                                addedToCartQuantity = i[key3];
                              }
                            }
                            _variationList.add(
                              Variations(
                                variationName1: variationName1,
                                variationName2: variationName2,
                                stock: stock,
                                price: price,
                                imageUrl: imageUrl,
                                quantity: quantity,
                                tag: tag,
                                variationId: variationId,
                                addedToCartQuantity: addedToCartQuantity,
                              ),
                            );
                          }
                        } else if (key2 == "days_to_ship") {
                          daysToShip = productDetails[key2];
                        } else if (key2 == "product_type") {
                          productType = productDetails[key2];
                        } else if (key2 == "halal_cert_image") {
                          halalCertImage = productDetails[key2];
                        } else if (key2 == "shop_number_of_product") {
                          numberOfProduct = productDetails[key2];
                        } else if (key2 == "total_stock") {
                          totalStock = productDetails[key2];
                        } else if (key2 == "shop_owner_id") {
                          shopOwnerId = productDetails[key2];
                        }
                      }

                      _productDetails = BusinessProduct(
                        isPreOrder: isPreOrder,
                        isVariationMode: isVariationMode,
                        isVariation2Enabled: isVariation2Enabled,
                        productName: productName,
                        coverImage: coverImage,
                        productDescription: productDescription,
                        minimumLot: minimumLot,
                        productRating: productRating,
                        productPrice: productPrice,
                        productId: productId,
                        isFavourite: isFavourite,
                        priceDisplay: priceDisplay,
                        shopName: shopName,
                        shopRating: shopRating,
                        shopLogo: shopLogo,
                        unitSold: unitSold,
                        productImages: productImages,
                        extraQuestionForm: _extraQuestionList,
                        wholesaleDetails: _wholeSaleList,
                        variations: _variationList,
                        shippingOptions: _shippingOptionList,
                        daysToShip: daysToShip,
                        productType: productType,
                        halalCertImage: halalCertImage,
                        numberOfProduct: numberOfProduct,
                        totalStock: totalStock,
                        shopOwnerId: shopOwnerId,
                      );
                    }
                  }

                  _productsInCartList.add(ProductsCart(
                    productId: productId,
                    productDetails: _productDetails,
                    variations: _variationsList,
                    isChecked: isChecked,
                  ));
                }
              }
            }
            _wholesaleShopCart.add(WholesaleShopCart(
              shopId: shopId,
              shopName: shopName,
              productsInCart: _productsInCartList,
              isChecked: isChecked,
            ));
          }
        }
        _allSelectedChecked = false;
        setState(() {});
      }
    }).catchError((onError) {
      dialog.dismiss();
      print(onError.toString());
    });
  }

  Future<void> _deleteSelectedCartItem(
      var removeCartItemList, YYDialog dialog) {
    HttpRequestResponse httpRequestResponse = HttpRequestResponse();
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/massRemoveBusinessCart";
    // TODO: Replace the user shop id
    Map data = {
      "selected_variation_list": removeCartItemList,
      "user_shop_id": shopId
    };
    var body = json.encode(data);
    dialog.show();
    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      print(response.body.toString());
      dialog.dismiss();
      httpRequestResponse =
          HttpRequestResponse.fromJson(json.decode(response.body));
      if (httpRequestResponse.status == 'OK') {
        print("OK");
        Future.delayed(Duration.zero).then((value) {
          var dialog2 = yyProgressDialogNoBody();
          _initCartList(dialog2);
        });
      } else {
        print("Something wrong");
      }
    }).catchError((onError) {
      dialog.dismiss();
      print(onError.toString());
    });
    return null;
  }

  Future<void> _updateCart(
    String variationId,
    String productId,
    String userShopId,
    int amountToChange,
    int amountAfterChange,
    String type,
    CartVariation cartVariation,
    ProductsCart productsCart,
  ) async {
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/mobileSingleEditForBusinessCart";
    Map data = {
      'user_shop_id': shopId,
      'selected_product_id': productId,
      'selected_variation_id': variationId,
      'type': type,
      'amount_to_change': amountToChange,
      'amount_after_change': amountAfterChange
    };

    var dialog = yyProgressDialogNoBody();

    HttpRequestResponse httpRequestResponse = HttpRequestResponse();

    var body = json.encode(data);

    if (type == "decrement" || type == "delete") {
      cartVariation.addedToCartQuantity -=
          productsCart.productDetails.minimumLot;
    } else if (type == "increment") {
      cartVariation.addedToCartQuantity +=
          productsCart.productDetails.minimumLot;
    }
    _calculateTotalPrice();
    setState(() {});
    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      httpRequestResponse =
          HttpRequestResponse.fromJson(json.decode(response.body));
      if (httpRequestResponse.status == "OK") {
        if (httpRequestResponse.message != "Not valid") {
          print("updated successfully");
          if (type == "delete") {
            _initCartList(dialog);
          }
        } else {
          if (type == "decrement") {
            cartVariation.addedToCartQuantity +=
                productsCart.productDetails.minimumLot;
          } else if (type == "increment") {
            cartVariation.addedToCartQuantity -=
                productsCart.productDetails.minimumLot;
          }
          _calculateTotalPrice();
          print("not enough stock");
          Fluttertoast.showToast(
            msg: "Not enough stock!",
            toastLength: Toast.LENGTH_LONG,
            fontSize: ScreenUtil().setSp(30.0),
          );
        }

        setState(() {});
      } else {
        print("Something went wrong");
      }
    }).catchError((onError) {
      print(onError.toString());
    });
  }

  List<Widget> _createCartList() {
    List<Widget> cartList = List<Widget>();
    for (var item in _wholesaleShopCart) {
      List<Widget> productList = List<Widget>();
      for (var i in item.productsInCart) {
        List<Widget> variationList = List<Widget>();
        for (var j in i.variations) {
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
          variationList.add(
            Row(
              children: <Widget>[
                Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: j.isChecked,
                  onChanged: (bool value) {
                    setState(() {
                      j.isChecked = value;
                      bool isAllTrue = true;
                      for (var x in i.variations) {
                        if (!x.isChecked) {
                          isAllTrue = false;
                        }
                      }
                      if (isAllTrue) {
                        i.isChecked = true;
                      } else {
                        i.isChecked = false;
                      }
                      bool isAllProductTrue = true;
                      for (var y in item.productsInCart) {
                        if (!y.isChecked) {
                          isAllProductTrue = false;
                        }
                      }
                      if (isAllProductTrue) {
                        item.isChecked = true;
                      } else {
                        item.isChecked = false;
                      }
                      bool isAllShopTrue = true;
                      for (var z in _wholesaleShopCart) {
                        if (!z.isChecked) {
                          isAllShopTrue = false;
                        }
                      }
                      if (isAllShopTrue) {
                        _allSelectedChecked = true;
                      } else {
                        _allSelectedChecked = false;
                      }
                    });
                    _calculateTotalPrice();
                  },
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    margin: EdgeInsets.only(
                      top: 10.0,
                      bottom: 10.0,
                      right: 10.0,
                    ),
                    color: Color(0xFFF5F5F5),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    variationName,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40.0),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: !_isEditing,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 2.0,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        text: "RM" + j.price.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: ScreenUtil().setSp(38.0),
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: "/PCS",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            !_isEditing
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                          left: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                          top: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                          bottom: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                        )),
                                        child: SizedBox(
                                          width: 30.0,
                                          height: 30.0,
                                          child: IconButton(
                                            highlightColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            icon: Icon(
                                              Icons.remove,
                                              size: 12.0,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              String status = "";
                                              // TODO: Replace the user shop id with the actual shop id from shared preferences
                                              if (j.addedToCartQuantity -
                                                      i.productDetails
                                                          .minimumLot <=
                                                  0) {
                                                // delete?
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        "Confirm delete?",
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(
                                                            50.0,
                                                          ),
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          50.0),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text(
                                                            'OK',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          45.0),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            _updateCart(
                                                              j.variationId,
                                                              i.productId,
                                                              shopId,
                                                              -i.productDetails
                                                                  .minimumLot,
                                                              j.addedToCartQuantity -
                                                                  i.productDetails
                                                                      .minimumLot,
                                                              "delete",
                                                              j,
                                                              i,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                _updateCart(
                                                  j.variationId,
                                                  i.productId,
                                                  shopId,
                                                  -i.productDetails.minimumLot,
                                                  j.addedToCartQuantity -
                                                      i.productDetails
                                                          .minimumLot,
                                                  "decrement",
                                                  j,
                                                  i,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                        ),
                                        child: SizedBox(
                                          height: 30.0,
                                          width: 60.0,
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                j.addedToCartQuantity
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                          top: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                          bottom: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                        )),
                                        child: SizedBox(
                                          width: 30.0,
                                          height: 30.0,
                                          child: IconButton(
                                            highlightColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            icon: Icon(
                                              Icons.add,
                                              size: 12.0,
                                              color: j.addedToCartQuantity +
                                                          i.productDetails
                                                              .minimumLot <=
                                                      j.stock
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                            onPressed: j.addedToCartQuantity +
                                                        i.productDetails
                                                            .minimumLot <=
                                                    j.stock
                                                ? () {
                                                    _updateCart(
                                                      j.variationId,
                                                      i.productId,
                                                      shopId,
                                                      i.productDetails
                                                          .minimumLot,
                                                      j.addedToCartQuantity +
                                                          i.productDetails
                                                              .minimumLot,
                                                      "increment",
                                                      j,
                                                      i,
                                                    );
                                                  }
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          j.addedToCartQuantity.toString() +
                                              " UNIT",
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(40.0),
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        Visibility(
                          visible: !_isEditing,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 5.0),
                                child: Text(
                                  "Stock: " + j.stock.toString(),
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40.0),
                                    color: Colors.grey,
                                  ),
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
          );
        }
        productList.add(
          Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessBusinessProductDetail(
                        productName: i.productDetails.productName,
                        displayPrice: i.productDetails.priceDisplay,
                        isPreOrder: i.productDetails.isPreOrder,
                        isVariationMode: i.productDetails.isVariationMode,
                        isVariation2Enabled:
                            i.productDetails.isVariation2Enabled,
                        coverImage: i.productDetails.coverImage,
                        productDescription: i.productDetails.productDescription,
                        minimumLot: i.productDetails.minimumLot,
                        productRating: i.productDetails.productRating,
                        productPrice: i.productDetails.productPrice,
                        productId: i.productDetails.productId,
                        isFavourite: i.productDetails.isFavourite,
                        shopName: i.productDetails.shopName,
                        shopRating: i.productDetails.shopRating,
                        shopLogo: i.productDetails.shopLogo,
                        unitSold: i.productDetails.unitSold,
                        productImages: i.productDetails.productImages,
                        extraQuestionForm: i.productDetails.extraQuestionForm,
                        wholesaleDetails: i.productDetails.wholesaleDetails,
                        variations: i.productDetails.variations,
                        daysToShip: i.productDetails.daysToShip,
                        productType: i.productDetails.productType,
                        halalCertImage: i.productDetails.halalCertImage,
                        halalIssueCountry: i.productDetails.halalIssueCountry,
                        numberOfProduct: i.productDetails.numberOfProduct,
                        totalStock: i.productDetails.totalStock,
                        shopOwnerId: i.productDetails.shopOwnerId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: i.isChecked,
                      onChanged: (bool value) {
                        setState(() {
                          i.isChecked = value;
                          for (var x in i.variations) {
                            x.isChecked = value;
                          }
                          bool isAllProductTrue = true;
                          for (var y in item.productsInCart) {
                            if (!y.isChecked) {
                              isAllProductTrue = false;
                            }
                          }
                          if (isAllProductTrue) {
                            item.isChecked = true;
                          } else {
                            item.isChecked = false;
                          }
                          bool isAllShopTrue = true;
                          for (var z in _wholesaleShopCart) {
                            if (!z.isChecked) {
                              isAllShopTrue = false;
                            }
                          }
                          if (isAllShopTrue) {
                            _allSelectedChecked = true;
                          } else {
                            _allSelectedChecked = false;
                          }
                        });
                        _calculateTotalPrice();
                      },
                    ),
                    Row(
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
                              fontSize: ScreenUtil().setSp(45.0),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Column(
                children: variationList,
              )
            ],
          ),
        );
      }
      cartList.add(
        Container(
          margin: EdgeInsets.only(bottom: 15.0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Checkbox(
                            activeColor: Theme.of(context).primaryColor,
                            value: item.isChecked,
                            onChanged: (bool value) {
                              setState(() {
                                item.isChecked = value;
                                for (var x in item.productsInCart) {
                                  x.isChecked = value;
                                  for (var y in x.variations) {
                                    y.isChecked = value;
                                  }
                                }
                                bool isAllShopTrue = true;
                                for (var z in _wholesaleShopCart) {
                                  if (!z.isChecked) {
                                    isAllShopTrue = false;
                                  }
                                }
                                if (isAllShopTrue) {
                                  _allSelectedChecked = true;
                                } else {
                                  _allSelectedChecked = false;
                                }
                              });
                              _calculateTotalPrice();
                            },
                          ),
                          Text(
                            item.shopName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: ScreenUtil().setSp(45.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 1.0),
                  Column(
                    children: productList,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return cartList;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      initPreferences();
    });
  }

  bool _allSelectedChecked = false;

  double _price = 0;

  bool _isChecking = false;

  Future<void> _checkDefaultAddress() {
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/checkBusinessGotDefaultAddress";
    Map data = {'user_shop_id': shopId};
    var body = json.encode(data);
    _isChecking = true;
    setState(() {});
    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      var resp = json.decode(response.body);
      _isChecking = false;
      setState(() {});
      if (resp["status"] == 'OK') {
        if (resp["result"]) {
          // Got default address
          print("proceed checkout");
          print(resp["postal_code"]);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => BusinessCheckOut(
                wholesaleShopList: _wholesaleShopCart,
                fullAddress: resp["full_address"],
                phoneNumber: resp["phone_number"],
                fullName: resp["full_name"],
                state: resp["state"],
                postalCode: resp["postal_code"],
                area: resp["area"],
              ),
            ),
          );
          for (var item in _wholesaleShopCart) {
            for (var i in item.productsInCart) {
              for (var j in i.variations) {
                if (j.isChecked) {
                  for (var x in i.productDetails.shippingOptions) {
                    print(x.toString());
                  }
                }
              }
            }
          }
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "You don't have any address for delivery, setup now!",
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
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(45.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              BusinessAddressScreen(
                            type: "create",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }).catchError((onError) {
      _isChecking = false;
      setState(() {});
      print(onError.toString());
    });
    return null;
  }

  void _calculateTotalPrice() {
    _price = 0;
    for (var item in _wholesaleShopCart) {
      for (var i in item.productsInCart) {
        for (var j in i.variations) {
          if (j.isChecked) {
            // Find the price of the item
            double itemPrice = 0;
            // If got wholesale price
            if (i.productDetails.wholesaleDetails.length > 1) {
              for (int x = 0;
                  x < i.productDetails.wholesaleDetails.length;
                  x++) {
                if (x < i.productDetails.wholesaleDetails.length - 1) {
                  if (j.addedToCartQuantity >=
                          i.productDetails.wholesaleDetails[x].min &&
                      j.addedToCartQuantity <=
                          i.productDetails.wholesaleDetails[x].max) {
                    itemPrice =
                        i.productDetails.wholesaleDetails[x].price.toDouble();
                  }
                } else {
                  if (j.addedToCartQuantity >=
                      i.productDetails.wholesaleDetails[x].min) {
                    itemPrice =
                        i.productDetails.wholesaleDetails[x].price.toDouble();
                  }
                }
              }
            } else {
              itemPrice = j.price.toDouble();
            }
            setState(() {
              _price += j.addedToCartQuantity * itemPrice;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    YYDialog.init(context);

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
          leading: widget.from == 'home'
              ? Container()
              : IconButton(
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
              fontSize: ScreenUtil().setSp(50.0),
              letterSpacing: 0.5,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                _isEditing = !_isEditing;
                for (var item in _wholesaleShopCart) {
                  for (var i in item.productsInCart) {
                    for (var j in i.variations) {
                      j.isChecked = false;
                    }
                    i.isChecked = false;
                  }
                  item.isChecked = false;
                }
                _allSelectedChecked = false;
                _price = 0;
                setState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      _isEditing ? "Done" : "Edit",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(42.0),
                        color: _isEditing ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _wholesaleShopCart.length > 0
                ? Container(
                    child: Column(
                      children: _createCartList(),
                    ),
                  )
                : Container(
                    height: 250.0,
                    child: Center(
                      child: Text(
                        "Nothing in the cart at the moment.",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(45.0),
                        ),
                      ),
                    ),
                  ),
          )
        ],
      ),
      bottomNavigationBar: Container(
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
        // padding: EdgeInsets.all(3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: _allSelectedChecked,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      _allSelectedChecked = value;
                      for (var item in _wholesaleShopCart) {
                        for (var i in item.productsInCart) {
                          for (var j in i.variations) {
                            j.isChecked = value;
                          }
                          i.isChecked = value;
                        }
                        item.isChecked = value;
                      }
                    });
                    _calculateTotalPrice();
                  },
                ),
                Container(
                  child: Text(
                    "Select All",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(43.0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Visibility(
                  visible: !_isEditing,
                  child: Container(
                    child: Text(
                      "Subtotal: ",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(43.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_isEditing,
                  child: Container(
                    margin: EdgeInsets.only(right: 10.0),
                    child: Text(
                      "RM" + _price.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(43.0),
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _price > 0
                      ? () {
                          if (_isEditing) {
                            // Remove
                            var _removeList = [];
                            for (var item in _wholesaleShopCart) {
                              for (var i in item.productsInCart) {
                                for (var j in i.variations) {
                                  if (j.isChecked) {
                                    print(j.variationId);
                                    _removeList.add({
                                      "productId": i.productId,
                                      "variationId": j.variationId,
                                    });
                                  }
                                }
                              }
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Confirm remove?",
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
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(45.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        var dialog = yyProgressDialogNoBody();
                                        _deleteSelectedCartItem(
                                            _removeList, dialog);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Check out
                            _checkDefaultAddress();
                          }
                        }
                      : null,
                  child: Container(
                    height: 50.0,
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    color: _price > 0 && !_isChecking
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    child: Center(
                      child: Text(
                        _isEditing
                            ? "Remove"
                            : _isChecking ? "Checking" : "Check Out",
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
            )
          ],
        ),
      ),
    );
  }
}
