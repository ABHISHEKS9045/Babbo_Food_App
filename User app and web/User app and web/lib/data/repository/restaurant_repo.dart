import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  RestaurantRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getRestaurantList(int offset, String filterBy) async {
    return await apiClient.getData('${AppConstants.restaurantUri}/$filterBy?offset=$offset&limit=10');
  }

  Future<Response> getPopularRestaurantList(String type) async {
    return await apiClient.getData('${AppConstants.popularRestaurantUri}?type=$type');
  }

  Future<Response> getLatestRestaurantList(String type) async {
    return await apiClient.getData('${AppConstants.latestRestaurantUri}?type=$type');
  }

  Future<Response> getRestaurantDetails(String restaurantID) async {
    return await apiClient.getData('${AppConstants.restaurantDetailsUri}$restaurantID');
  }

  Future<Response> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, String type) async {
    return await apiClient.getData(
      '${AppConstants.restaurantProductUri}?restaurant_id=$restaurantID&category_id=$categoryID&offset=$offset&limit=10&type=$type',
    );
  }

  Future<Response> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}products/search?restaurant_id=$storeID&name=$searchText&offset=$offset&limit=10&type=$type',
    );
  }

  Future<Response> getRestaurantReviewList(String? restaurantID) async {
    return await apiClient.getData('${AppConstants.restaurantReviewUri}?restaurant_id=$restaurantID');
  }

  Future<Response> getRestaurantRecommendedItemList(int? restaurantId) async {
    return await apiClient.getData('${AppConstants.restaurantRecommendedItemUri}?restaurant_id=$restaurantId&offset=1&limit=50');
  }

  Future<Response> getRecentlyViewedRestaurantList(String type) async {
    return await apiClient.getData('${AppConstants.recentlyViewedRestaurantUri}?type=$type');
  }

  Future<Response> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    // AddressModel? addressModel = Get.find<LocationController>().getUserAddress();
    /*Map<String, String> header = apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token), addressModel?.zoneIds,
      Get.find<LocalizationController>().locale.languageCode,
      addressModel?.latitude, addressModel?.longitude
    );*/
    return await apiClient.getData('${AppConstants.cartRestaurantSuggestedItemsUri}?restaurant_id=$restaurantID');
  }

}