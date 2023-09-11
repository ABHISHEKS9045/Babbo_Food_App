import 'package:efood_multivendor/controller/campaign_controller.dart';
import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/not_available_widget.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebCampaignView extends StatelessWidget {
  const WebCampaignView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
      return (campaignController.itemCampaignList != null && campaignController.itemCampaignList!.isEmpty) ? const SizedBox() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Text('trending_food_offers'.tr, style: robotoMedium.copyWith(fontSize: 24)),
          ),

          campaignController.itemCampaignList != null ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, childAspectRatio: (1/1.1),
              mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            itemCount: campaignController.itemCampaignList!.length > 3 ? 4 : campaignController.itemCampaignList!.length,
            itemBuilder: (context, index){
              double price = campaignController.itemCampaignList![index].price!;
              double discount = campaignController.itemCampaignList![index].discount!;
              double discountPrice = PriceConverter.convertWithDiscount(price, discount, campaignController.itemCampaignList![index].discountType)!;
              if(index == 3) {
                return InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getItemCampaignRoute()),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+${campaignController.itemCampaignList!.length-3}\n${'more'.tr}', textAlign: TextAlign.center,
                      style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: () {
                  ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                    ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true),
                    backgroundColor: Colors.transparent, isScrollControlled: true,
                  ) : Get.dialog(
                    Dialog(child: ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true)),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                    Stack(children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}'
                              '/${campaignController.itemCampaignList![index].image}',
                          height: 135, fit: BoxFit.cover, width: context.width/4,
                        ),
                      ),
                      DiscountTag(
                        discount: campaignController.itemCampaignList![index].restaurantDiscount! > 0
                            ? campaignController.itemCampaignList![index].restaurantDiscount
                            : campaignController.itemCampaignList![index].discount,
                        discountType: campaignController.itemCampaignList![index].restaurantDiscount! > 0 ? 'percent'
                            : campaignController.itemCampaignList![index].discountType,
                        fromTop: Dimensions.paddingSizeLarge, fontSize: Dimensions.fontSizeExtraSmall,
                      ),
                      Get.find<ProductController>().isAvailable(campaignController.itemCampaignList![index])
                          ? const SizedBox() : const NotAvailableWidget(),
                    ]),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            campaignController.itemCampaignList![index].name!,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text(
                            campaignController.itemCampaignList![index].restaurantName!,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Row(
                            children: [
                              Expanded(
                                child: Row(children: [
                                  Text(
                                    PriceConverter.convertPrice(discountPrice),
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                                  ),

                                  discountPrice < price ? Text(
                                    PriceConverter.convertPrice(price), textDirection: TextDirection.ltr,
                                    style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                                  ) : const SizedBox(),
                                ]),
                              ),
                              Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
                              Text(
                                campaignController.itemCampaignList![index].avgRating!.toStringAsFixed(1),
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),

                  ]),
                ),
              );
            },
          ) : WebPopularFoodShimmer(campaignController: campaignController),
        ],
      );
    });
  }
}

class WebPopularFoodShimmer extends StatelessWidget {
  final CampaignController campaignController;
  const WebPopularFoodShimmer({Key? key, required this.campaignController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: (1/1.1),
        mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: 8,
      itemBuilder: (context, index){
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: campaignController.itemCampaignList == null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 135,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                  color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 15, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                    const SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                    const SizedBox(height: 5),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(height: 10, width: 30, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                      const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    ]),
                  ]),
                ),
              ),

            ]),
          ),
        );
      },
    );
  }
}

