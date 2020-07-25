import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwlaa/model/business_product.dart';
import 'package:uwlaa/model/http_request_response.dart';
import 'package:uwlaa/model/product_category_list.dart';
import 'package:uwlaa/model/slider.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uwlaa/screen/business_cart.dart';
import 'package:http/http.dart' as http;
import 'package:uwlaa/screen/consumer_cart.dart';
import 'package:uwlaa/util/ui_icons.dart';



class ShopProducts extends StatefulWidget {
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



  ShopProducts({
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
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopProductsState();
  }

}

class ShopProductsState extends State<ShopProducts> {
  //initialization variable
  final RefreshController _refreshController = RefreshController();
  List<prefix0.Slider> _sliderList = [];

  int _numberOfVariation = 0;
  List<String> _variationImageList = [];
  int _selectedBottomIndex = 0;
  int _selectedCategoryIndex=0;

  String shopID= "";
  String shopName="";
  String shopLogo="";
  int shopRating=2;
  String userId = "";
  String fullName = "";
  String signupType = "";
  String email = "";

  List<bool> _selected = List.generate(20, (i) => false);

  List<BusinessProduct> _productList = List<BusinessProduct>();
  List<String> layer1CategoryList1=List<String>();
  List<String> layer2CategoryList1=List<String>();
  List<String> layer3CategoryList1=List<String>();

  Widget _buildCategory(String categoryName,String sortName,bool _pressed,int index) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _onCategoryNavTapped(index);
            _selected[index]= !_selected[index];
          });
          _sortProduct(sortName);

        },
        child: Container(
          width: 80.0,
          padding: EdgeInsets.only(top: 10.0),
          child: Column(

            children: <Widget>[
              Container(
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(46.0),
                    fontWeight: _selected[index] ? FontWeight.w800:FontWeight.w500,
                    letterSpacing: 0.5,
                    color: _selected[index] ? Theme.of(context).primaryColor : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //BorderDesign
  SizedBox borderLine=  SizedBox(width: 20,
      child:Container(
        decoration: BoxDecoration(
            border:Border(
                right: BorderSide(
                  color: Colors.grey,
                  width: 0.3,
                )
            )
        ),
      ));

  Row ratingBar= Row(
    children: <Widget>[
      Icon(Icons.star,size: 15,color: Colors.yellow),
    ],
  );
  //set default value;
  String dropdownValue = 'All';
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
                color: Colors.blue[600],
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.3,
                //shop cover image
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width*0.2,
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          height: 70,
                          width: 70,
                          alignment: Alignment.center,
                          child: CircleAvatar(
                              backgroundImage: NetworkImage(shopLogo)
                          )
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              shopName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 0,
                            ),
                            Row(
                              children: <Widget>[
                                ratingBar,
                                /*Row(
                                  children: <Widget>[
                                    //display Rating
                                    *//*RatingBar(
                                      itemSize: 15,
                                      initialRating: shopRating,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                      onRatingUpdate: (rating){

                                      },
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ),*//*

                                  ],
                                ),*/
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "Follower 7.4k | Following 0",
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                InkWell(
                                  child: ButtonTheme(
                                    minWidth:80.0,
                                    height: 30.0,

                                    child: RaisedButton(
                                      elevation: 0,
                                      onPressed: () {},
                                      color: Theme.of(context).primaryColor,
                                      child:Row(
                                        children: <Widget>[
                                          Text(
                                            "+ Follow",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(30.0),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),


                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                InkWell(

                                  child: ButtonTheme(
                                    minWidth:80.0,
                                    height: 30.0,

                                    child: RaisedButton(
                                      elevation: 0,
                                      onPressed: () {},
                                      color: Theme.of(context).primaryColor,
                                      child:Row(
                                        children: <Widget>[
                                          Icon(Icons.chat,size: 15,color: Colors.white),
                                          SizedBox(width: 5,),
                                          Text(
                                            "Chat",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(30.0),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),


                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0,
                    ),
                  ],
                ),


              )
            ),
            SliverStickyHeader(
              header: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 2,
                        spreadRadius: .2,
                      ),
                    ]
                ),
                height: 40.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
/*                    SizedBox(width: 20),
                    _buildCategory("Promotion","promotion",false,1),*/
                    SizedBox(width: 20),
                    _buildCategory("Shop","shop",true,1),
                    SizedBox(width: 20),
                    _buildCategory("Products","products",true,2),
                    SizedBox(width: 20),
                    DropdownButton<String>(
                      value:dropdownValue,
                      icon:Icon(Icons.arrow_drop_down),
                      iconSize: 20,
                      elevation: 150,
                      style: TextStyle(color:Colors.black,
                          fontSize: ScreenUtil().setSp(40.0)),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue=newValue;
                    });
                  },
                      items: layer3CategoryList1
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 20),
                    SizedBox(width: 20),
                  ],
                ),
              ),
              // sliver: SliverGrid.count(
              //   crossAxisCount: 2,
              //   crossAxisSpacing: 3.0,
              //   mainAxisSpacing: 10.0,
              //   childAspectRatio: 0.55,
              //   children: _productListing,
              // ),
            ),
            SliverStickyHeader(
              header: Container(
                margin: EdgeInsets.only(bottom: 10.0),
                color: Colors.white,
                height: 40.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[

/*                    _buildCategory("Popular","popular",false,4),
                    SizedBox(width: 20),*/
                    SizedBox(width: 20),
                    _buildCategory("Latest","latest",true,5),
                    borderLine,
                    _buildCategory("Top Sales","topSales",false,6),
                    borderLine,
                    _buildCategory("Price","price",false,7),
                  ],
                ),
              ),
              // sliver: SliverGrid.count(
              //   crossAxisCount: 2,
              //   crossAxisSpacing: 3.0,
              //   mainAxisSpacing: 10.0,
              //   childAspectRatio: 0.55,
              //   children: _productListing,
              // ),
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
                                    ShopProducts(
                                      productName: _productList[index]
                                          .productName,
                                      displayPrice:
                                      _productList[index].priceDisplay,
                                      isPreOrder: _productList[index]
                                          .isPreOrder,
                                      isVariationMode:
                                      _productList[index].isVariationMode,
                                      isVariation2Enabled:
                                      _productList[index].isVariation2Enabled,
                                      coverImage: _productList[index]
                                          .coverImage,
                                      productDescription:
                                      _productList[index].productDescription,
                                      minimumLot: _productList[index]
                                          .minimumLot,
                                      productRating:
                                      _productList[index].productRating,
                                      productPrice:
                                      _productList[index].productPrice,
                                      productId: _productList[index].productId,
                                      isFavourite: _productList[index]
                                          .isFavourite,
                                      shopName: _productList[index].shopName,
                                      shopRating: _productList[index]
                                          .shopRating,
                                      shopLogo: _productList[index].shopLogo,
                                      unitSold: _productList[index].unitSold,
                                      productImages:
                                      _productList[index].productImages,
                                      extraQuestionForm:
                                      _productList[index].extraQuestionForm,
                                      wholesaleDetails:
                                      _productList[index].wholesaleDetails,
                                      variations: _productList[index]
                                          .variations,
                                      daysToShip: _productList[index]
                                          .daysToShip,
                                      productType: _productList[index]
                                          .productType,
                                      halalCertImage:
                                      _productList[index].halalCertImage,
                                      halalIssueCountry:
                                      _productList[index].halalIssueCountry,
                                      numberOfProduct:
                                      _productList[index].numberOfProduct,
                                      totalStock: _productList[index]
                                          .totalStock,
                                      shopOwnerId: _productList[index]
                                          .shopOwnerId,
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 180.0,
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
                    Theme
                        .of(context)
                        .primaryColor);
              },
            ),
            title: Text(
              'Shopping Mall',
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
            businessHomeWidget,
            // BusinessCart(
            //   from: 'home',
            // ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Theme
              .of(context)
              .primaryColor,
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
            // BottomNavigationBarItem(
            //   icon: Icon(UiIcons.shopping_cart),
            //   title: Text(
            //     "Cart",
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            // ),
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


  @override
  void initState() {
    super.initState();

    initPreferences() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      shopID = prefs.getString('shop_id');
      shopName = prefs.getString('shop_name');
      shopLogo = prefs.getString('shop_logo');
      userId = prefs.getString('user_id');
      fullName = prefs.getString('name');
      email = prefs.getString('email');
      signupType = prefs.getString('signup_type');


      //add default category
      layer1CategoryList1.add('All');
      layer2CategoryList1.add('All');
      layer3CategoryList1.add('All');
      var dialog = yyProgressDialogNoBody();
      _getCategoryName();
      _getShopProducts(dialog);

    }

     Future.delayed(Duration.zero).then((value) {
      initPreferences();

    });


  }

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
    FlutterStatusbarcolor.setStatusBarColor(Theme
        .of(context)
        .primaryColor);
    Navigator.pop(context);
  }

  BusinessProductList _businessProductList = BusinessProductList(
    status: "",
    businessProductList: [],
  );


  CategoryList _categoryList= CategoryList(
    status: "",
    productCategoryList: [],
  );

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  void _onCategoryNavTapped(int index){
    setState(() {
      _selectedCategoryIndex = index;
      print(_selectedCategoryIndex);
    });
  }






  Future<void> _getShopProducts(YYDialog dialog) async {
    dialog.show();
    _productList.clear();
    var queryParameters = {"user_id": userId,"shop_id":shopID};
    print("user_id " + userId);
    print("shop_id " + shopID);
    HttpClient()
        .postUrl(Uri.https(
        'us-central1-uwlaamart.cloudfunctions.net',
        '/shopManagementFunction/api/v1/mobileGetShopProducts',
        queryParameters))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) {
      response
          .transform(Utf8Decoder())
          .transform(json.decoder)
          .listen((contents) {
        setState(() {
          _businessProductList = BusinessProductList.fromJson(contents);
          if (_businessProductList.status == 'OK') {
            if (_businessProductList.businessProductList.length > 0) {

              for (var item in _businessProductList.businessProductList) {
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
                    shopRating1,
                    shopLogo,
                    unitSold,
                    productImages,
                    extraQuestionForm,
                    wholesaleDetails,
                    variations,
                    daysToShip,
                    productType,
                    halalCertImage,
                    halalIssueCountry,
                    numberOfProduct,
                    totalStock,
                    shopOwnerId
                    /*productCategory*/;
                List<ExtraQuestion> _extraQuestionList = List<ExtraQuestion>();
                List<WholesaleDetail> _wholeSaleList = List<WholesaleDetail>();
                List<Variations> _variationList = List<Variations>();
                for (String key in item.keys) {
                  if (key == "is_pre_order") {
                    isPreOrder = item[key];
                  } else if (key == "is_variation_mode") {
                    isVariationMode = item[key];
                  } else if (key == "is_variation2_enabled") {
                    isVariation2Enabled = item[key];
                  } else if (key == "product_name") {
                    productName = item[key];
                  } else if (key == "cover_image") {
                    coverImage = item[key];
                  } else if (key == "product_description") {
                    productDescription = item[key];
                  } else if (key == "minimum_lot") {
                    minimumLot = item[key];
                  } else if (key == "product_rating") {
                    productRating = item[key];
                  } else if (key == "product_price") {
                    productPrice = item[key];
                  } else if (key == "id") {
                    productId = item[key];
                  } else if (key == "is_favourite") {
                    isFavourite = item[key];
                  } else if (key == "price_display") {
                    priceDisplay = item[key];
                  } else if (key == "shop_name") {
                    shopName = item[key];
                  } else if (key == "shop_rating") {
                    shopRating1 = item[key];
                  } else if (key == "shop_logo") {
                    shopLogo = item[key];
                  } else if (key == "unit_sold") {
                    unitSold = item[key];
                  } else if (key == "product_images") {
                    productImages = item[key];
                  } else if (key == "extra_question_form") {
                    extraQuestionForm = item[key];
                    for (var i in extraQuestionForm) {
                      var title, answer;
                      for (String key1 in i.keys) {
                        if (key1 == "title") {
                          title = i[key1];
                        } else if (key1 == "answer") {
                          answer = i[key1];
                        }
                      }
                      _extraQuestionList
                          .add(ExtraQuestion(title: title, answer: answer));
                    }
                  } else if (key == "wholesale_details") {
                    wholesaleDetails = item[key];
                    for (var i in wholesaleDetails) {
                      var min, max, price;
                      for (String key1 in i.keys) {
                        if (key1 == "min") {
                          min = i[key1];
                        } else if (key1 == "max") {
                          max = i[key1];
                        } else if (key1 == "price") {
                          price = i[key1];
                        }
                      }
                      _wholeSaleList.add(
                          WholesaleDetail(min: min, max: max, price: price));
                    }
                  } else if (key == "variation_list") {
                    variations = item[key];
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
                      for (String key1 in i.keys) {
                        if (key1 == "variation_name_1") {
                          variationName1 = i[key1];
                        } else if (key1 == "variation_name_2") {
                          variationName2 = i[key1];
                        } else if (key1 == "stock") {
                          stock = i[key1];
                        } else if (key1 == "price") {
                          price = i[key1];
                        } else if (key1 == "image_url") {
                          imageUrl = i[key1];
                        } else if (key1 == "quantity") {
                          quantity = i[key1];
                        } else if (key1 == "tag") {
                          tag = i[key1];
                        } else if (key1 == "variation_id") {
                          variationId = i[key1];
                        } else if (key1 == "added_to_cart_quantity") {
                          addedToCartQuantity = i[key1];
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
                  } else if (key == "days_to_ship") {
                    daysToShip = item[key];
                  } else if (key == "product_type") {
                    productType = item[key];
                  } else if (key == "halal_cert_image") {
                    halalCertImage = item[key];
                  } else if (key == "halal_certificate_issue_country") {
                    halalIssueCountry = item[key];
                  } else if (key == "shop_number_of_product") {
                    numberOfProduct = item[key];
                  } else if (key == "total_stock") {
                    totalStock = item[key];
                  } else if (key == "shop_owner_id") {
                    shopOwnerId = item[key];
                  }
                  /*else if(key=="category_id"){
                      productCategory= item[key];
                  }*/
                }


                shopRating=shopRating1;

                _productList.add(
                  BusinessProduct(
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
                  ),
                );
              }
              dialog.dismiss();
            } else {
              dialog.dismiss();
              // No product at the moment
            }
          }


            if(shopRating==0){
              ratingBar= Row(
                children: <Widget>[
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                ],
              );
            }
            else if(shopRating==1){
              ratingBar= Row(
                children: <Widget>[
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                ],
              );
            }
            else if(shopRating==2){
              ratingBar= Row(
                children: <Widget>[
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                ],
              );
            }
            else if(shopRating==3){
              ratingBar= Row(
                children: <Widget>[
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                ],
              );
            }
            else if(shopRating==4){
              ratingBar= Row(
                children: <Widget>[
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.grey),
                ],
              );
            }
            else if(shopRating==5){
              ratingBar= Row(
                children: <Widget>[
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                  Icon(Icons.star,size: 15,color: Colors.yellow),
                ],
              );
            }

        });
      });
    });
  }

  Future<void> _sortProduct(String sortName) async {

    String functionURL='';
    _productList.clear();
    if(sortName=="price"){
      functionURL='/shopManagementFunction/api/v1/mobileSortProductByPrice';
    }
    else if(sortName=="latest"){
      functionURL='/shopManagementFunction/api/v1/mobileSortProductByTime';
    }
    else if(sortName=="topSales"){
      functionURL='/shopManagementFunction/api/v1/mobileGetShopProducts';
    }
    else{
      functionURL='/shopManagementFunction/api/v1/mobileGetShopProducts';
    }
    var queryParameters = {"user_id": userId,"shop_id":shopID};
    print("user_id " + userId);
    print("shop_id " + shopID);
    HttpClient()
        .postUrl(Uri.https(
        'us-central1-uwlaamart.cloudfunctions.net',
        functionURL,
        queryParameters))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) {
      response
          .transform(Utf8Decoder())
          .transform(json.decoder)
          .listen((contents) {
        setState(() {
          _businessProductList = BusinessProductList.fromJson(contents);
          if (_businessProductList.status == 'OK') {
            if (_businessProductList.businessProductList.length > 0) {

              for (var item in _businessProductList.businessProductList) {
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
                    halalIssueCountry,
                    numberOfProduct,
                    totalStock,
                    shopOwnerId;
                List<ExtraQuestion> _extraQuestionList = List<ExtraQuestion>();
                List<WholesaleDetail> _wholeSaleList = List<WholesaleDetail>();
                List<Variations> _variationList = List<Variations>();
                for (String key in item.keys) {
                  if (key == "is_pre_order") {
                    isPreOrder = item[key];
                  } else if (key == "is_variation_mode") {
                    isVariationMode = item[key];
                  } else if (key == "is_variation2_enabled") {
                    isVariation2Enabled = item[key];
                  } else if (key == "product_name") {
                    productName = item[key];
                  } else if (key == "cover_image") {
                    coverImage = item[key];
                  } else if (key == "product_description") {
                    productDescription = item[key];
                  } else if (key == "minimum_lot") {
                    minimumLot = item[key];
                  } else if (key == "product_rating") {
                    productRating = item[key];
                  } else if (key == "product_price") {
                    productPrice = item[key];
                  } else if (key == "id") {
                    productId = item[key];
                  } else if (key == "is_favourite") {
                    isFavourite = item[key];
                  } else if (key == "price_display") {
                    priceDisplay = item[key];
                  } else if (key == "shop_name") {
                    shopName = item[key];
                  } else if (key == "shop_rating") {
                    shopRating = item[key];
                  } else if (key == "shop_logo") {
                    shopLogo = item[key];
                  } else if (key == "unit_sold") {
                    unitSold = item[key];
                  } else if (key == "product_images") {
                    productImages = item[key];
                  } else if (key == "extra_question_form") {
                    extraQuestionForm = item[key];
                    for (var i in extraQuestionForm) {
                      var title, answer;
                      for (String key1 in i.keys) {
                        if (key1 == "title") {
                          title = i[key1];
                        } else if (key1 == "answer") {
                          answer = i[key1];
                        }
                      }
                      _extraQuestionList
                          .add(ExtraQuestion(title: title, answer: answer));
                    }
                  } else if (key == "wholesale_details") {
                    wholesaleDetails = item[key];
                    for (var i in wholesaleDetails) {
                      var min, max, price;
                      for (String key1 in i.keys) {
                        if (key1 == "min") {
                          min = i[key1];
                        } else if (key1 == "max") {
                          max = i[key1];
                        } else if (key1 == "price") {
                          price = i[key1];
                        }
                      }
                      _wholeSaleList.add(
                          WholesaleDetail(min: min, max: max, price: price));
                    }
                  } else if (key == "variation_list") {
                    variations = item[key];
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
                      for (String key1 in i.keys) {
                        if (key1 == "variation_name_1") {
                          variationName1 = i[key1];
                        } else if (key1 == "variation_name_2") {
                          variationName2 = i[key1];
                        } else if (key1 == "stock") {
                          stock = i[key1];
                        } else if (key1 == "price") {
                          price = i[key1];
                        } else if (key1 == "image_url") {
                          imageUrl = i[key1];
                        } else if (key1 == "quantity") {
                          quantity = i[key1];
                        } else if (key1 == "tag") {
                          tag = i[key1];
                        } else if (key1 == "variation_id") {
                          variationId = i[key1];
                        } else if (key1 == "added_to_cart_quantity") {
                          addedToCartQuantity = i[key1];
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
                  } else if (key == "days_to_ship") {
                    daysToShip = item[key];
                  } else if (key == "product_type") {
                    productType = item[key];
                  } else if (key == "halal_cert_image") {
                    halalCertImage = item[key];
                  } else if (key == "halal_certificate_issue_country") {
                    halalIssueCountry = item[key];
                  } else if (key == "shop_number_of_product") {
                    numberOfProduct = item[key];
                  } else if (key == "total_stock") {
                    totalStock = item[key];
                  } else if (key == "shop_owner_id") {
                    shopOwnerId = item[key];
                  }
                }

                /*shop_name=shopName;
                shop_rating=shopRating;
                shop_logo_url=shopLogo;
                print(shop_logo_url);*/

                _productList.add(
                  BusinessProduct(
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
                  ),
                );
              }
              //rearrange the tap sale based on unit sold in descending order
              if(sortName=="topSales"){
                _productList.sort((b,a)=>a.unitSold.compareTo(b.unitSold));
              }

            } else {

              // No product at the moment
            }
          }
        });
      });
    });
  }

  Future<void> _getCategoryName() async {
    HttpClient()
        .postUrl(Uri.https(
        'us-central1-uwlaamart.cloudfunctions.net',
        '/shopManagementFunction/api/v1/getAllProductCategory'))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) {
      response
          .transform(Utf8Decoder())
          .transform(json.decoder)
          .listen((contents) {
        setState(() {
          _categoryList = CategoryList.fromJson(contents);
          if (_categoryList.status == 'OK') {
             if(_categoryList.productCategoryList.length>0){

               //1st Layer Category
               for(var item in _categoryList.productCategoryList){
                  var layer1categoryID,
                      layer1CategoryName,
                      layer2CategoryList;
                  for(String key in item.keys){
                    if(key=="id"){
                      layer1categoryID=item[key];
                    }
                    else if(key=="title"){
                      layer1CategoryName=item[key];
                    }
                    else if(key=="children"){

                      //Second Layer Category
                      layer2CategoryList=item[key];
                      for(var i in layer2CategoryList){
                        var layer2categoryID,
                            layer2CategoryName,
                            layer3CategoryList;
                        for(String key1 in i.keys){
                          if(key1=="id"){
                            layer2categoryID=item[key1];
                          }
                          else if(key1=="title"){
                            layer2CategoryName=item[key1];
                          }
                          else if(key1=="children"){

                            //Third Layer Category
                            layer3CategoryList=item[key1];
                            for(var idx in layer3CategoryList){
                              var layer3categoryID,
                                  layer3CategoryName;
                              for(String key2 in idx.keys){
                                if(key2=="id"){
                                  layer3categoryID=item[key2];
                                }
                                else if(key2=="title"){
                                  layer3CategoryName=item[key2];
                                }
                              }
                              if(!layer3CategoryList1.contains(layer3CategoryName)){
                                layer3CategoryList1.add(layer3CategoryName);
                              }
                            }
                          }
                        }
                        if(!layer2CategoryList1.contains(layer2CategoryName)&&layer2CategoryName!=null){
                          layer2CategoryList1.add(layer2CategoryName);
                          print("Layer2"+layer2CategoryName);
                        }
                      }
                    }

                  }
                  if(!layer1CategoryList1.contains(layer1CategoryName)&&layer1CategoryName!=null){
                    layer1CategoryList1.add(layer1CategoryName);
                    print("Layer1"+ layer1CategoryName);
                  }
               }
             }
          }

        });
      });
    });
  }


}

