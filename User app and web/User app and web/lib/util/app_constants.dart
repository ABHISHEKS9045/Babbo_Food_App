import 'package:efood_multivendor/data/model/response/language_model.dart';
import 'package:efood_multivendor/util/images.dart';

class AppConstants {
  static const String appName = 'babbo Food';
  static const double appVersion = 7.0;

  static const String fontFamily = 'Roboto';
  static const bool payInWevView = false;

  static const String baseUrl = 'https://fooddeliverymilan.website/admin';
  static const String categoryUri = '/api/v1/categories';
  static const String bannerUri = '/api/v1/banners';
  static const String restaurantProductUri = '/api/v1/products/latest';
  static const String popularProductUri = '/api/v1/products/popular';
  static const String reviewedProductUri = '/api/v1/products/most-reviewed';
  static const String searchProductUri = '/api/v1/products/details/';
  static const String subCategoryUri = '/api/v1/categories/childes/';
  static const String categoryProductUri = '/api/v1/categories/products/';
  static const String categoryRestaurantUri = '/api/v1/categories/restaurants/';
  static const String configUri = '/api/v1/config';
  static const String trackUri = '/api/v1/customer/order/track?order_id=';
  static const String messageUri = '/api/v1/customer/message/get';
  static const String forgetPasswordUri = '/api/v1/auth/forgot-password';
  static const String verifyTokenUri = '/api/v1/auth/verify-token';
  static const String resetPasswordUri = '/api/v1/auth/reset-password';
  static const String verifyPhoneUri = '/api/v1/auth/verify-phone';
  static const String checkEmailUri = '/api/v1/auth/check-email';
  static const String verifyEmailUri = '/api/v1/auth/verify-email';
  static const String registerUri = '/api/v1/auth/sign-up';
  static const String loginUri = '/api/v1/auth/login';
  static const String tokenUri = '/api/v1/customer/cm-firebase-token';
  static const String placeOrderUri = '/api/v1/customer/order/place';
  static const String addressListUri = '/api/v1/customer/address/list';
  static const String zoneUri = '/api/v1/config/get-zone-id';
  static const String removeAddressUri = '/api/v1/customer/address/delete?address_id=';
  static const String addAddressUri = '/api/v1/customer/address/add';
  static const String updateAddressUri = '/api/v1/customer/address/update/';
  static const String setMenuUri = '/api/v1/products/set-menu';
  static const String customerInfoUri = '/api/v1/customer/info';
  static const String couponUri = '/api/v1/coupon/list';
  static const String couponApplyUri = '/api/v1/coupon/apply?code=';
  static const String runningOrderListUri = '/api/v1/customer/order/running-orders';
  static const String runningSubscriptionOrderListUri = '/api/v1/customer/order/order-subscription-list';
  static const String historyOrderListUri = '/api/v1/customer/order/list';
  static const String orderCancelUri = '/api/v1/customer/order/cancel';
  static const String codSwitchUri = '/api/v1/customer/order/payment-method';
  static const String orderDetailsUri = '/api/v1/customer/order/details?order_id=';
  static const String wishListGetUri = '/api/v1/customer/wish-list';
  static const String addWishListUri = '/api/v1/customer/wish-list/add?';
  static const String removeWishListUri = '/api/v1/customer/wish-list/remove?';
  static const String notificationUri = '/api/v1/customer/notifications';
  static const String updateProfileUri = '/api/v1/customer/update-profile';
  static const String searchUri = '/api/v1/';
  static const String reviewUri = '/api/v1/products/reviews/submit';
  static const String productDetailsUri = '/api/v1/products/details/';
  static const String lastLocationUri = '/api/v1/delivery-man/last-location?order_id=';
  static const String deliveryManReviewUri = '/api/v1/delivery-man/reviews/submit';
  static const String restaurantUri = '/api/v1/restaurants/get-restaurants';
  static const String popularRestaurantUri = '/api/v1/restaurants/popular';
  static const String latestRestaurantUri = '/api/v1/restaurants/latest';
  static const String restaurantDetailsUri = '/api/v1/restaurants/details/';
  static const String basicCampaignUri = '/api/v1/campaigns/basic';
  static const String itemCampaignUri = '/api/v1/campaigns/item';
  static const String basicCampaignDetailsUri = '/api/v1/campaigns/basic-campaign-details?basic_campaign_id=';
  static const String interestUri = '/api/v1/customer/update-interest';
  static const String suggestedFoodUri = '/api/v1/customer/suggested-foods';
  static const String restaurantReviewUri = '/api/v1/restaurants/reviews';
  static const String distanceMatrixUri = '/api/v1/config/distance-api';
  static const String searchLocationUri = '/api/v1/config/place-api-autocomplete';
  static const String placeDetailsUri = '/api/v1/config/place-api-details';
  static const String geocodeUri = '/api/v1/config/geocode-api';
  static const String socialLoginUri = '/api/v1/auth/social-login';
  static const String socialRegisterUri = '/api/v1/auth/social-register';
  static const String updateZoneUri = '/api/v1/customer/update-zone';
  static const String walletTransactionUri = '/api/v1/customer/wallet/transactions';
  static const String loyaltyTransactionUri = '/api/v1/customer/loyalty-point/transactions';
  static const String loyaltyPointTransferUri = '/api/v1/customer/loyalty-point/point-transfer';
  static const String customerRemoveUri = '/api/v1/customer/remove-account';
  static const String conversationListUri = '/api/v1/customer/message/list';
  static const String searchConversationListUri = '/api/v1/customer/message/search-list';
  static const String messageListUri = '/api/v1/customer/message/details';
  static const String sendMessageUri = '/api/v1/customer/message/send';
  static const String zoneListUri = '/api/v1/zone/list';
  static const String restaurantRegisterUri = '/api/v1/auth/vendor/register';
  static const String dmRegisterUri = '/api/v1/auth/delivery-man/store';
  static const String restaurantPackagesUri = '/api/v1/auth/vendor/package-view';
  static const String businessPlanUri = '/api/v1/auth/vendor/business_plan';
  static const String refundReasonsUri = '/api/v1/customer/order/refund-reasons';
  static const String refundRequestUri = '/api/v1/customer/order/refund-request';
  static const String orderCancellationUri = '/api/v1/customer/order/cancellation-reasons';
  static const String cuisineUri = '/api/v1/cuisine';
  static const String cuisineRestaurantUri = '/api/v1/cuisine/get_restaurants';
  static const String restaurantRecommendedItemUri = '/api/v1/products/recommended';
  static const String vehicleChargeUri = '/api/v1/vehicle/extra_charge';
  static const String vehiclesUri = '/api/v1/get-vehicles';
  static const String productListWithIdsUri = '/api/v1/customer/food-list';
  static const String recentlyViewedRestaurantUri = '/api/v1/restaurants/recently-viewed-restaurants';
  static const String subscriptionListUri = '/api/v1/customer/subscription';
  static const String sendCheckoutNotificationUri = '/api/v1/customer/order/send-notification';
  static const String cartRestaurantSuggestedItemsUri = '/api/v1/products/recommended/most-reviewed';
  static const String aboutUsUri = '/about-us';
  static const String privacyPolicyUri = '/privacy-policy';
  static const String termsAndConditionUri = '/terms-and-conditions';
  static const String cancellationUri = '/cancellation-policy';
  static const String refundUri = '/refund-policy';
  static const String shippingPolicyUri = '/shipping-policy';

  /// Shared Key
  static const String theme = 'theme';
  static const String token = 'multivendor_token';
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';
  static const String cartList = 'cart_list';
  static const String userPassword = 'user_password';
  static const String userAddress = 'user_address';
  static const String userNumber = 'user_number';
  static const String userCountryCode = 'user_country_code';
  static const String notification = 'notification';
  static const String searchHistory = 'search_history';
  static const String intro = 'intro';
  static const String notificationCount = 'notification_count';
  static const String notificationIdList = 'notification_id_list';
  static const String topic = 'all_zone_customer';
  static const String zoneId = 'zoneId';
  static const String localizationKey = 'X-localization';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String earnPoint = 'stackfood_earn_point';
  static const String acceptCookies = '6ammart_accept_cookies';
  static const String cookiesManagement = 'cookies_management';
  static const String dmTipIndex = 'stackfood_dm_tip_index';


  ///Refer & Earn work flow list..
  static const dataList = ['Invite your friends & businesses', 'They register eFood with special offer', 'You made your earning !'];

  /// Delivery Tips
  static List<String> tips = ['not_now' ,'15', '10', '20', '40', 'custom'];
  static List<String> deliveryInstructionList = [
    'Deliver to front door',
    'Deliver to the reception desk',
    'Avoid calling me',
  ];


  ///Order Status
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String processing = 'processing';
  static const String confirmed = 'confirmed';
  static const String handover = 'handover';
  static const String pickedUp = 'picked_up';
  static const String delivered = 'delivered';
  static const String cancelled = 'canceled';

  /// Delivery Type
  static const String delivery = 'delivery';
  static const String takeAway = 'take_away';

  /// Preference Day
  static List<String?> preferenceDays = ['today', 'tomorrow'];

  /// Deep Links
  static const String yourScheme = 'babbo-food';
  static const String yourHost = 'babbo-food';

  /// Languages
  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.arabic, languageName: 'عربى', countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(imageUrl: Images.spanish, languageName: 'Spanish', countryCode: 'ES', languageCode: 'es'),
  ];
}
