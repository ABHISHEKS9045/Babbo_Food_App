import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/view/screens/home/widget/bad_weather_widget.dart';
import 'package:efood_multivendor/view/screens/home/widget/cuisine_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/filter_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/near_by_button_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/notification_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:efood_multivendor/view/base/paginated_list_view.dart';
import 'package:efood_multivendor/view/screens/home/home_screen.dart';
import 'package:efood_multivendor/view/screens/home/theme1/banner_view1.dart';
import 'package:efood_multivendor/view/screens/home/theme1/best_reviewed_item_view.dart';
import 'package:efood_multivendor/view/screens/home/theme1/category_view1.dart';
import 'package:efood_multivendor/view/screens/home/theme1/item_campaign_view1.dart';
import 'package:efood_multivendor/view/screens/home/theme1/popular_item_view1.dart';
import 'package:efood_multivendor/view/screens/home/theme1/popular_store_view1.dart';

class Theme1HomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const Theme1HomeScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigModel configModel = Get.find<SplashController>().configModel!;
    bool isLogin = Get.find<AuthController>().isLoggedIn();

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [

        // App Bar
        SliverAppBar(
          floating: true, elevation: 0, automaticallyImplyLeading: false,
          backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).colorScheme.background,
          title: Center(child: Container(
            width: Dimensions.webMaxWidth, height: 50, color: Theme.of(context).colorScheme.background,
            child: Row(children: [
              Expanded(child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                  ),
                  child: GetBuilder<LocationController>(builder: (locationController) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          locationController.getUserAddress()!.addressType == 'home' ? Icons.home_filled
                              : locationController.getUserAddress()!.addressType == 'office' ? Icons.work : Icons.location_on,
                          size: 20, color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            locationController.getUserAddress()!.address!,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyLarge!.color),
                      ],
                    );
                  }),
                ),
              )),
              InkWell(
                child: GetBuilder<NotificationController>(builder: (notificationController) {
                  return Stack(children: [
                    Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                    notificationController.hasNotification ? Positioned(top: 0, right: 0, child: Container(
                      height: 10, width: 10, decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Theme.of(context).cardColor),
                    ),
                    )) : const SizedBox(),
                  ]);
                }),
                onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
              ),
            ]),
          )),
          actions: const [SizedBox()],
        ),

        // Search Button
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverDelegate(child: Center(child: Container(
            height: 50, width: Dimensions.webMaxWidth,
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: InkWell(
              onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                ),
                child: Row(children: [
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Icon(
                    Icons.search, size: 25,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(child: Text(
                    'search_food_or_restaurant'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                    ),
                  )),
                ]),
              ),
            ),
          ))),
        ),

        SliverToBoxAdapter(
          child: Center(child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const BannerView1(),
              const BadWeatherWidget(),
              const CategoryView1(),
              const ItemCampaignView1(),
              configModel.mostReviewedFoods == 1 ? const BestReviewedItemView() : const SizedBox(),
              isLogin ? const PopularStoreView1(isPopular: false, isRecentlyViewed: true) : const SizedBox(),
              const CuisinesView(),
              configModel.popularRestaurant == 1 ? const PopularStoreView1(isPopular: true) : const SizedBox(),
              const NearByButtonView(),
              configModel.popularFood == 1 ? const PopularItemView1(isPopular: true) : const SizedBox(),
              configModel.newRestaurant == 1 ? const PopularStoreView1(isPopular: false) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                child: Row(children: [
                  Expanded(child: Text(
                    'all_restaurants'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  )),
                  const FilterView(),
                ]),
              ),

              GetBuilder<RestaurantController>(builder: (restaurantController) {
                return PaginatedListView(
                  scrollController: scrollController,
                  totalSize: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : null,
                  offset: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.offset : null,
                  onPaginate: (int? offset) async => await restaurantController.getRestaurantList(offset!, false),
                  productView: ProductView(
                    isRestaurant: true, products: null, showTheme1Restaurant: true,
                    restaurants: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.restaurants : null,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                      vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                    ),
                  ),
                );
              }),

            ]),
          )),
        ),
      ],
    );
  }
}
