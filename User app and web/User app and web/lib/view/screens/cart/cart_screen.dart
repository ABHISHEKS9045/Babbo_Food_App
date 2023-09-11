import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/base/product_widget.dart';
import 'package:efood_multivendor/view/base/web_constrained_box.dart';
import 'package:efood_multivendor/view/screens/cart/widget/cart_product_widget.dart';
import 'package:efood_multivendor/view/screens/cart/widget/not_available_bottom_sheet.dart';
import 'package:efood_multivendor/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({Key? key, required this.fromNav}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: Get.find<CartController>().cartList[0].product!.restaurantId, name: null), fromCart: true);
    Get.find<CartController>().calculationCart();
    if(Get.find<CartController>().cartList.isNotEmpty){
      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(isUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, isUpdate: false);
      Get.find<RestaurantController>().getCartRestaurantSuggestedItemList(Get.find<CartController>().cartList[0].product!.restaurantId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_cart'.tr, isBackButtonExist: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      body: GetBuilder<CartController>(builder: (cartController) {

          return cartController.cartList.isNotEmpty ? Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(top: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Product

                          Row(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    WebConstrainedBox(
                                      dataLength: cartController.cartList.length, minLength: 5, minHeight: 0.6,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                            itemCount: cartController.cartList.length,
                                            itemBuilder: (context, index) {
                                              return CartProductWidget(
                                                cart: cartController.cartList[index], cartIndex: index, addOns: cartController.addOnsList[index],
                                                isAvailable: cartController.availableList[index],
                                              );
                                            },
                                          ),
                                          // const SizedBox(height: Dimensions.paddingSizeSmall),

                                          const Divider(thickness: 0.5, height: 5),

                                          Padding(
                                            padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                                            child: TextButton.icon(
                                              onPressed: (){
                                                Get.toNamed(
                                                  RouteHelper.getRestaurantRoute(cartController.cartList[0].product!.restaurantId),
                                                  arguments: RestaurantScreen(restaurant: Restaurant(id: cartController.cartList[0].product!.restaurantId)),
                                                );
                                              },
                                              icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
                                              label: Text('add_more_items'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                                            ),
                                          ),

                                          !ResponsiveHelper.isDesktop(context) ? suggestedItemView(cartController.cartList) : const SizedBox(),
                                      ]),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),

                                    //Pricing View
                                    !ResponsiveHelper.isDesktop(context) ? pricingView(cartController, cartController.cartList[0].product!) : const SizedBox(),
                                  ],
                                )
                              ),


                              ResponsiveHelper.isDesktop(context) ? Expanded(flex: 4, child: pricingView(cartController, cartController.cartList[0].product!)) : const SizedBox(),

                            ],
                          ),

                          ResponsiveHelper.isDesktop(context) ? suggestedItemView(cartController.cartList) : const SizedBox(),


                        ]),
                      ),
                    ),
                  ),
                ),
              ),

              ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : CheckoutButton(cartController: cartController, availableList: cartController.availableList),

            ],
          ) : const NoDataScreen(isCart: true, text: '');
        },
      ),
    );
  }



  Widget suggestedItemView(List<CartModel> cartList){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(Get.find<ThemeController>().darkTheme ? 0 : 1),
      ),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<RestaurantController>(builder: (restaurantController) {
          List<Product>? suggestedItems;
          if(restaurantController.suggestedItems != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.product!.id!);
            }
            for (Product item in restaurantController.suggestedItems!) {
              if(cartIds.contains(item.id)){
                if (kDebugMode) {
                  print('it will not added -> ${restaurantController.suggestedItems!.indexOf(item)}');
                }
              }else{
                suggestedItems.add(item);
              }
            }
          }
          return restaurantController.suggestedItems != null && suggestedItems!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              ),

              SizedBox(
                height: ResponsiveHelper.isDesktop(context) ? 160 : 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ProductWidget(
                          isRestaurant: false,
                          product: suggestedItems![index],
                          fromCartSuggestion: true,
                          restaurant: null, index: index, length: null, isCampaign: false,
                          inRestaurant: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox();
        }),
      ]),
    );
  }


  Widget pricingView(CartController cartController, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: GetBuilder<RestaurantController>(
        builder: (restaurantController) {
          return Column(children: [

            (restaurantController.restaurant != null && restaurantController.restaurant!.cutlery!) ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                Icon(Icons.flatware, size: ResponsiveHelper.isDesktop(context) ? 30 : 25, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ),

                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: cartController.addCutlery,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      cartController.updateCutlery();
                    },
                    trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                )

              ]),
            ) : const SizedBox(),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: (){
                      if(ResponsiveHelper.isDesktop(context)){
                        Get.dialog(const Dialog(child: NotAvailableBottomSheet()));
                      }else{
                        showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                          builder: (con) => const NotAvailableBottomSheet(),
                        );
                      }
                    },
                    child: Row(children: [
                      Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.arrow_forward_ios_sharp, size: 18),
                    ]),
                  ),


                  cartController.notAvailableIndex != -1 ? Row(children: [
                    Text(cartController.notAvailableList[cartController.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    IconButton(
                      onPressed: ()=> cartController.setAvailableIndex(-1),
                      icon: const Icon(Icons.clear, size: 18),
                    )
                  ]) : const SizedBox(),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('item_price'.tr, style: robotoRegular),
                  PriceConverter.convertAnimationPrice(cartController.itemPrice, textStyle: robotoRegular),
                  // Text(PriceConverter.convertPrice(cartController.itemPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('discount'.tr, style: robotoRegular),
                  restaurantController.restaurant != null ? Row(children: [
                    Text('(-)', style: robotoRegular),
                    PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoRegular),
                  ]) : Text('calculating'.tr, style: robotoRegular),
                  // Text('(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('addons'.tr, style: robotoRegular),
                    Row(children: [
                      Text('(+)', style: robotoRegular),
                      PriceConverter.convertAnimationPrice(cartController.addOns, textStyle: robotoRegular),
                    ]),
                    // Text('(+) ${PriceConverter.convertPrice(cartController.addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ],
                ),

              ]),
            ),

           ResponsiveHelper.isDesktop(context) ? CheckoutButton(cartController: cartController, availableList: cartController.availableList) : const SizedBox.shrink(),

          ]);
        }
      ),
    );
  }

}



class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  const CheckoutButton({Key? key, required this.cartController, required this.availableList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 10)]
      ),
      child: SafeArea(
        child: GetBuilder<RestaurantController>(
            builder: (storeController) {
              if(Get.find<RestaurantController>().restaurant != null && !Get.find<RestaurantController>().restaurant!.freeDelivery! &&  Get.find<SplashController>().configModel!.freeDeliveryOver != null){
                percentage = cartController.subTotal/Get.find<SplashController>().configModel!.freeDeliveryOver!;
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  (storeController.restaurant != null && !storeController.restaurant!.freeDelivery!
                  && Get.find<SplashController>().configModel!.freeDeliveryOver != null && percentage < 1)
                  ? Column(children: [
                      Row(children: [
                        Image.asset(Images.percentTag, height: 20, width: 20),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        PriceConverter.convertAnimationPrice(
                          Get.find<SplashController>().configModel!.freeDeliveryOver! - cartController.subTotal,
                          textStyle: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                        ),

                        // Text(PriceConverter.convertPrice(Get.find<SplashController>().configModel!.freeDeliveryOver! - cartController.subTotal), style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      LinearProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        value: percentage,
                      ),
                  ]) : const SizedBox(),


                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('subtotal'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                        PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),

                        // Text(
                        //   PriceConverter.convertPrice(cartController.subTotal),
                        //   style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                        // ),
                      ],
                    ),
                  ),

                  CustomButton(
                    radius: 10,
                    buttonText: 'proceed_to_checkout'.tr, onPressed: () {
                    if(!cartController.cartList.first.product!.scheduleOrder! && cartController.availableList.contains(false)) {
                      showCustomSnackBar('one_or_more_product_unavailable'.tr);
                    } else {
                      Get.find<CouponController>().removeCouponData(false);
                      Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                    }
                  }),

                ],
              );
            }
        ),
      ),
    );
  }
}
