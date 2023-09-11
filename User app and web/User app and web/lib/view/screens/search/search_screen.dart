import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/search_controller.dart' as search;
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/bottom_cart_widget.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/search/widget/filter_widget.dart';
import 'package:efood_multivendor/view/screens/search/widget/search_field.dart';
import 'package:efood_multivendor/view/screens/search/widget/search_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedFoods();
    }
    Get.find<search.SearchController>().getHistoryList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(Get.find<search.SearchController>().isSearchMode) {
          return true;
        }else {
          Get.find<search.SearchController>().setSearchMode(true);
          return false;
        }
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        body: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: GetBuilder<search.SearchController>(builder: (searchController) {
            _searchController.text = searchController.searchText;
            return Column(children: [

              Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Row(children: [
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: SearchField(
                  controller: _searchController,
                  hint: 'search_food_or_restaurant'.tr,
                  suffixIcon: !searchController.isSearchMode ? Icons.filter_list : Icons.search,
                  iconPressed: () => _actionSearch(searchController, false),
                  onSubmit: (text) => _actionSearch(searchController, true),
                )),
                CustomButton(
                  onPressed: () => searchController.isSearchMode ? Get.back() : searchController.setSearchMode(true),
                  buttonText: 'cancel'.tr,
                  transparent: true,
                  width: 80,
                ),
              ]))),

              Expanded(child: searchController.isSearchMode ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  searchController.historyList.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('history'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

                    InkWell(
                      onTap: () => searchController.clearSearchAddress(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 4),
                        child: Text('clear_all'.tr, style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                        )),
                      ),
                    ),
                  ]) : const SizedBox(),

                  ListView.builder(
                    itemCount: searchController.historyList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(children: [
                        Row(children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => searchController.searchData(searchController.historyList[index]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Text(
                                  searchController.historyList[index],
                                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => searchController.removeHistory(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 20),
                            ),
                          )
                        ]),
                        index != searchController.historyList.length-1 ? const Divider() : const SizedBox(),
                      ]);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  (_isLoggedIn && searchController.suggestedFoodList != null) ? Text(
                    'suggestions'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  (_isLoggedIn && searchController.suggestedFoodList != null) ? searchController.suggestedFoodList!.isNotEmpty ?  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4, childAspectRatio: (1/ 0.4),
                      mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: searchController.suggestedFoodList!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                            ProductBottomSheet(product: searchController.suggestedFoodList![index]),
                            backgroundColor: Colors.transparent, isScrollControlled: true,
                          ) : Get.dialog(
                            Dialog(child: ProductBottomSheet(product: searchController.suggestedFoodList![index])),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Row(children: [
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}'
                                    '/${searchController.suggestedFoodList![index].image}',
                                width: 45, height: 45, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Text(
                              searchController.suggestedFoodList![index].name!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            )),
                          ]),
                        ),
                      );
                    },
                  ) : Padding(padding: const EdgeInsets.only(top: 10), child: Text('no_suggestions_available'.tr)) : const SizedBox(),
                ]))),
              ) : SearchResultWidget(searchText: _searchController.text.trim())),

            ]);
          }),
        )),

        bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
        }),
      ),
    );
  }

  void _actionSearch(search.SearchController searchController, bool isSubmit) {
    if(searchController.isSearchMode || isSubmit) {
      if(_searchController.text.trim().isNotEmpty) {
        searchController.searchData(_searchController.text.trim());
      }else {
        showCustomSnackBar('search_food_or_restaurant'.tr);
      }
    }else {
      List<double?> prices = [];
      if(!searchController.isRestaurant) {
        for (var product in searchController.allProductList!) {
          prices.add(product.price);
        }
        prices.sort();
      }
      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
      Get.dialog(FilterWidget(maxValue: maxValue, isRestaurant: searchController.isRestaurant));
    }
  }
}
