import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/auth/sign_in_screen.dart';
import 'package:efood_multivendor/view/screens/menu/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebMenuBar extends StatelessWidget implements PreferredSizeWidget {
  const WebMenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showJoin = (Get.find<SplashController>().configModel!.toggleDmRegistration!
        || Get.find<SplashController>().configModel!.toggleRestaurantRegistration!) && ResponsiveHelper.isDesktop(context);
    List<PopupMenuEntry> entryList = [];
    if(Get.find<SplashController>().configModel!.toggleDmRegistration!) {
      entryList.add(PopupMenuItem<int>(value: 0, child: Text('join_as_a_delivery_man'.tr)));
    }
    if(Get.find<SplashController>().configModel!.toggleRestaurantRegistration!) {
      entryList.add(PopupMenuItem<int>(value: 1, child: Text('join_as_a_restaurant'.tr)));
    }

    return Center(child: Container(
      width: Dimensions.webMaxWidth,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(children: [

        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getInitialRoute()),
          child: Image.asset(Images.logo, height: 60, width: 100),
        ),

        Get.find<LocationController>().getUserAddress() != null ? Expanded(child: InkWell(
          onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: GetBuilder<LocationController>(builder: (locationController) {
              return Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    locationController.getUserAddress()!.addressType == 'home' ? Icons.home_filled
                        : locationController.getUserAddress()!.addressType == 'office' ? Icons.work : Icons.location_on,
                    size: 20, color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Flexible(
                    child: Text(
                      locationController.getUserAddress()!.address!,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                ],
              );
            }),
          ),
        )) : const Expanded(child: SizedBox()),

        MenuButton(icon: Icons.home, title: 'home'.tr, onTap: () => Get.toNamed(RouteHelper.getInitialRoute())),
        const SizedBox(width: 20),
        MenuButton(icon: Icons.search, title: 'search'.tr, onTap: () => Get.toNamed(RouteHelper.getSearchRoute())),
        const SizedBox(width: 20),
        MenuButton(icon: Icons.notifications, title: 'notification'.tr, onTap: () => Get.toNamed(RouteHelper.getNotificationRoute())),
        const SizedBox(width: 20),
        MenuButton(icon: Icons.favorite_outlined, title: 'favourite'.tr, onTap: () => Get.toNamed(RouteHelper.getMainRoute('favourite'))),
        const SizedBox(width: 20),
        MenuButton(icon: Icons.shopping_cart, title: 'my_cart'.tr, isCart: true, onTap: () => Get.toNamed(RouteHelper.getCartRoute())),
        const SizedBox(width: 20),
        MenuButton(icon: Icons.menu, title: 'menu'.tr, onTap: () {
          Get.bottomSheet(const MenuScreen(), backgroundColor: Colors.transparent, isScrollControlled: true);
        }),
        const SizedBox(width: 20),
        GetBuilder<AuthController>(builder: (authController) {
          return MenuButton(
            icon: authController.isLoggedIn() ? Icons.shopping_bag : Icons.lock,
            title: authController.isLoggedIn() ? 'my_orders'.tr : 'sign_in'.tr,
            onTap: (){
              if(authController.isLoggedIn()){
                Get.toNamed(RouteHelper.getMainRoute('order'));
              }else{
                Get.dialog(const SignInScreen(exitFromApp: false, backFromThis: false));
              }
            },
            // onTap: () => Get.toNamed(authController.isLoggedIn() ? RouteHelper.getMainRoute('order') : RouteHelper.getSignInRoute(RouteHelper.main)),
          );
        }),
        SizedBox(width: showJoin ? 20 : 0),

        showJoin ? PopupMenuButton<dynamic>(
          itemBuilder: (BuildContext context) => entryList,
          onSelected: (dynamic value) {
            if(value == 0) {
              Get.toNamed(RouteHelper.getDeliverymanRegistrationRoute());
            }else {
              Get.toNamed(RouteHelper.getRestaurantRegistrationRoute());
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(children: [
              Text('join_us'.tr, style: robotoMedium.copyWith(color: Colors.white)),
              const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
            ]),
          ),
        ) : const SizedBox(),

      ]),
    ));
  }
  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 70);
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isCart;
  final Function onTap;
  const MenuButton({Key? key, required this.icon, required this.title, this.isCart = false, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Row(children: [
        Stack(clipBehavior: Clip.none, children: [

          Icon(icon, size: 20),

          isCart ? GetBuilder<CartController>(builder: (cartController) {
            return cartController.cartList.isNotEmpty ? Positioned(
              top: -5, right: -5,
              child: Container(
                height: 15, width: 15, alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                child: Text(
                  cartController.cartList.length.toString(),
                  style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).cardColor),
                ),
              ),
            ) : const SizedBox();
          }) : const SizedBox(),
        ]),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
      ]),
    );
  }
}

