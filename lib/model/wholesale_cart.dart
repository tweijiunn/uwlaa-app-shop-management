import 'package:uwlaa/model/business_product.dart';

class BusinessCartList {
  final List<dynamic> businessCartList;
  final String status;

  BusinessCartList({this.status, this.businessCartList});

  factory BusinessCartList.fromJson(Map<String, dynamic> json) {
    return new BusinessCartList(
        status: json["status"], businessCartList: json["result"]);
  }
}

class WholesaleShopCart {
  final String shopName;
  final String shopId;
  final List<ProductsCart> productsInCart;

  WholesaleShopCart({this.shopName, this.shopId, this.productsInCart});

  factory WholesaleShopCart.fromJson(Map<String, dynamic> json) {
    return new WholesaleShopCart(
      shopName: json["shop_name"],
      shopId: json["shop_id"],
      productsInCart: json['products_in_cart'],
    );
  }
}

class ProductsCart {
  final String productId;
  final List<CartVariation> variations;
  final BusinessProduct productDetails;

  ProductsCart({
    this.productId,
    this.variations,
    this.productDetails,
  });

  factory ProductsCart.fromJson(Map<String, dynamic> json) {
    return ProductsCart(
      productId: json["product_id"],
      variations: json['variations'],
      productDetails: json['product_details'],
    );
  }
}

class CartVariation {
  final String variationId;
  var addedToCartQuantity;
  final String status;
  var stock;
  var price;

  CartVariation({
    this.variationId,
    this.addedToCartQuantity,
    this.status,
    this.stock,
    this.price,
  });

  factory CartVariation.fromJson(Map<String, dynamic> json) {
    return CartVariation(
      variationId: json["variation_id"],
      addedToCartQuantity: json['added_to_cart_quantity'],
      status: json['status'],
      stock: json['stock'],
      price: json['price'],
    );
  }
}
