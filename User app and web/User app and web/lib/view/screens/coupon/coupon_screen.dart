import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/base/not_logged_in_screen.dart';
import 'package:efood_multivendor/view/screens/coupon/widget/coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CouponScreen extends StatefulWidget {
  final bool fromCheckout;

  const CouponScreen({Key? key, required this.fromCheckout}) : super(key: key);
  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  final bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<CouponController>().getCouponList();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: 'coupon'.tr),
      body: _isLoggedIn ? GetBuilder<CouponController>(builder: (couponController) {
        return couponController.couponList != null ? couponController.couponList!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await couponController.getCouponList();
          },
          child: Scrollbar(child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 3,
              ),
              itemCount: couponController.couponList!.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: couponController.couponList![index].code!));
                    showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                  },
                  child: CouponCard(couponController: couponController, index: index),
                  /*child: Stack(children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: Transform.rotate(
                        angle: Get.find<LocalizationController>().isLtr ? 0 : pi ,
                        child: Image.asset(
                          Images.couponBg,
                          height: ResponsiveHelper.isMobilePhone() ? 130 : 140, width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).primaryColor, fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Container(
                      height: ResponsiveHelper.isMobilePhone() ? 130 : 140,
                      alignment: Alignment.center,
                      child: Row(children: [

                        const SizedBox(width: 30),
                        Image.asset(Images.coupon, height: 50, width: 50, color: Theme.of(context).cardColor),

                        const SizedBox(width: 40),

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                            Text(
                              '${couponController.couponList![index].code} (${couponController.couponList![index].title})',
                              style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text(
                              '${couponController.couponList![index].discount}${couponController.couponList![index].discountType == 'percent' ? '%'
                                  : Get.find<SplashController>().configModel!.currencySymbol} off',
                              style: robotoMedium.copyWith(color: Theme.of(context).cardColor), textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Row(children: [
                              Text(
                                '${'valid_until'.tr}:',
                                style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                couponController.couponList![index].expireDate!,
                                style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ]),

                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                '${'type'.tr}:',
                                style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              couponController.couponList![index].restaurant == null ? Flexible(child: Text(
                                '${couponController.couponList![index].couponType!.tr}${couponController.couponList![index].couponType
                                    == 'restaurant_wise' ? ' (${couponController.couponList![index].data})' : ''}',
                                style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                              )) : const SizedBox(),

                              couponController.couponList![index].restaurant != null ? Flexible(child: Text(
                                '${couponController.couponList![index].couponType!.tr} (${couponController.couponList![index].restaurant!.name})',
                                style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              )) : const SizedBox(),
                            ]),

                            Row(children: [
                              Text(
                                '${'min_purchase'.tr}:',
                                style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                PriceConverter.convertPrice(couponController.couponList![index].minPurchase),
                                style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                              ),
                            ]),

                            Row(children: [
                              Text(
                                '${'max_discount'.tr}:',
                                style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                PriceConverter.convertPrice(couponController.couponList![index].maxDiscount),
                                style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                              ),
                            ]),

                          ]),
                        ),

                      ]),
                    ),

                  ]),*/
                );
              },
            ))),
          )),
        ) : NoDataScreen(text: 'no_coupon_found'.tr) : const Center(child: CircularProgressIndicator());
      }) : NotLoggedInScreen(callBack: (bool value)  {
        initCall();
        setState(() {});
      }),
    );
  }
}