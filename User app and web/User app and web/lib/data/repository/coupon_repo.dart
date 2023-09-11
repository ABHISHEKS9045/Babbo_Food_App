import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CouponRepo {
  final ApiClient apiClient;
  CouponRepo({required this.apiClient});

  Future<Response> getCouponList(int? customerId) async {
    return await apiClient.getData('${AppConstants.couponUri}?customer_id=$customerId');
  }

  Future<Response> applyCoupon(String couponCode, int? restaurantID) async {
    return await apiClient.getData('${AppConstants.couponApplyUri}$couponCode&restaurant_id=$restaurantID');
  }
}