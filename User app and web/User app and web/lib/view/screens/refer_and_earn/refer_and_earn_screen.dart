import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/helper/link_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/not_logged_in_screen.dart';
import 'package:efood_multivendor/view/screens/refer_and_earn/widget/bottom_sheet_view.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';

enum ShareType {
  facebook,
  messenger,
  twitter,
  whatsapp,
}

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({Key? key}) : super(key: key);

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn() && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    String initialLink = 'StackFood://stackfood.com/category-product?id=5&name=QnVyZ2Vy';
    LinkConverter.convertDeepLink(initialLink);
    return Scaffold(
      appBar: CustomAppBar(title: 'refer'.tr),
      body: ExpandableBottomSheet(
        background:  isLoggedIn ? SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge),
          child:   Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: GetBuilder<UserController>(builder: (userController) {
                return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Image.asset(
                    Images.referImage, width: ResponsiveHelper.isDesktop(context) ? 200 : 500,
                    height: ResponsiveHelper.isDesktop(context) ? 250 : 150, fit: BoxFit.contain,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Text('earn_money_on_every_referral'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    '${'one_referral'.tr}= ${PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                        ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble() : 0.0)}',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 40),

                  Text('invite_friends_and_business'.tr , style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge), textAlign: TextAlign.center),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('copy_your_code_share_it_with_your_friends'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Text('your_personal_code'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  DottedBorder(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 1,
                    strokeCap: StrokeCap.butt,
                    dashPattern: const [8, 5],
                    padding: const EdgeInsets.all(0),
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(50),
                    child: SizedBox(
                      height: 50,
                      child: (userController.userInfoModel != null) ? Row(children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                            child: Text(
                              userController.userInfoModel != null ? userController.userInfoModel!.refCode ?? '' : '',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if(userController.userInfoModel!.refCode!.isNotEmpty){
                              Clipboard.setData(ClipboardData(text: '${userController.userInfoModel != null ? userController.userInfoModel!.refCode : ''}'));
                              showCustomSnackBar('referral_code_copied'.tr, isError: false);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(50)),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                            margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Text('copy'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeDefault)),
                          ),
                        ),
                      ]) : const CircularProgressIndicator(),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  InkWell(
                    onTap: () => Share.share('${'this_is_my_refer_code'.tr}: ${userController.userInfoModel!.refCode}'),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 5)],
                      ),
                      padding: const EdgeInsets.all(7),
                      child: const Icon(Icons.share),
                    ),
                  ),
                  // Wrap(children: [
                  //   InkWell(
                  //     onTap: () => onButtonTap(ShareType.messenger, userController.userInfoModel!.refCode!),
                  //     child: Image.asset(Images.messengerIcon, height: 40, width: 40),
                  //   ),
                  //   const SizedBox(width: Dimensions.paddingSizeSmall),
                  //
                  //   InkWell(
                  //     onTap: () => onButtonTap(ShareType.whatsapp, userController.userInfoModel!.refCode!),
                  //     child: Image.asset(Images.whatsappIcon, height: 40, width: 40),
                  //   ),
                  //   const SizedBox(width: Dimensions.paddingSizeSmall),
                  //
                  //   InkWell(
                  //     onTap: () => Share.share('${'this_is_my_refer_code'.tr}: ${userController.userInfoModel!.refCode}'),
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Theme.of(context).cardColor,
                  //         boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 5)],
                  //       ),
                  //       padding: const EdgeInsets.all(7),
                  //       child: const Icon(Icons.share),
                  //     ),
                  //   )
                  // ]),

                  ResponsiveHelper.isDesktop(context) ? const Padding(
                    padding: EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                    child: BottomSheetView(),
                  ) : const SizedBox(),


                ]);
              }
            ),
          ),


        ) : NotLoggedInScreen(callBack: (value){
          initCall();
          setState(() {});
        }),

        persistentContentHeight:  ResponsiveHelper.isDesktop(context) ? 0 : 60,
        expandableContent: ResponsiveHelper.isDesktop(context) || !isLoggedIn ? const SizedBox() : const BottomSheetView(),


      ),
    );
  }
}



