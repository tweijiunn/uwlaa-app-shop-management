import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwlaa/model/business_product.dart';
import 'package:uwlaa/model/slider.dart' as prefix0;
import 'package:uwlaa/screen/business_business_product_details.dart';
import 'package:uwlaa/util/ui_icons.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'business_cart.dart';

class BusinessBusinessHome extends StatefulWidget {
  BusinessBusinessHome({Key key}) : super(key: key);

  @override
  _BusinessBusinessHomeState createState() => _BusinessBusinessHomeState();
}

class _BusinessBusinessHomeState extends State<BusinessBusinessHome> {
  final RefreshController _refreshController = RefreshController();

  List<prefix0.Slider> _sliderList = [];
  int _selectedBottomIndex = 0;

  String shopId = "";
  String shopLogo = "";

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

  Future<bool> _onBackPressed() {
    FlutterStatusbarcolor.setStatusBarColor(Theme.of(context).primaryColor);
    Navigator.pop(context);
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  List<BusinessProduct> _productList = List<BusinessProduct>();

  Future<void> _getAllProducts(YYDialog dialog) async {
    var url =
        "https://us-central1-uwlaamart.cloudfunctions.net/httpFunction/api/v1/mobileGetAllWholesaleProducts";
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
            List<ExtraQuestion> _extraQuestionList = List<ExtraQuestion>();
            List<WholesaleDetail> _wholeSaleList = List<WholesaleDetail>();
            List<Variations> _variationList = List<Variations>();
            var isPreOrder = item["is_pre_order"];
            var isVariationMode = item["is_variation_mode"];
            var isVariation2Enabled = item["is_variation2_enabled"];
            var productName = item["product_name"];
            var coverImage = item["cover_image"];
            var productDescription = item["product_description"];
            var minimumLot = item["minimum_lot"];
            var productRating = item["product_rating"];
            var productPrice = item["product_price"];
            var productId = item["id"];
            var isFavourite = item["is_favourite"];
            var priceDisplay = item["price_display"];
            var shopName = item["shop_name"];
            var shopRating = item["shop_rating"];
            var shopLogo = item["shop_logo"];
            var unitSold = item["unit_sold"];
            var productImages = item["product_images"];
            var extraQuestionForm = item["extra_question_form"];
            for (var i in extraQuestionForm) {
              var title, answer;
              title = i["title"];
              answer = i["answer"];
              _extraQuestionList
                  .add(ExtraQuestion(title: title, answer: answer));
            }
            var wholesaleDetails = item["wholesale_details"];
            for (var i in wholesaleDetails) {
              var min = i["min"];
              var max = i["max"];
              var price = i["price"];
              _wholeSaleList
                  .add(WholesaleDetail(min: min, max: max, price: price));
            }
            var variations = item["variation_list"];
            for (var i in variations) {
              var variationName1 = i["variation_name_1"];
              var variationName2 = i["variation_name_2"];
              var stock = i["stock"];
              var price = i["price"];
              var imageUrl = i["image_url"];
              var quantity = i["quantity"];
              var tag = i["tag"];
              var variationId = i["variation_id"];
              var addedToCartQuantity = i["added_to_cart_quantity"];
              _variationList.add(Variations(
                variationName1: variationName1,
                variationName2: variationName2,
                stock: stock,
                price: price,
                imageUrl: imageUrl,
                quantity: quantity,
                tag: tag,
                variationId: variationId,
                addedToCartQuantity: addedToCartQuantity,
              ));
            }
            var daysToShip = item["days_to_ship"];
            var productType = item["product_type"];
            var halalCertImage = item["halal_cert_image"];
            var halalIssueCountry = item["halal_certificate_issue_country"];
            var numberOfProduct = item["shop_number_of_product"];
            var totalStock = item["total_stock"];
            var shopOwnerId = item["shop_owner_id"];
            _productList.add(BusinessProduct(
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
              daysToShip: daysToShip,
              productType: productType,
              halalCertImage: halalCertImage,
              halalIssueCountry: halalIssueCountry,
              numberOfProduct: numberOfProduct,
              totalStock: totalStock,
              shopOwnerId: shopOwnerId,
            ));
          }
        } else {
          print("error");
        }
      });
    }).catchError((onError) {
      print(onError.toString());
    });
  }

  initPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    shopId = prefs.getString('shop_id');
    shopLogo = prefs.getString('shop_logo');
    print("shopLogo " + shopLogo);
    setState(() {});
    var dialog = yyProgressDialogNoBody();
    _getAllProducts(dialog);
  }

  Widget _buildCategory(String categoryName, IconData iconData) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {},
        child: Container(
          width: 80.0,
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            children: <Widget>[
              Icon(iconData),
              Container(
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(46.0),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      initPreferences();
    });

    _sliderList.add(prefix0.Slider(
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/uwlaamart.appspot.com/o/app_carousel_images%2Fdevelopment%2Fcarousel_2.jpg?alt=media",
      linkTo:
          "https://firebasestorage.googleapis.com/v0/b/uwlaamart.appspot.com/o/app_carousel_images%2Fdevelopment%2Fcarousel_2.jpg?alt=media",
    ));
    _sliderList.add(prefix0.Slider(
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/uwlaamart.appspot.com/o/app_carousel_images%2Fdevelopment%2Fcarousel_3.jpg?alt=media",
      linkTo:
          "https://firebasestorage.googleapis.com/v0/b/uwlaamart.appspot.com/o/app_carousel_images%2Fdevelopment%2Fcarousel_3.jpg?alt=media",
    ));
    _sliderList.add(prefix0.Slider(
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/uwlaamart.appspot.com/o/app_carousel_images%2Fdevelopment%2Fcarousel_4.png?alt=media",
      linkTo:
          "https://firebasestorage.googleapis.com/v0/b/uwlaamart.appspot.com/o/app_carousel_images%2Fdevelopment%2Fcarousel_4.png?alt=media",
    ));
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    YYDialog.init(context);

    Widget businessHomeWidget = SafeArea(
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: MaterialClassicHeader(
          color: Colors.orange,
          backgroundColor: Colors.white,
        ),
        onRefresh: () async {
          _refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    height: 162.0,
                    viewportFraction: 1.0,
                  ),
                  items: _sliderList.map((prefix0.Slider slider) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            // color: Colors.amber,
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
              ),
            ),
            SliverStickyHeader(
              header: Container(
                margin: EdgeInsets.only(bottom: 10.0),
                color: Colors.white,
                height: 60.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _buildCategory("Home", UiIcons.gift),
                    _buildCategory("Food", UiIcons.bakery),
                    _buildCategory("Furniture", UiIcons.living_room),
                    _buildCategory("Shoes", UiIcons.shoe_1),
                    _buildCategory("Sport", UiIcons.sport),
                    _buildCategory("Watch", UiIcons.watch),
                    _buildCategory("Travel", UiIcons.tent),
                    _buildCategory("Child", UiIcons.baby_changing),
                    _buildCategory("Tool", UiIcons.tool),
                  ],
                ),
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      margin: index % 2 == 0
                          ? EdgeInsets.only(left: 10.0)
                          : EdgeInsets.only(right: 10.0),
                      child: Card(
                        elevation: 0.0,
                        semanticContainer: true,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BusinessBusinessProductDetail(
                                  productName: _productList[index].productName,
                                  displayPrice:
                                      _productList[index].priceDisplay,
                                  isPreOrder: _productList[index].isPreOrder,
                                  isVariationMode:
                                      _productList[index].isVariationMode,
                                  isVariation2Enabled:
                                      _productList[index].isVariation2Enabled,
                                  coverImage: _productList[index].coverImage,
                                  productDescription:
                                      _productList[index].productDescription,
                                  minimumLot: _productList[index].minimumLot,
                                  productRating:
                                      _productList[index].productRating,
                                  productPrice:
                                      _productList[index].productPrice,
                                  productId: _productList[index].productId,
                                  isFavourite: _productList[index].isFavourite,
                                  shopName: _productList[index].shopName,
                                  shopRating: _productList[index].shopRating,
                                  shopLogo: _productList[index].shopLogo,
                                  unitSold: _productList[index].unitSold,
                                  productImages:
                                      _productList[index].productImages,
                                  extraQuestionForm:
                                      _productList[index].extraQuestionForm,
                                  wholesaleDetails:
                                      _productList[index].wholesaleDetails,
                                  variations: _productList[index].variations,
                                  daysToShip: _productList[index].daysToShip,
                                  productType: _productList[index].productType,
                                  halalCertImage:
                                      _productList[index].halalCertImage,
                                  halalIssueCountry:
                                      _productList[index].halalIssueCountry,
                                  numberOfProduct:
                                      _productList[index].numberOfProduct,
                                  totalStock: _productList[index].totalStock,
                                  shopOwnerId: _productList[index].shopOwnerId,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 200.0,
                                child: Image(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    _productList[index].coverImage,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _productList[index].productName.length > 40
                                        ? _productList[index]
                                            .productName
                                            .replaceRange(
                                              40,
                                              _productList[index]
                                                  .productName
                                                  .length,
                                              "...",
                                            )
                                        : _productList[index].productName,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 100.0,
                                  margin: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  padding: EdgeInsets.only(
                                    left: 5.0,
                                    right: 5.0,
                                    top: 3.0,
                                    bottom: 3.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: _productList[index].productType ==
                                            "muslim_friendly"
                                        ? Color(0xFF43A047)
                                        : Color(0xFF01579B),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _productList[index].productType ==
                                              "muslim_friendly"
                                          ? "Muslim Friendly"
                                          : "Halal Certified",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(30.0),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 5.0,
                                  bottom: 10.0,
                                  left: 10.0,
                                  right: 10.0,
                                ),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _productList[index].priceDisplay,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: ScreenUtil().setSp(40.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                ),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    _productList[index].unitSold.toString() +
                                        " Sold",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(35.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   child: Container(
                              //     margin: EdgeInsets.only(
                              //       left: 10.0,
                              //       // bottom: 10.0,
                              //       right: 10.0,
                              //     ),
                              //     child: Row(
                              //       children: <Widget>[
                              //         Expanded(
                              //           child: RaisedButton(
                              //             elevation: 0.0,
                              //             onPressed: () {},
                              //             color: Colors.red,
                              //             child: Text(
                              //               'Purchase Now',
                              //               style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize:
                              //                     ScreenUtil().setSp(42.0),
                              //                 fontWeight: FontWeight.w600,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _productList.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.58,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(_selectedBottomIndex == 2 ? 0.0 : 50.0),
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
              'Wholesale',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: ScreenUtil().setSp(55.0),
                letterSpacing: 0.5,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: InkWell(
                  child: Icon(
                    Icons.search,
                    color: Color(0xFF000000),
                  ),
                ),
                onPressed: null,
              )
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedBottomIndex,
          children: <Widget>[
            businessHomeWidget,
            Container(),
            BusinessCart(
              from: 'home',
            ),
            Container(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.black87,
          currentIndex: _selectedBottomIndex,
          onTap: _onBottomNavTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(UiIcons.home),
              title: Text(
                "Home",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(UiIcons.layers),
              title: Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(UiIcons.shopping_cart),
              title: Text(
                "Cart",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(UiIcons.user_3),
              title: Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
