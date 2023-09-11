import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/banner_controller.dart';
import 'package:efood_multivendor/controller/campaign_controller.dart';
import 'package:efood_multivendor/controller/category_controller.dart';
import 'package:efood_multivendor/controller/cuisine_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/notification_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/paginated_list_view.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/home/theme1/theme1_home_screen.dart';
import 'package:efood_multivendor/view/screens/home/web_home_screen.dart';
import 'package:efood_multivendor/view/screens/home/widget/bad_weather_widget.dart';
import 'package:efood_multivendor/view/screens/home/widget/cuisine_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/filter_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/near_by_button_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/popular_food_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/item_campaign_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/popular_restaurant_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/banner_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/category_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);


  static Future<void> loadData(bool reload) async {
    Get.find<BannerController>().getBannerList(reload);
    Get.find<CategoryController>().getCategoryList(reload);
    Get.find<CuisineController>().getCuisineList();
    if(Get.find<SplashController>().configModel!.popularRestaurant == 1) {
      Get.find<RestaurantController>().getPopularRestaurantList(reload, 'all', false);
    }
    Get.find<CampaignController>().getItemCampaignList(reload);
    if(Get.find<SplashController>().configModel!.popularFood == 1) {
      Get.find<ProductController>().getPopularProductList(reload, 'all', false);
    }
    if(Get.find<SplashController>().configModel!.newRestaurant == 1) {
      Get.find<RestaurantController>().getLatestRestaurantList(reload, 'all', false);
    }
    if(Get.find<SplashController>().configModel!.mostReviewedFoods == 1) {
      Get.find<ProductController>().getReviewedProductList(reload, 'all', false);
    }
    Get.find<RestaurantController>().getRestaurantList(1, reload);
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<RestaurantController>().getRecentlyViewedRestaurantList(reload, 'all', false);
      Get.find<UserController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      Get.find<LocationController>().getAddressList();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  bool _isLogin = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();
    HomeScreen.loadData(false);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      backgroundColor: Theme.of(context).colorScheme.background,// ResponsiveHelper.isDesktop(context) ? Theme.of(context).cardColor : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Get.find<BannerController>().getBannerList(true);
            await Get.find<CategoryController>().getCategoryList(true);
            await Get.find<CuisineController>().getCuisineList();
            await Get.find<RestaurantController>().getPopularRestaurantList(true, 'all', false);
            await Get.find<CampaignController>().getItemCampaignList(true);
            await Get.find<ProductController>().getPopularProductList(true, 'all', false);
            await Get.find<RestaurantController>().getLatestRestaurantList(true, 'all', false);
            await Get.find<ProductController>().getReviewedProductList(true, 'all', false);
            await Get.find<RestaurantController>().getRestaurantList(1, true);
            if(Get.find<AuthController>().isLoggedIn()) {
              await Get.find<UserController>().getUserInfo();
              await Get.find<NotificationController>().getNotificationList(true);
            }
          },
          child: ResponsiveHelper.isDesktop(context) ? WebHomeScreen(
            scrollController: _scrollController,
          ) : (Get.find<SplashController>().configModel!.theme == 2) ? Theme1HomeScreen(
            scrollController: _scrollController,
          ) : CustomScrollView(
            controller: _scrollController,
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
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                      ),
                      child: Row(children: [
                        Icon(Icons.search, size: 25, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Expanded(child: Text('search_food_or_restaurant'.tr, style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                        ))),
                      ]),
                    ),
                  ),
                ))),
              ),

              SliverToBoxAdapter(
                child: Center(child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    const BannerView(),
                    const BadWeatherWidget(),
                    const CategoryView(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _configModel!.popularRestaurant == 1 ? const PopularRestaurantView(isPopular: true) : const SizedBox(),
                    const NearByButtonView(),
                    const ItemCampaignView(),
                    _isLogin ? const PopularRestaurantView(isPopular: false, isRecentlyViewed: true) : const SizedBox(),
                    const CuisinesView(),
                    _configModel!.popularFood == 1 ? const PopularFoodView(isPopular: true) : const SizedBox(),
                    _configModel!.newRestaurant == 1 ? const PopularRestaurantView(isPopular: false) : const SizedBox(),
                    _configModel!.mostReviewedFoods == 1 ? const PopularFoodView(isPopular: false) : const SizedBox(),

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
                        scrollController: _scrollController,
                        totalSize: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : null,
                        offset: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.offset : null,
                        onPaginate: (int? offset) async => await restaurantController.getRestaurantList(offset!, false),
                        productView: ProductView(
                          isRestaurant: true, products: null,
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
          ),
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
