import 'dart:convert';

import 'package:efood_multivendor/data/model/response/cuisine_model.dart';

class RestaurantModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Restaurant>? restaurants;

  RestaurantModel({this.totalSize, this.limit, this.offset, this.restaurants});

  RestaurantModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['restaurants'] != null) {
      restaurants = [];
      json['restaurants'].forEach((v) {
        restaurants!.add(Restaurant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logo;
  String? latitude;
  String? longitude;
  String? address;
  int? zoneId;
  double? minimumOrder;
  String? currency;
  bool? freeDelivery;
  String? coverPhoto;
  bool? delivery;
  bool? takeAway;
  bool? scheduleOrder;
  double? avgRating;
  double? tax;
  int? ratingCount;
  int? selfDeliverySystem;
  bool? posSystem;
  int? open;
  bool? active;
  String? deliveryTime;
  List<int>? categoryIds;
  int? veg;
  int? nonVeg;
  Discount? discount;
  List<Schedules>? schedules;
  double? minimumShippingCharge;
  double? perKmShippingCharge;
  double? maximumShippingCharge;
  int? vendorId;
  String? restaurantModel;
  int? restaurantStatus;
  RestaurantSubscription? restaurantSubscription;
  List<Cuisines>? cuisineNames;
  List<int>? cuisineIds;
  bool? orderSubscriptionActive;
  bool? cutlery;

  Restaurant(
      {this.id,
        this.name,
        this.phone,
        this.email,
        this.logo,
        this.latitude,
        this.longitude,
        this.address,
        this.zoneId,
        this.minimumOrder,
        this.currency,
        this.freeDelivery,
        this.coverPhoto,
        this.delivery,
        this.takeAway,
        this.scheduleOrder,
        this.avgRating,
        this.tax,
        this.ratingCount,
        this.selfDeliverySystem,
        this.posSystem,
        this.open,
        this.active,
        this.deliveryTime,
        this.categoryIds,
        this.veg,
        this.nonVeg,
        this.discount,
        this.schedules,
        this.minimumShippingCharge,
        this.perKmShippingCharge,
        this.maximumShippingCharge,
        this.vendorId,
        this.restaurantModel,
        this.restaurantStatus,
        this.restaurantSubscription,
        this.cuisineNames,
        this.cuisineIds,
        this.orderSubscriptionActive,
        this.cutlery,
      });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    logo = json['logo'] ?? '';
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    zoneId = json['zone_id'];
    minimumOrder = json['minimum_order'] != null ? json['minimum_order'].toDouble() : 0;
    currency = json['currency'];
    freeDelivery = json['free_delivery'];
    coverPhoto = json['cover_photo'] ?? '';
    delivery = json['delivery'];
    takeAway = json['take_away'];
    scheduleOrder = json['schedule_order'];
    avgRating = json['avg_rating']?.toDouble();
    tax = json['tax']?.toDouble();
    ratingCount = json['rating_count '];
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = json['pos_system'];
    open = json['open'];
    active = json['active'];
    deliveryTime = json['delivery_time'];
    veg = json['veg'];
    nonVeg = json['non_veg'];
    categoryIds = json['category_ids'] != null ? json['category_ids'].cast<int>() : [];
    discount = json['discount'] != null ? Discount.fromJson(json['discount']) : null;
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(Schedules.fromJson(v));
      });
    }
    minimumShippingCharge = json['minimum_shipping_charge'] != null ? json['minimum_shipping_charge'].toDouble() : 0.0;
    perKmShippingCharge = json['per_km_shipping_charge'] != null ? json['per_km_shipping_charge'].toDouble() : 0.0;
    maximumShippingCharge = json['maximum_shipping_charge']?.toDouble();
    vendorId = json['vendor_id'];
    restaurantModel = json['restaurant_model'];
    restaurantStatus = json['restaurant_status'];
    restaurantSubscription = json['restaurant_sub'] != null ? RestaurantSubscription.fromJson(json['restaurant_sub']) : null;
    if(json['cuisine'] != null){
      cuisineNames = [];
      json['cuisine'].forEach((v){
        cuisineNames!.add(Cuisines.fromJson(v));
      });
    }
    orderSubscriptionActive = json['order_subscription_active'];
    // if(json['cuisine_ids'] != null){
    //   cuisineIds = [];
    //   json['cuisine_ids'].forEach((v){
    //     cuisineIds.add(v);
    //   });
    // }
    cutlery = json['cutlery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['logo'] = logo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['minimum_order'] = minimumOrder;
    data['currency'] = currency;
    data['zone_id'] = zoneId;
    data['free_delivery'] = freeDelivery;
    data['cover_photo'] = coverPhoto;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['tax'] = tax;
    data['rating_count '] = ratingCount;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['open'] = open;
    data['active'] = active;
    data['veg'] = veg;
    data['non_veg'] = nonVeg;
    data['delivery_time'] = deliveryTime;
    data['category_ids'] = categoryIds;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
    }
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['vendor_id'] = vendorId;
    data['cuisine'] = cuisineNames!.toList();
    data['order_subscription_active'] = orderSubscriptionActive;
    data['cutlery'] = cutlery;
    return data;
  }
}

class Discount {
  int? id;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;

  Discount(
      {this.id,
        this.startDate,
        this.endDate,
        this.startTime,
        this.endTime,
        this.minPurchase,
        this.maxDiscount,
        this.discount,
        this.discountType,
        this.restaurantId,
        this.createdAt,
        this.updatedAt});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time']?.substring(0, 5);
    endTime = json['end_time']?.substring(0, 5);
    minPurchase = json['min_purchase'].toDouble();
    maxDiscount = json['max_discount'].toDouble();
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Schedules {
  int? id;
  int? restaurantId;
  int? day;
  String? openingTime;
  String? closingTime;

  Schedules(
      {this.id,
        this.restaurantId,
        this.day,
        this.openingTime,
        this.closingTime});

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    day = json['day'];
    openingTime = json['opening_time'].substring(0, 5);
    closingTime = json['closing_time'].substring(0, 5);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['day'] = day;
    data['opening_time'] = openingTime;
    data['closing_time'] = closingTime;
    return data;
  }
}

class RestaurantSubscription {
  int? id;
  int? packageId;
  int? restaurantId;
  String? expiryDate;
  String? maxOrder;
  String? maxProduct;
  int? pos;
  int? mobileApp;
  int? chat;
  int? review;
  int? selfDelivery;
  int? status;
  int? totalPackageRenewed;
  String? createdAt;
  String? updatedAt;

  RestaurantSubscription(
      {this.id,
        this.packageId,
        this.restaurantId,
        this.expiryDate,
        this.maxOrder,
        this.maxProduct,
        this.pos,
        this.mobileApp,
        this.chat,
        this.review,
        this.selfDelivery,
        this.status,
        this.totalPackageRenewed,
        this.createdAt,
        this.updatedAt});

  RestaurantSubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    restaurantId = json['restaurant_id'];
    expiryDate = json['expiry_date'];
    maxOrder = json['max_order'];
    maxProduct = json['max_product'];
    pos = json['pos'];
    mobileApp = json['mobile_app'];
    chat = (json['chat'] != null && json['chat'] != 'null') ? json['chat'] : 0;
    review = json['review'] ?? 0;
    selfDelivery = json['self_delivery'];
    status = json['status'];
    totalPackageRenewed = json['total_package_renewed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['restaurant_id'] = restaurantId;
    data['expiry_date'] = expiryDate;
    data['max_order'] = maxOrder;
    data['max_product'] = maxProduct;
    data['pos'] = pos;
    data['mobile_app'] = mobileApp;
    data['chat'] = chat;
    data['review'] = review;
    data['self_delivery'] = selfDelivery;
    data['status'] = status;
    data['total_package_renewed'] = totalPackageRenewed;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Refund {
  int? id;
  int? orderId;
  List<String>? image;
  String? customerReason;
  String? customerNote;
  String? adminNote;

  Refund(
      {this.id,
        this.orderId,
        this.image,
        this.customerReason,
        this.customerNote,
        this.adminNote,
      });

  Refund.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    if(json['image'] != null){
      image = [];
      jsonDecode(json['image']).forEach((v) => image!.add(v));
    }
    customerReason = json['customer_reason'];
    customerNote = json['customer_note'];
    adminNote = json['admin_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['image'] = image;
    data['customer_reason'] = customerReason;
    data['customer_note'] = customerNote;
    data['admin_note'] = adminNote;
    return data;
  }
}