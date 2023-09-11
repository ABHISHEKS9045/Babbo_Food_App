import 'package:efood_multivendor/controller/cuisine_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebCuisineView extends StatelessWidget {
  const WebCuisineView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CuisineController>(builder: (cuisineController) {
      return (cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isEmpty) ? const SizedBox() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Text('cuisines'.tr, style: robotoMedium.copyWith(fontSize: 24)),
          ),

          cuisineController.cuisineModel != null ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, childAspectRatio: (1/0.8),
              mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            itemCount: cuisineController.cuisineModel!.cuisines!.length > 3 ? 4 : cuisineController.cuisineModel!.cuisines!.length,
            itemBuilder: (context, index){

              return Stack(children: [
                InkWell(
                  onTap: () =>  Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.cuisineImageUrl}'
                              '/${cuisineController.cuisineModel!.cuisines![index].image}',
                          height: 135, fit: BoxFit.cover, width: context.width/4,
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: Center(
                            child: Text(
                              cuisineController.cuisineModel!.cuisines![index].name!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                    ]),
                  ),
                ),

                Visibility(
                  visible: index == 3,
                  child: Positioned(
                    top: 0, bottom: 0, left: 0, right: 0,
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getCuisineRoute()),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          gradient: LinearGradient(colors: [
                            Theme.of(context).primaryColor.withOpacity(0.7),
                            Theme.of(context).primaryColor.withOpacity(1),
                          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+${cuisineController.cuisineModel!.cuisines!.length-3}\n${'more'.tr}', textAlign: TextAlign.center,
                          style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                  ),
                )
              ]);
            },
          ) : WebCuisineShimmer(cuisineController: cuisineController),
        ],
      );
    });
  }
}

class WebCuisineShimmer extends StatelessWidget {
  final CuisineController cuisineController;
  const WebCuisineShimmer({Key? key, required this.cuisineController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: (1/0.75),
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
            enabled: cuisineController.cuisineModel == null,
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

