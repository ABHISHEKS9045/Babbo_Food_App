import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllRestaurantScreen extends StatefulWidget {
  final bool isPopular;
  final bool isRecentlyViewed;
  const AllRestaurantScreen({Key? key, required this.isPopular, required this.isRecentlyViewed}) : super(key: key);

  @override
  State<AllRestaurantScreen> createState() => _AllRestaurantScreenState();
}

class _AllRestaurantScreenState extends State<AllRestaurantScreen> {

  @override
  void initState() {
    super.initState();

    if(widget.isPopular) {
      Get.find<RestaurantController>().getPopularRestaurantList(false, 'all', false);
    }else {
      if(widget.isRecentlyViewed){
        Get.find<RestaurantController>().getRecentlyViewedRestaurantList(false, 'all', false);
      }else{
        Get.find<RestaurantController>().getLatestRestaurantList(false, 'all', false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<RestaurantController>(
      builder: (restController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: widget.isPopular ? 'popular_restaurants'.tr : widget.isRecentlyViewed
                ? 'recently_viewed_restaurants'.tr : '${'new_on'.tr} ${AppConstants.appName}',
            type: restController.type,
            onVegFilterTap: (String type) {
              if(widget.isPopular) {
                restController.getPopularRestaurantList(true, type, true);
              }else {
                if(widget.isRecentlyViewed){
                  restController.getRecentlyViewedRestaurantList(true, type, true);
                }else{
                  restController.getLatestRestaurantList(true, type, true);
                }
              }
            },
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if(widget.isPopular) {
                await Get.find<RestaurantController>().getPopularRestaurantList(
                  true, Get.find<RestaurantController>().type, false,
                );
              }else {
                if(widget.isRecentlyViewed){
                  Get.find<RestaurantController>().getRecentlyViewedRestaurantList(true, Get.find<RestaurantController>().type, false);
                }else{
                  await Get.find<RestaurantController>().getLatestRestaurantList(
                    true, Get.find<RestaurantController>().type, false,
                  );
                }
              }
            },
            child: Scrollbar(child: SingleChildScrollView(child: Center(child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: ProductView(
                isRestaurant: true, products: null, noDataText: 'no_restaurant_available'.tr,
                restaurants: widget.isPopular ? restController.popularRestaurantList : widget.isRecentlyViewed
                    ? restController.recentlyViewedRestaurantList : restController.latestRestaurantList,
              ),
            )))),
          ),
        );
      }
    );
  }
}
