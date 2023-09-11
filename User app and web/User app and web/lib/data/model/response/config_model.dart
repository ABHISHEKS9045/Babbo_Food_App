class ConfigModel {
  String? businessName;
  String? logo;
  String? address;
  String? phone;
  String? email;
  BaseUrls? baseUrls;
  String? currencySymbol;
  bool? cashOnDelivery;
  bool? digitalPayment;
  String? termsAndConditions;
  String? privacyPolicy;
  String? aboutUs;
  String? country;
  DefaultLocation? defaultLocation;
  String? appUrlAndroid;
  String? appUrlIos;
  bool? customerVerification;
  bool? orderDeliveryVerification;
  String? currencySymbolDirection;
  double? appMinimumVersionAndroid;
  double? appMinimumVersionIos;
  double? freeDeliveryOver;
  bool? demo;
  bool? maintenanceMode;
  int? popularFood;
  int? popularRestaurant;
  int? mostReviewedFoods;
  int? newRestaurant;
  String? orderConfirmationModel;
  bool? showDmEarning;
  bool? canceledByDeliveryman;
  bool? canceledByRestaurant;
  String? timeformat;
  bool? toggleVegNonVeg;
  bool? toggleDmRegistration;
  bool? toggleRestaurantRegistration;
  List<SocialLogin>? socialLogin;
  List<SocialLogin>? appleLogin;
  int? scheduleOrderSlotDuration;
  int? digitAfterDecimalPoint;
  int? loyaltyPointExchangeRate;
  double? loyaltyPointItemPurchasePoint;
  int? loyaltyPointStatus;
  int? minimumPointToTransfer;
  int? customerWalletStatus;
  int? dmTipsStatus;
  int? refEarningStatus;
  double? refEarningExchangeRate;
  int? theme;
  BusinessPlan? businessPlan;
  double? adminCommission;
  bool? refundStatus;
  int? refundPolicyStatus;
  String? refundPolicyData;
  int? cancellationPolicyStatus;
  String? cancellationPolicyData;
  int? shippingPolicyStatus;
  String? shippingPolicyData;
  int? freeTrialPeriodStatus;
  int? freeTrialPeriodDay;
  int? taxIncluded;
  String? cookiesText;
  List<Language>? language;
  bool? takeAway;
  bool? homeDelivery;
  bool? repeatOrderOption;

  ConfigModel(
      {this.businessName,
        this.logo,
        this.address,
        this.phone,
        this.email,
        this.baseUrls,
        this.currencySymbol,
        this.cashOnDelivery,
        this.digitalPayment,
        this.termsAndConditions,
        this.privacyPolicy,
        this.aboutUs,
        this.country,
        this.defaultLocation,
        this.appUrlAndroid,
        this.appUrlIos,
        this.customerVerification,
        this.orderDeliveryVerification,
        this.currencySymbolDirection,
        this.appMinimumVersionAndroid,
        this.appMinimumVersionIos,
        this.freeDeliveryOver,
        this.demo,
        this.maintenanceMode,
        this.popularFood,
        this.popularRestaurant,
        this.mostReviewedFoods,
        this.newRestaurant,
        this.orderConfirmationModel,
        this.showDmEarning,
        this.canceledByDeliveryman,
        this.canceledByRestaurant,
        this.timeformat,
        this.toggleVegNonVeg,
        this.toggleDmRegistration,
        this.toggleRestaurantRegistration,
        this.socialLogin,
        this.appleLogin,
        this.scheduleOrderSlotDuration,
        this.digitAfterDecimalPoint,
        this.loyaltyPointExchangeRate,
        this.loyaltyPointItemPurchasePoint,
        this.loyaltyPointStatus,
        this.minimumPointToTransfer,
        this.customerWalletStatus,
        this.dmTipsStatus,
        this.refEarningStatus,
        this.refEarningExchangeRate,
        this.theme,
        this.businessPlan,
        this.adminCommission,
        this.refundStatus,
        this.refundPolicyStatus,
        this.refundPolicyData,
        this.cancellationPolicyStatus,
        this.cancellationPolicyData,
        this.shippingPolicyStatus,
        this.shippingPolicyData,
        this.freeTrialPeriodStatus,
        this.freeTrialPeriodDay,
        this.taxIncluded,
        this.cookiesText,
        this.language,
        this.takeAway,
        this.homeDelivery,
        this.repeatOrderOption,
      });

  ConfigModel.fromJson(Map<String, dynamic> json) {
    businessName = json['business_name'];
    logo = json['logo'];
    address = json['address'];
    phone = json['phone'];
    email = json['email'];
    baseUrls = json['base_urls'] != null ? BaseUrls.fromJson(json['base_urls']) : null;
    currencySymbol = json['currency_symbol'];
    cashOnDelivery = json['cash_on_delivery'];
    digitalPayment = json['digital_payment'];
    termsAndConditions = json['terms_and_conditions'];
    privacyPolicy = json['privacy_policy'];
    aboutUs = json['about_us'];
    country = json['country'];
    defaultLocation = json['default_location'] != null ? DefaultLocation.fromJson(json['default_location']) : null;
    appUrlAndroid = json['app_url_android'];
    appUrlIos = json['app_url_ios'];
    customerVerification = json['customer_verification'];
    orderDeliveryVerification = json['order_delivery_verification'];
    currencySymbolDirection = json['currency_symbol_direction'];
    appMinimumVersionAndroid = json['app_minimum_version_android'] != null ? json['app_minimum_version_android'].toDouble() : 0.0;
    appMinimumVersionIos = json['app_minimum_version_ios'] != null ? json['app_minimum_version_ios'].toDouble() : 0.0;
    freeDeliveryOver = json['free_delivery_over'] != null ? double.parse(json['free_delivery_over'].toString()) : null;
    demo = json['demo'];
    maintenanceMode = json['maintenance_mode'];
    popularFood = json['popular_food'];
    popularRestaurant = json['popular_restaurant'];
    newRestaurant = json['new_restaurant'];
    mostReviewedFoods = json['most_reviewed_foods'];
    orderConfirmationModel = json['order_confirmation_model'];
    showDmEarning = json['show_dm_earning'];
    canceledByDeliveryman = json['canceled_by_deliveryman'];
    canceledByRestaurant = json['canceled_by_restaurant'];
    timeformat = json['timeformat'];
    toggleVegNonVeg = json['toggle_veg_non_veg'];
    toggleDmRegistration = json['toggle_dm_registration'];
    toggleRestaurantRegistration = json['toggle_restaurant_registration'];
    if (json['social_login'] != null) {
      socialLogin = <SocialLogin>[];
      json['social_login'].forEach((v) {
        socialLogin!.add(SocialLogin.fromJson(v));
      });
    }
    if (json['apple_login'] != null) {
      appleLogin = <SocialLogin>[];
      json['apple_login'].forEach((v) {
        appleLogin!.add(SocialLogin.fromJson(v));
      });
    }
    scheduleOrderSlotDuration = json['schedule_order_slot_duration'] == 0 ? 30 : json['schedule_order_slot_duration'];
    digitAfterDecimalPoint = json['digit_after_decimal_point'];
    loyaltyPointExchangeRate = json['loyalty_point_exchange_rate'];
    loyaltyPointItemPurchasePoint = json['loyalty_point_item_purchase_point'].toDouble();
    loyaltyPointStatus = json['loyalty_point_status'];
    minimumPointToTransfer = json['minimum_point_to_transfer'];
    customerWalletStatus = json['customer_wallet_status'];
    dmTipsStatus = json['dm_tips_status'];
    refEarningStatus = json['ref_earning_status'];
    refEarningExchangeRate = json['ref_earning_exchange_rate'].toDouble();
    theme = json['theme'];
    businessPlan = json['business_plan'] != null ? BusinessPlan.fromJson(json['business_plan']) : null;
    adminCommission = json['admin_commission'].toDouble();
    refundStatus = json['refund_active_status'];
    refundPolicyStatus = json['refund_policy_status'];
    refundPolicyData = json['refund_policy_data'];
    cancellationPolicyStatus = json['cancellation_policy_status'];
    cancellationPolicyData = json['cancellation_policy_data'];
    shippingPolicyStatus = json['shipping_policy_status'];
    shippingPolicyData = json['shipping_policy_data'];
    freeTrialPeriodStatus = json['free_trial_period_status'];
    freeTrialPeriodDay = json['free_trial_period_data'];
    taxIncluded = json['tax_included'];
    cookiesText = json['cookies_text'];
    if (json['language'] != null) {
      language = [];
      json['language'].forEach((v) {
        language!.add(Language.fromJson(v));
      });
    }
    takeAway = json['take_away'];
    homeDelivery = json['home_delivery'];
    repeatOrderOption = json['repeat_order_option'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_name'] = businessName;
    data['logo'] = logo;
    data['address'] = address;
    data['phone'] = phone;
    data['email'] = email;
    if (baseUrls != null) {
      data['base_urls'] = baseUrls!.toJson();
    }
    data['currency_symbol'] = currencySymbol;
    data['cash_on_delivery'] = cashOnDelivery;
    data['digital_payment'] = digitalPayment;
    data['terms_and_conditions'] = termsAndConditions;
    data['privacy_policy'] = privacyPolicy;
    data['about_us'] = aboutUs;
    data['country'] = country;
    if (defaultLocation != null) {
      data['default_location'] = defaultLocation!.toJson();
    }
    data['app_url_android'] = appUrlAndroid;
    data['app_url_ios'] = appUrlIos;
    data['customer_verification'] = customerVerification;
    data['order_delivery_verification'] = orderDeliveryVerification;
    data['currency_symbol_direction'] = currencySymbolDirection;
    data['app_minimum_version_android'] = appMinimumVersionAndroid;
    data['app_minimum_version_ios'] = appMinimumVersionIos;
    data['free_delivery_over'] = freeDeliveryOver;
    data['demo'] = demo;
    data['maintenance_mode'] = maintenanceMode;
    data['popular_food'] = popularFood;
    data['popular_restaurant'] = popularRestaurant;
    data['new_restaurant'] = newRestaurant;
    data['most_reviewed_foods'] = mostReviewedFoods;
    data['order_confirmation_model'] = orderConfirmationModel;
    data['show_dm_earning'] = showDmEarning;
    data['canceled_by_deliveryman'] = canceledByDeliveryman;
    data['canceled_by_restaurant'] = canceledByRestaurant;
    data['timeformat'] = timeformat;
    data['toggle_veg_non_veg'] = toggleVegNonVeg;
    data['toggle_dm_registration'] = toggleDmRegistration;
    data['toggle_restaurant_registration'] = toggleRestaurantRegistration;
    if (socialLogin != null) {
      data['social_login'] = socialLogin!.map((v) => v.toJson()).toList();
    }
    if (appleLogin != null) {
      data['apple_login'] = appleLogin!.map((v) => v.toJson()).toList();
    }
    data['schedule_order_slot_duration'] = scheduleOrderSlotDuration;
    data['digit_after_decimal_point'] = digitAfterDecimalPoint;
    data['loyalty_point_exchange_rate'] = loyaltyPointExchangeRate;
    data['loyalty_point_item_purchase_point'] = loyaltyPointItemPurchasePoint;
    data['loyalty_point_status'] = loyaltyPointStatus;
    data['minimum_point_to_transfer'] = minimumPointToTransfer;
    data['customer_wallet_status'] = customerWalletStatus;
    data['dm_tips_status'] = dmTipsStatus;
    data['ref_earning_status'] = refEarningStatus;
    data['ref_earning_exchange_rate'] = refEarningExchangeRate;
    data['theme'] = theme;
    data['refund_active_status'] = refundStatus;
    data['tax_included'] = taxIncluded;
    data['cookies_text'] = cookiesText;
    if (language != null) {
      data['language'] = language!.map((v) => v.toJson()).toList();
    }
    data['take_away'] = takeAway;
    data['home_delivery'] = homeDelivery;
    data['repeat_order_option'] = repeatOrderOption;
    return data;
  }
}

class BaseUrls {
  String? productImageUrl;
  String? customerImageUrl;
  String? bannerImageUrl;
  String? categoryImageUrl;
  String? reviewImageUrl;
  String? notificationImageUrl;
  String? restaurantImageUrl;
  String? restaurantCoverPhotoUrl;
  String? deliveryManImageUrl;
  String? chatImageUrl;
  String? campaignImageUrl;
  String? businessLogoUrl;
  String? refundImageUrl;
  String? cuisineImageUrl;

  BaseUrls(
      {this.productImageUrl,
        this.customerImageUrl,
        this.bannerImageUrl,
        this.categoryImageUrl,
        this.reviewImageUrl,
        this.notificationImageUrl,
        this.restaurantImageUrl,
        this.restaurantCoverPhotoUrl,
        this.deliveryManImageUrl,
        this.chatImageUrl,
        this.campaignImageUrl,
        this.businessLogoUrl,
        this.refundImageUrl,
        this.cuisineImageUrl,
      });

  BaseUrls.fromJson(Map<String, dynamic> json) {
    productImageUrl = json['product_image_url'];
    customerImageUrl = json['customer_image_url'];
    bannerImageUrl = json['banner_image_url'];
    categoryImageUrl = json['category_image_url'];
    reviewImageUrl = json['review_image_url'];
    notificationImageUrl = json['notification_image_url'];
    restaurantImageUrl = json['restaurant_image_url'];
    restaurantCoverPhotoUrl = json['restaurant_cover_photo_url'];
    deliveryManImageUrl = json['delivery_man_image_url'];
    chatImageUrl = json['chat_image_url'];
    campaignImageUrl = json['campaign_image_url'];
    businessLogoUrl = json['business_logo_url'];
    refundImageUrl = json['refund_image_url'];
    cuisineImageUrl = json['cuisine_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_image_url'] = productImageUrl;
    data['customer_image_url'] = customerImageUrl;
    data['banner_image_url'] = bannerImageUrl;
    data['category_image_url'] = categoryImageUrl;
    data['review_image_url'] = reviewImageUrl;
    data['notification_image_url'] = notificationImageUrl;
    data['restaurant_image_url'] = restaurantImageUrl;
    data['restaurant_cover_photo_url'] = restaurantCoverPhotoUrl;
    data['delivery_man_image_url'] = deliveryManImageUrl;
    data['chat_image_url'] = chatImageUrl;
    data['campaign_image_url'] = campaignImageUrl;
    data['business_logo_url'] = businessLogoUrl;
    data['refund_image_url'] = refundImageUrl;
    data['cuisine_image_url'] = cuisineImageUrl;
    return data;
  }
}

class DefaultLocation {
  String? lat;
  String? lng;

  DefaultLocation({this.lat, this.lng});

  DefaultLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Language {
  String? key;
  String? value;

  Language({this.key, this.value});

  Language.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class SocialLogin {
  String? loginMedium;
  bool? status;
  String? clientId;

  SocialLogin({this.loginMedium, this.status, this.clientId});

  SocialLogin.fromJson(Map<String, dynamic> json) {
    loginMedium = json['login_medium'];
    status = json['status'];
    clientId = json['client_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['login_medium'] = loginMedium;
    data['status'] = status;
    data['client_id'] = clientId;
    return data;
  }
}

class BusinessPlan {
  int? commission;
  int? subscription;

  BusinessPlan({this.commission, this.subscription});

  BusinessPlan.fromJson(Map<String, dynamic> json) {
    commission = json['commission'];
    subscription = json['subscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commission'] = commission;
    data['subscription'] = subscription;
    return data;
  }
}
