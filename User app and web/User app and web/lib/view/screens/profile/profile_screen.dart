import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/auth/sign_in_screen.dart';
import 'package:efood_multivendor/view/screens/profile/widget/profile_button.dart';
import 'package:efood_multivendor/view/screens/profile/widget/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
     _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    if(_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showWalletCard = Get.find<SplashController>().configModel!.customerWalletStatus == 1
        || Get.find<SplashController>().configModel!.loyaltyPointStatus == 1;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<UserController>(builder: (userController) {
        return (_isLoggedIn && userController.userInfoModel == null) ? const Center(child: CircularProgressIndicator()) :
          Center(
            child: SingleChildScrollView(
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: Dimensions.webMaxWidth, height: context.height,
                  child: Center(
                    child: Column(
                      children: [

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraLarge),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            !ResponsiveHelper.isDesktop(context) ? IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back_ios),
                            ) : const SizedBox(),

                            Text('profile'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                            const SizedBox(width: 50),
                          ]),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeExtraLarge),
                          child: Row(children: [

                            ClipOval(child: CustomImage(
                              placeholder: Images.guestIcon,
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                                  '/${(userController.userInfoModel != null && _isLoggedIn) ? userController.userInfoModel!.image : ''}',
                              height: 70, width: 70, fit: BoxFit.cover,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeDefault),

                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  _isLoggedIn ? '${userController.userInfoModel!.fName} ${userController.userInfoModel!.lName}' : 'guest_user'.tr,
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                _isLoggedIn ? Text(
                                  '${'joined'.tr} ${DateConverter.containTAndZToUTCFormat(userController.userInfoModel!.createdAt!)}',
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                ) : InkWell(
                                  onTap: () async {
                                    if(!ResponsiveHelper.isDesktop(context)) {
                                      await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                                    }else{
                                      Get.dialog(const SignInScreen(exitFromApp: false, backFromThis: true));
                                    }
                                  },
                                  child: Text(
                                    'login_to_view_all_feature'.tr,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ]),
                            ),

                            _isLoggedIn ? InkWell(
                              onTap: ()=> Get.toNamed(RouteHelper.getUpdateProfileRoute()),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                    boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 5, spreadRadius: 1, offset: const Offset(3, 3))]
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: const Icon(Icons.edit_outlined, size: 24, color: Colors.blue),
                              ),
                            ) : InkWell(
                              onTap: () async {
                                if(!ResponsiveHelper.isDesktop(context)) {
                                  await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                                }else{
                                  Get.dialog(const SignInScreen(exitFromApp: false, backFromThis: true));
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                                child: Text(
                                  'login'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                                ),
                              ),
                            )

                          ]),
                        ),


                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                                color: Theme.of(context).colorScheme.background,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                            child: Column(children: [

                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              (showWalletCard && _isLoggedIn) ? Row(children: [

                                Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? Expanded(child: ProfileCard(
                                  image: Images.loyaltyIcon,
                                  data: userController.userInfoModel!.loyaltyPoint != null ? userController.userInfoModel!.loyaltyPoint.toString() : '0',
                                  title: 'loyalty_points'.tr,
                                )) : const SizedBox(),

                                SizedBox(width: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? Dimensions.paddingSizeSmall : 0),

                                _isLoggedIn ?  Expanded(child: ProfileCard(
                                  image: Images.shoppingBagIcon,
                                  data: userController.userInfoModel!.orderCount.toString(),
                                  title: 'total_order'.tr,
                                )) : const SizedBox(),

                                SizedBox(width: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Dimensions.paddingSizeSmall : 0),

                                Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Expanded(child: ProfileCard(
                                  image: Images.walletProfile,
                                  data: PriceConverter.convertPrice(userController.userInfoModel!.walletBalance),
                                  title: 'wallet_balance'.tr,
                                )) : const SizedBox(),

                              ]) : const SizedBox(),

                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              ProfileButton(icon: Icons.tonality_outlined, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                                Get.find<ThemeController>().toggleTheme();
                              }),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              _isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
                                return ProfileButton(
                                  icon: Icons.notifications, title: 'notification'.tr,
                                  isButtonActive: authController.notification, onTap: () {
                                  authController.setNotificationActive(!authController.notification);
                                },
                                );
                              }) : const SizedBox(),
                              SizedBox(height: _isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                              _isLoggedIn ? userController.userInfoModel!.socialId == null ? ProfileButton(icon: Icons.lock, title: 'change_password'.tr, onTap: () {
                                Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change'));
                              }) : const SizedBox() : const SizedBox(),
                              SizedBox(height: _isLoggedIn ? userController.userInfoModel!.socialId == null ? Dimensions.paddingSizeSmall : 0 : 0),

                              _isLoggedIn ? ProfileButton(
                                icon: Icons.delete,
                                iconImage: Images.profileDelete,
                                title: 'delete_account'.tr,
                                onTap: () {
                                  Get.dialog(ConfirmationDialog(
                                    icon: Images.support,
                                    title: 'are_you_sure_to_delete_account'.tr,
                                    description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                                    onYesPressed: () => userController.removeUser(),
                                  ), useSafeArea: false);
                                },
                              ) : const SizedBox(),
                              SizedBox(height: _isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text(AppConstants.appVersion.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                              ]),
                            ]),
                          ),
                        )



                      ],
                    ),
                  ),
              ),
            ),
          );


      }),
    );
  }
}
