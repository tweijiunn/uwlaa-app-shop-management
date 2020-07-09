import 'package:uwlaa/model/business_product.dart';

class BusinessCartList {
  final List<dynamic> cartList;
  final String status;

  BusinessCartList({this.status, this.cartList});

  factory BusinessCartList.fromJson(Map<String, dynamic> json) {
    return new BusinessCartList(
        status: json["status"], cartList: json["result"]);
  }
}

class WholesaleShopCart {
  final String shopName;
  final String shopId;
  bool isChecked;
  final List<ProductsCart> productsInCart;

  WholesaleShopCart(
      {this.shopName, this.shopId, this.productsInCart, this.isChecked});

  factory WholesaleShopCart.fromJson(Map<String, dynamic> json) {
    return new WholesaleShopCart(
      shopName: json["shop_name"],
      shopId: json["shop_id"],
      isChecked: json["is_checked"],
      productsInCart: json['products_in_cart'],
    );
  }
}

class ProductsCart {
  final String productId;
  final List<CartVariation> variations;
  final BusinessProduct productDetails;
  bool isChecked;

  ProductsCart({
    this.productId,
    this.variations,
    this.productDetails,
    this.isChecked,
  });

  factory ProductsCart.fromJson(Map<String, dynamic> json) {
    return ProductsCart(
        productId: json["product_id"],
        variations: json['variations'],
        productDetails: json['product_details'],
        isChecked: json['is_checked']);
  }

  @override
  String toString() {
    String response = "{ productId: $productId, variations: ";
    for (int i = 0; i < variations.length; i++) {
      if (i == 0 && i == variations.length - 1) {
        response += "wholesaleDetails: [ " + variations[i].toString() + " ], ";
      } else if (i == 0) {
        response += "wholesaleDetails: [ " + variations[i].toString() + ", ";
      } else if (i == variations.length - 1) {
        response += variations[i].toString() + " ], ";
      } else {
        response += variations[i].toString() + ", ";
      }
    }
    response += "productDetails: " + productDetails.toString() + " },";
    return response;
  }
}

class CartVariation {
  final String variationId;
  var addedToCartQuantity;
  final String status;
  var stock;
  var price;
  bool isChecked;

  CartVariation({
    this.variationId,
    this.addedToCartQuantity,
    this.status,
    this.stock,
    this.price,
    this.isChecked,
  });

  factory CartVariation.fromJson(Map<String, dynamic> json) {
    return CartVariation(
      variationId: json["variation_id"],
      addedToCartQuantity: json['added_to_cart_quantity'],
      status: json['status'],
      stock: json['stock'],
      price: json['price'],
      isChecked: json['is_checked'],
    );
  }

  @override
  String toString() {
    var response =
        "{ variationId: $variationId, addedToCartQuantity: $addedToCartQuantity, status: $status, stock: $stock, price: $price }";
    return response;
  }
}
