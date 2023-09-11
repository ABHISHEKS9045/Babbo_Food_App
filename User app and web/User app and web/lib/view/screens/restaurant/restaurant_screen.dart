import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/category_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/model/response/category_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/bottom_cart_widget.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:efood_multivendor/view/base/product_widget.dart';
import 'package:efood_multivendor/view/base/veg_filter_widget.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/customizable_space_bar.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/restaurant_description_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  const RestaurantScreen({Key? key, required this.restaurant}) : super(key: key);

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: widget.restaurant!.id));
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurant!.id, false);
    Get.find<RestaurantController>().getRestaurantProductList(widget.restaurant!.id, 1, 'all', false);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<RestaurantController>().restaurantProducts != null
          && !Get.find<RestaurantController>().foodPaginate) {
        int pageSize = (Get.find<RestaurantController>().foodPageSize! / 10).ceil();
        if (Get.find<RestaurantController>().foodOffset < pageSize) {
          Get.find<RestaurantController>().setFoodOffset(Get.find<RestaurantController>().foodOffset+1);
          debugPrint('end of the page');
          Get.find<RestaurantController>().showFoodBottomLoader();
          Get.find<RestaurantController>().getRestaurantProductList(
            widget.restaurant!.id, Get.find<RestaurantController>().foodOffset, Get.find<RestaurantController>().type, false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {
          Restaurant? restaurant;
          if(restController.restaurant != null && restController.restaurant!.name != null && categoryController.categoryList != null) {
            restaurant = restController.restaurant;
          }
          restController.setCategoryList();

          return (restController.restaurant != null && restController.restaurant!.name != null && categoryController.categoryList != null)
          ? CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [

              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF171A29),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  alignment: Alignment.center,
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [

                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            fit: BoxFit.cover, placeholder: Images.restaurantCover, height: 220,
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantCoverPhotoUrl}/${restaurant!.coverPhoto}',
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: RestaurantDescriptionView(restaurant: restaurant)),

                    ]),
                  ))),
                ),
              ) : SliverAppBar(
                expandedHeight: 250, toolbarHeight: 100,
                pinned: true, floating: false, elevation: 0.5,
                backgroundColor: Theme.of(context).cardColor,
                leading: IconButton(
                  icon: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    alignment: Alignment.center,
                    child: Icon(Icons.chevron_left, color: Theme.of(context).cardColor),
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  centerTitle: true,
                  expandedTitleScale: 1.1,
                  title: CustomizableSpaceBar(
                    builder: (context, scrollingRate) {
                      return Container(
                        height: 100,
                        color: Theme.of(context).cardColor,
                        child: Container(
                          color: Theme.of(context).cardColor.withOpacity(scrollingRate),
                          padding: EdgeInsets.only(
                            bottom: 0,
                            left: Get.find<LocalizationController>().isLtr ? 40 * scrollingRate : 0,
                            right: Get.find<LocalizationController>().isLtr ? 0 : 40 * scrollingRate,
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              height: 100, color: Theme.of(context).cardColor.withOpacity(scrollingRate == 0.0 ? 1 : 0),
                              padding: EdgeInsets.only(
                                left: Get.find<LocalizationController>().isLtr ? 20 : 0,
                                right: Get.find<LocalizationController>().isLtr ? 0 : 20,
                              ),
                              child: Row(children: [

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Stack(children: [
                                    CustomImage(
                                      image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantImageUrl}/${restaurant!.logo}',
                                      height: 60 - (scrollingRate * 15), width: 70 - (scrollingRate * 15), fit: BoxFit.cover,
                                    ),
                                    restController.isRestaurantOpenNow(restaurant.active!, restaurant.schedules) ? const SizedBox() : Positioned(
                                      bottom: 0, left: 0, right: 0,
                                      child: Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusSmall)),
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        child: Text(
                                          'closed_now'.tr, textAlign: TextAlign.center,
                                          style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(
                                    restaurant.name!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge - (scrollingRate * 3), color: Theme.of(context).textTheme.bodyMedium!.color),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text(
                                    restaurant.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * 2), color: Theme.of(context).disabledColor),
                                  ),
                                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),

                                  Row(children: [
                                    Text('minimum_order'.tr, style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2), color: Theme.of(context).disabledColor,
                                    )),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Text(
                                      PriceConverter.convertPrice(restaurant.minimumOrder), textDirection: TextDirection.ltr,
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2), color: Theme.of(context).primaryColor),
                                    ),
                                  ]),

                                ])),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                GetBuilder<WishListController>(builder: (wishController) {
                                  bool isWished = wishController.wishRestIdList.contains(restaurant!.id);
                                  return InkWell(
                                    onTap: () {
                                      if(Get.find<AuthController>().isLoggedIn()) {
                                        isWished ? wishController.removeFromWishList(restaurant!.id, true)
                                            : wishController.addToWishList(null, restaurant, true);
                                      }else {
                                        showCustomSnackBar('you_are_not_logged_in'.tr);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        isWished ? Icons.favorite : Icons.favorite_border,
                                        color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                        size: 24  - (scrollingRate * 4),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(width: Dimensions.paddingSizeLarge),

                              ]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  background: CustomImage(
                    fit: BoxFit.cover, placeholder: Images.restaurantCover,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantCoverPhotoUrl}/${restaurant!.coverPhoto}',
                  ),
                ),
                actions: const [
                  SizedBox()
                ],

              ),

              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.webMaxWidth,
                // padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : RestaurantDescriptionView(restaurant: restaurant),
                  restaurant.discount != null ? Container(
                    width: context.width,
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        restaurant.discount!.discountType == 'percent' ? '${restaurant.discount!.discount}% ${'off'.tr}'
                            : '${PriceConverter.convertPrice(restaurant.discount!.discount)} ${'off'.tr}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                      ),
                      Text(
                        restaurant.discount!.discountType == 'percent'
                            ? '${'enjoy'.tr} ${restaurant.discount!.discount}% ${'off_on_all_categories'.tr}'
                            : '${'enjoy'.tr} ${PriceConverter.convertPrice(restaurant.discount!.discount)}'
                            ' ${'off_on_all_categories'.tr}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                      ),
                      SizedBox(height: (restaurant.discount!.minPurchase != 0 || restaurant.discount!.maxDiscount != 0) ? 5 : 0),
                      restaurant.discount!.minPurchase != 0 ? Text(
                        '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.minPurchase)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                      ) : const SizedBox(),
                      restaurant.discount!.maxDiscount != 0 ? Text(
                        '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.maxDiscount)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                      ) : const SizedBox(),
                      Text(
                        '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(restaurant.discount!.startTime!)} '
                            '- ${DateConverter.convertTimeToTime(restaurant.discount!.endTime!)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                      ),
                    ]),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  restController.recommendedProductModel != null && restController.recommendedProductModel!.products!.isNotEmpty ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeLarge,
                          bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeLarge,
                        ),
                        child: Text('recommended_items'.tr, style: robotoMedium),
                      ),
                      // const SizedBox(height: Dimensions.paddingSizeSmall),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 150 : 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: restController.recommendedProductModel!.products!.length,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                              child: Container(
                                width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                child: ProductWidget(
                                  isRestaurant: false, product: restController.recommendedProductModel!.products![index],
                                  restaurant: null, index: index, length: null, isCampaign: false,
                                  inRestaurant: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ) : const SizedBox(),
                ]),
              ))),

              (restController.categoryList!.isNotEmpty) ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(height: 90, child: Center(child: Container(
                  width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Row(children: [
                        Text('all_products'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        const Expanded(child: SizedBox()),

                        InkWell(
                          onTap: ()=> Get.toNamed(RouteHelper.getSearchRestaurantProductRoute(restaurant!.id)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Icon(Icons.search, size: 28, color: Theme.of(context).primaryColor),
                          ),
                        ),

                        restController.type.isNotEmpty ? VegFilterWidget(
                          type: restController.type,
                          onSelected: (String type) {
                            restController.getRestaurantProductList(restController.restaurant!.id, 1, type, true);
                          },
                        ) : const SizedBox(),

                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    SizedBox(
                      height: 30,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: restController.categoryList!.length,
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => restController.setCategoryIndex(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                color: index == restController.categoryIndex ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(
                                  restController.categoryList![index].name!,
                                  style: index == restController.categoryIndex
                                      ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                      : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                ))),
              ) : const SliverToBoxAdapter(child: SizedBox()),

              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: Column(children: [
                  ProductView(
                    isRestaurant: false, restaurants: null,
                    products: restController.categoryList!.isNotEmpty ? restController.restaurantProducts : null,
                    inRestaurantPage: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeLarge,
                    ),
                  ),
                  restController.foodPaginate ? const Center(child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CircularProgressIndicator(),
                  )) : const SizedBox(),

                ]),
              ))),
            ],
          ) : const Center(child: CircularProgressIndicator());
        });
      }),

      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
        })
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Product> products;
  CategoryProduct(this.category, this.products);
}
