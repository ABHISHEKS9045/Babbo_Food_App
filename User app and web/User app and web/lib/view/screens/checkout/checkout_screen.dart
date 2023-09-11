import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_dropdown.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/base/not_logged_in_screen.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_widget.dart';
import 'package:efood_multivendor/view/screens/cart/widget/delivery_option_button.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/condition_check_box.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/coupon_bottom_sheet.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/delivery_instruction_view.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/order_type_widget.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_method_bottom_sheet.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/subscription_view.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/time_slot_bottom_sheet.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/tips_widget.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel>? cartList;
  final bool fromCart;
  const CheckoutScreen({Key? key, required this.fromCart, required this.cartList}) : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tipController = TextEditingController(text: '0');
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive;
  bool? _isDigitalPaymentActive;
  late bool _isWalletActive;
  late List<CartModel> _cartList;

  List<AddressModel> address = [];
  bool firstTime = true;
  final tooltipController1 = JustTheController();
  final tooltipController2 = JustTheController();
  final tooltipController3 = JustTheController();


  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<LocationController>().getZone(
          Get.find<LocationController>().getUserAddress()!.latitude,
          Get.find<LocationController>().getUserAddress()!.longitude, false, updateInAddress: true
      );
      Get.find<CouponController>().setCoupon('');

      Get.find<OrderController>().stopLoader(isUpdate: false);
      Get.find<OrderController>().updateTimeSlot(0, notify: false);

      if(Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo();
      }
      if(Get.find<LocationController>().addressList == null) {
        Get.find<LocationController>().getAddressList();
      }
      Get.find<CouponController>().getCouponList();
      _isCashOnDeliveryActive = Get.find<SplashController>().configModel!.cashOnDelivery;
      _isDigitalPaymentActive = Get.find<SplashController>().configModel!.digitalPayment;
      _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
      Get.find<OrderController>().setPaymentMethod(_isCashOnDeliveryActive! ? 0 : _isDigitalPaymentActive! ? 1 : 2, isUpdate: false);
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Get.find<CartController>().cartList) : _cartList.addAll(widget.cartList!);
      Get.find<RestaurantController>().initCheckoutData(_cartList[0].product!.restaurantId);

      Get.find<OrderController>().updateTips(
        Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 0, notify: false,
      );
      _tipController.text = Get.find<OrderController>().selectedTips != -1 ? AppConstants.tips[Get.find<OrderController>().selectedTips] : '';

    }
  }

  @override
  void dispose() {
    super.dispose();
    _streetNumberController.dispose();
    _houseController.dispose();
    _floorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      body: isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<RestaurantController>(builder: (restController) {
          bool todayClosed = false;
          bool tomorrowClosed = false;
          List<DropdownItem<int>> addressList = [];
          addressList.add(
            DropdownItem<int>(value: 0, child: SizedBox(
              width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
              child: AddressWidget(
                address: Get.find<LocationController>().getUserAddress(),
                fromAddress: false, fromCheckout: true,
              ),
            ))
          );
          address.add(locationController.getUserAddress()!);

          if(restController.restaurant != null) {
            if(locationController.addressList != null) {
              for(int index=0; index<locationController.addressList!.length; index++) {
                if(locationController.addressList![index].zoneIds!.contains(restController.restaurant!.zoneId)) {

                  address.add(locationController.addressList![index]);

                  addressList.add(DropdownItem<int>(value: index + 1, child: SizedBox(
                    width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
                    child: AddressWidget(
                      address: locationController.addressList![index],
                      fromAddress: false, fromCheckout: true,
                    ),
                  )));
                }
              }
            }
            todayClosed = restController.isRestaurantClosed(true, restController.restaurant!.active!, restController.restaurant!.schedules);
            tomorrowClosed = restController.isRestaurantClosed(false, restController.restaurant!.active!, restController.restaurant!.schedules);
            _taxPercent = restController.restaurant!.tax;
          }
          return GetBuilder<CouponController>(builder: (couponController) {
            return GetBuilder<OrderController>(builder: (orderController) {
              bool showTips = orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !orderController.subscriptionOrder;
              double deliveryCharge = -1;
              double charge = -1;
              double? maxCodOrderAmount;
              if(restController.restaurant != null && orderController.distance != null && orderController.distance != -1 ) {
                ZoneData zoneData = Get.find<LocationController>().getUserAddress()!.zoneData!.firstWhere((data) => data.id == restController.restaurant!.zoneId);
                double perKmCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.perKmShippingCharge!
                    : zoneData.perKmShippingCharge ?? 0;

                double minimumCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.minimumShippingCharge!
                    :  zoneData.minimumShippingCharge ?? 0;

                double? maximumCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.maximumShippingCharge
                : zoneData.maximumShippingCharge;

                deliveryCharge = orderController.distance! * perKmCharge;
                charge = orderController.distance! * perKmCharge;

                if(deliveryCharge < minimumCharge) {
                  deliveryCharge = minimumCharge;
                  charge = minimumCharge;
                }

                if(restController.restaurant!.selfDeliverySystem == 0 && orderController.extraCharge != null){
                  deliveryCharge = deliveryCharge + orderController.extraCharge!;
                  charge = charge + orderController.extraCharge!;
                }

                if(maximumCharge != null && deliveryCharge > maximumCharge){
                  deliveryCharge = maximumCharge;
                  charge = maximumCharge;
                }

                if(restController.restaurant!.selfDeliverySystem == 0 && zoneData.increasedDeliveryFeeStatus == 1){
                  deliveryCharge = deliveryCharge + (deliveryCharge * (zoneData.increasedDeliveryFee!/100));
                  charge = charge + charge * (zoneData.increasedDeliveryFee!/100);
                }

                if(zoneData.maxCodOrderAmount != null) {
                  maxCodOrderAmount = zoneData.maxCodOrderAmount;
                }
              }

              double price = 0;
              double? discount = 0;
              double? couponDiscount = couponController.discount;
              double tax = 0;
              bool taxIncluded = Get.find<SplashController>().configModel!.taxIncluded == 1;
              double addOns = 0;
              double subTotal = 0;
              double orderAmount = 0;
              bool restaurantSubscriptionActive = false;
              int subscriptionQty = orderController.subscriptionOrder ? 0 : 1;
              if(restController.restaurant != null) {

                restaurantSubscriptionActive =  restController.restaurant!.orderSubscriptionActive! && widget.fromCart;

                if(restaurantSubscriptionActive){
                  if(orderController.subscriptionOrder && orderController.subscriptionRange != null) {
                    if(orderController.subscriptionType == 'weekly') {
                      List<int> weekDays = [];
                      for(int index=0; index<orderController.selectedDays.length; index++) {
                        if(orderController.selectedDays[index] != null) {
                          weekDays.add(index + 1);
                        }
                      }
                      subscriptionQty = DateConverter.getWeekDaysCount(orderController.subscriptionRange!, weekDays);
                    }else if(orderController.subscriptionType == 'monthly') {
                      List<int> days = [];
                      for(int index=0; index<orderController.selectedDays.length; index++) {
                        if(orderController.selectedDays[index] != null) {
                          days.add(index + 1);
                        }
                      }
                      subscriptionQty = DateConverter.getMonthDaysCount(orderController.subscriptionRange!, days);
                    }else {
                      subscriptionQty = orderController.subscriptionRange!.duration.inDays;
                    }
                  }
                }

                for (var cartModel in _cartList) {
                  List<AddOns> addOnList = [];
                  for (var addOnId in cartModel.addOnIds!) {
                    for (AddOns addOns in cartModel.product!.addOns!) {
                      if (addOns.id == addOnId.id) {
                        addOnList.add(addOns);
                        break;
                      }
                    }
                  }

                  for (int index = 0; index < addOnList.length; index++) {
                    addOns = addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
                  }
                  price = price + (cartModel.price! * cartModel.quantity!);
                  double? dis = (restController.restaurant!.discount != null
                      && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
                      ? restController.restaurant!.discount!.discount : cartModel.product!.discount;
                  String? disType = (restController.restaurant!.discount != null
                      && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
                      ? 'percent' : cartModel.product!.discountType;
                  discount = discount! + ((cartModel.price! - PriceConverter.convertWithDiscount(cartModel.price, dis, disType)!) * cartModel.quantity!);
                }
                if (restController.restaurant != null && restController.restaurant!.discount != null) {
                  if (restController.restaurant!.discount!.maxDiscount != 0 && restController.restaurant!.discount!.maxDiscount! < discount!) {
                    discount = restController.restaurant!.discount!.maxDiscount;
                  }
                  if (restController.restaurant!.discount!.minPurchase != 0 && restController.restaurant!.discount!.minPurchase! > (price + addOns)) {
                    discount = 0;
                  }
                }
                price = PriceConverter.toFixed(price);
                addOns = PriceConverter.toFixed(addOns);
                discount = PriceConverter.toFixed(discount!);
                couponDiscount = PriceConverter.toFixed(couponDiscount!);
                subTotal = price + addOns;
                orderAmount = (price - discount) + addOns - couponDiscount;

                if (orderController.orderType == 'take_away' || restController.restaurant!.freeDelivery!
                    || (Get.find<SplashController>().configModel!.freeDeliveryOver != null && orderAmount
                        >= Get.find<SplashController>().configModel!.freeDeliveryOver!) || couponController.freeDelivery) {
                  deliveryCharge = 0;
                }
              }

              if(taxIncluded){
                tax = orderAmount * _taxPercent! /(100 + _taxPercent!);
              }else {
                tax = PriceConverter.calculation(orderAmount, _taxPercent, 'percent', 1);
              }
              tax = PriceConverter.toFixed(tax);
              deliveryCharge = PriceConverter.toFixed(deliveryCharge);
              double total = subTotal + deliveryCharge - discount- couponDiscount! + (taxIncluded ? 0 : tax) + (showTips ? orderController.tips : 0);
              total = PriceConverter.toFixed(total);

              return (orderController.distance != null && locationController.addressList != null && restController.restaurant != null) ? Column(
                children: [
                  Expanded(child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Expanded(child: topSection(restController, charge, deliveryCharge, orderController, locationController, addressList, tomorrowClosed, todayClosed, price, discount, addOns, restaurantSubscriptionActive, showTips),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeLarge),

                            Expanded(child: bottomSection(orderController, total,  subTotal, discount, couponController, taxIncluded, tax, deliveryCharge, restController, locationController, todayClosed, tomorrowClosed, orderAmount, maxCodOrderAmount, subscriptionQty)),
                          ]),
                        ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          /// TopSection
                          topSection(restController, charge, deliveryCharge, orderController, locationController, addressList, tomorrowClosed, todayClosed, price, discount, addOns, restaurantSubscriptionActive, showTips),

                          ///BottomSection
                          bottomSection(orderController, total,  subTotal, discount, couponController, taxIncluded, tax, deliveryCharge, restController, locationController, todayClosed, tomorrowClosed, orderAmount, maxCodOrderAmount, subscriptionQty),

                        ]),
                      ),
                    ),
                  )),

                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(
                              'total_amount'.tr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                            PriceConverter.convertAnimationPrice(
                              total,
                              textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                            // Text(
                            //   PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                            //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            // ),
                          ]),
                        ),

                        _orderPlaceButton(orderController, restController, locationController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge,
                            tax, discount, total, maxCodOrderAmount, subscriptionQty),
                      ],
                    ),
                  ),

                ],
              ) : const Center(child: CircularProgressIndicator());

            });
          });
        });
      }) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }


  Widget topSection(RestaurantController restController, double charge, double deliveryCharge, OrderController orderController,
      LocationController locationController, List<DropdownItem<int>> addressList, bool tomorrowClosed, bool todayClosed,
      double price, double discount, double addOns, bool restaurantSubscriptionActive, bool showTips) {

    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: Column(children: [

        _isCashOnDeliveryActive! && restaurantSubscriptionActive ? Container(
          width: context.width,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('order_type'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Row(children: [
              Expanded(child: OrderTypeWidget(
                title: 'regular_order'.tr,
                subtitle: 'place_an_order_and_enjoy'.tr,
                icon: Images.regularOrder,
                isSelected: !orderController.subscriptionOrder,
                onTap: () {
                  orderController.setSubscription(false);
                  orderController.updateTips(
                    Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 1, notify: false,
                  );
                },
              )),
              SizedBox(width: _isCashOnDeliveryActive! ? Dimensions.paddingSizeSmall : 0),

              Expanded(child: OrderTypeWidget(
                title: 'subscription_order'.tr,
                subtitle: 'place_order_and_enjoy_it_everytime'.tr,
                icon: Images.subscriptionOrder,
                isSelected: orderController.subscriptionOrder,
                onTap: () {
                  orderController.setSubscription(true);
                  orderController.addTips(0);
                },
              )),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            orderController.subscriptionOrder ? SubscriptionView(
              orderController: orderController,
            ) : const SizedBox(),
            SizedBox(height: orderController.subscriptionOrder ? Dimensions.paddingSizeLarge : 0),
          ]),
        ) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        restController.restaurant != null ? Container(
          width: context.width,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('delivery_option'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [

              (Get.find<SplashController>().configModel!.homeDelivery! && restController.restaurant!.delivery!)
                  ? DeliveryOptionButton(
                value: 'delivery', title: 'home_delivery'.tr, charge: charge, isFree: restController.restaurant!.freeDelivery,
              ) : const SizedBox(),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              (Get.find<SplashController>().configModel!.takeAway! && restController.restaurant!.takeAway!)
                  ? DeliveryOptionButton(
                value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true,
              ) : const SizedBox(),

            ])),
          ]),
        ) : const SizedBox(),

        SizedBox(height: orderController.orderType != 'take_away' ? Dimensions.paddingSizeLarge : 0),
        (orderController.orderType != 'take_away') ? Center(child: Text('${'delivery_charge'.tr}: ${(orderController.orderType == 'take_away'
            || (orderController.orderType == 'delivery' ? restController.restaurant!.freeDelivery! : true)) ? 'free'.tr
            : charge != -1 ? PriceConverter.convertPrice(orderController.orderType == 'delivery' ? charge : deliveryCharge)
            : 'calculating'.tr}', textDirection: TextDirection.ltr)) : const SizedBox(),
        SizedBox(height: orderController.orderType != 'take_away' ? Dimensions.paddingSizeLarge : 0),

        orderController.orderType != 'take_away' ? Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          color: Theme.of(context).cardColor,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('deliver_to'.tr, style: robotoMedium),
              InkWell(
                onTap: () async{
                  var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, restController.restaurant!.zoneId));
                  if(address != null){
                    _streetNumberController.text = address.road ?? '';
                    _houseController.text = address.house ?? '';
                    _floorController.text = address.floor ?? '';

                    orderController.getDistanceInMeter(
                      LatLng(double.parse(address.latitude), double.parse(address.longitude )),
                      LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  child: Row(children: [
                    Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text('add_new'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                  ]),
                ),
              ),
            ]),


            Container(
              constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: CustomDropdown<int>(
                onChange: (int? value, int index) {
                  if(restController.restaurant!.selfDeliverySystem == 0) {
                    orderController.getDistanceInMeter(
                      LatLng(
                        double.parse(index == 0 ? locationController.getUserAddress()!.latitude! : address[index].latitude!),
                        double.parse(index == 0 ? locationController.getUserAddress()!.longitude! : address[index].longitude!),
                      ),
                      LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                    );
                  }
                  orderController.setAddressIndex(index);

                  _streetNumberController.text = orderController.addressIndex == 0 ? locationController.getUserAddress()!.road ?? '' : address[orderController.addressIndex].road ?? '';
                  _houseController.text = orderController.addressIndex == 0 ? locationController.getUserAddress()!.house ?? '' : address[orderController.addressIndex].house ?? '';
                  _floorController.text = orderController.addressIndex == 0 ? locationController.getUserAddress()!.floor ?? '' : address[orderController.addressIndex].floor ?? '';

                },
                dropdownButtonStyle: DropdownButtonStyle(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall,
                    horizontal: Dimensions.paddingSizeExtraSmall,
                  ),
                  primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                dropdownStyle: DropdownStyle(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                ),
                items: addressList,
                child: AddressWidget(
                  address: address[orderController.addressIndex],
                  fromAddress: false, fromCheckout: true,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            CustomTextField(
              titleText: 'street_number'.tr,
              inputType: TextInputType.streetAddress,
              focusNode: _streetNode,
              nextFocus: _houseNode,
              controller: _streetNumberController,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),


            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    titleText: 'house'.tr,
                    inputType: TextInputType.text,
                    focusNode: _houseNode,
                    nextFocus: _floorNode,
                    controller: _houseController,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomTextField(
                    titleText: 'floor'.tr,
                    inputType: TextInputType.text,
                    focusNode: _floorNode,
                    inputAction: TextInputAction.done,
                    controller: _floorController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          ]),
        ) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        //delivery instruction
        (orderController.orderType != 'take_away') ? const DeliveryInstructionView() : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        // Time Slot
        (widget.fromCart && !orderController.subscriptionOrder && restController.restaurant!.scheduleOrder!) ?  Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('preference_time'.tr, style: robotoMedium),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController2,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('schedule_time_tool_tip'.tr,style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => tooltipController2.showTooltip(),
                  child: const Icon(Icons.info_outline),
                ),
                // child: const Icon(Icons.info_outline),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            InkWell(
              onTap: (){
                if(ResponsiveHelper.isDesktop(context)){
                  showDialog(context: context, builder: (con) => Dialog(
                    child: TimeSlotBottomSheet(
                      tomorrowClosed: tomorrowClosed,
                      todayClosed: todayClosed,
                    ),
                  ));
                }else{
                  showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (con) => TimeSlotBottomSheet(
                      tomorrowClosed: tomorrowClosed,
                      todayClosed: todayClosed,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                height: 50,
                child: Row(children: [
                  const SizedBox(width: Dimensions.paddingSizeLarge),
                  Expanded(child: Text(
                      (orderController.selectedDateSlot == 0 && todayClosed) ? 'restaurant_is_closed'.tr
                          : orderController.preferableTime.isNotEmpty ? orderController.preferableTime : 'now'.tr,
                    style: robotoRegular.copyWith(color: (orderController.selectedDateSlot == 0 && todayClosed) ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyMedium!.color),
                  )),

                  const Icon(Icons.arrow_drop_down_outlined),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Icon(Icons.access_time_filled_outlined, color: Theme.of(context).primaryColor),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        ) : const SizedBox(),
        SizedBox(height: (widget.fromCart && !orderController.subscriptionOrder && restController.restaurant!.scheduleOrder!) ? Dimensions.paddingSizeSmall : 0),


        // Coupon
        GetBuilder<CouponController>(
          builder: (couponController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('promo_code'.tr, style: robotoMedium),
                  InkWell(
                    onTap: () {
                      if(ResponsiveHelper.isDesktop(context)){
                        Get.dialog(const Dialog(child: CouponBottomSheet())).then((value) {
                          if(value != null) {
                            _couponController.text = value.toString();
                          }
                        });
                      }else{
                        showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                          builder: (con) => const CouponBottomSheet(),
                        ).then((value) {
                          if(value != null) {
                            _couponController.text = value.toString();
                          }
                          if(_couponController.text.isNotEmpty){
                            if(couponController.discount! < 1 && !couponController.freeDelivery) {
                              if(_couponController.text.isNotEmpty && !couponController.isLoading) {
                                couponController.applyCoupon(_couponController.text, (price-discount)+addOns, deliveryCharge,
                                    restController.restaurant!.id).then((discount) {
                                  if (discount! > 0) {
                                    _couponController.text = 'coupon_applied'.tr;
                                    showCustomSnackBar(
                                      '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                      isError: false,
                                    );
                                  }
                                });
                              } else if(_couponController.text.isEmpty) {
                                showCustomSnackBar('enter_a_coupon_code'.tr);
                              }
                            } else {
                              couponController.removeCouponData(true);
                              _couponController.text = '';
                            }
                          }
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(children: [
                        Text('add_voucher'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                      ]),
                    ),
                  )
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.2),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          controller: _couponController,
                          style: robotoRegular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                          decoration: InputDecoration(
                              hintText: 'enter_promo_code'.tr,
                              hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                              isDense: true,
                              filled: true,
                              enabled: couponController.discount == 0,
                              fillColor: Theme.of(context).cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                  right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.local_offer_outlined, color: Theme.of(context).primaryColor)
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        String couponCode = _couponController.text.trim();
                        if(couponController.discount! < 1 && !couponController.freeDelivery) {
                          if(couponCode.isNotEmpty && !couponController.isLoading) {
                            couponController.applyCoupon(couponCode, (price-discount)+addOns, deliveryCharge,
                                restController.restaurant!.id).then((discount) {
                              if (discount! > 0) {
                                showCustomSnackBar(
                                  '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                  isError: false,
                                );
                              }
                            });
                          } else if(couponCode.isEmpty) {
                            showCustomSnackBar('enter_a_coupon_code'.tr);
                          }
                        } else {
                          couponController.removeCouponData(true);
                          _couponController.text = '';
                        }
                      },
                      child: Container(
                        height: 45, width: (couponController.discount! <= 0 && !couponController.freeDelivery) ? 100 : 50,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: (couponController.discount! <= 0 && !couponController.freeDelivery) ? Theme.of(context).primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: (couponController.discount! <= 0 && !couponController.freeDelivery) ? !couponController.isLoading ? Text(
                          'apply'.tr,
                          style: robotoMedium.copyWith(color: Colors.white),
                        ) : const SizedBox(
                          height: 30, width: 30,
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                            : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

              ]),
            );
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        showTips ? Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('delivery_man_tips'.tr, style: robotoMedium),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController3,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'.tr,style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => tooltipController3.showTooltip(),
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SizedBox(
              height: (orderController.selectedTips == AppConstants.tips.length-1) && orderController.canShowTipsField ? 0 : 45,
              child: (orderController.selectedTips == AppConstants.tips.length-1) && orderController.canShowTipsField ? const SizedBox() : ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: AppConstants.tips.length,
                itemBuilder: (context, index) {
                  return TipsWidget(
                    title: (index != 0 && index != AppConstants.tips.length -1) ? PriceConverter.convertPrice(double.parse(AppConstants.tips[index].toString()), forDM: true) : AppConstants.tips[index].tr,
                    isSelected: orderController.selectedTips == index,
                    onTap: () {
                      orderController.updateTips(index);
                      if(orderController.selectedTips != 0 && orderController.selectedTips != AppConstants.tips.length-1){
                        orderController.addTips(double.parse(AppConstants.tips[index]));
                      }
                      if(orderController.selectedTips == AppConstants.tips.length-1){
                        orderController.showTipsField();
                      }
                      if(orderController.selectedTips == 0){
                        orderController.addTips(0);
                      }
                      _tipController.text = orderController.tips.toString();
                    },
                  );
                },
              ),
            ),
            SizedBox(height: (orderController.selectedTips == AppConstants.tips.length-1) && orderController.canShowTipsField ? Dimensions.paddingSizeExtraSmall : 0),

            orderController.selectedTips == AppConstants.tips.length-1 ? const SizedBox() : ListTile(
              onTap: () => orderController.toggleDmTipSave(),
              leading: Checkbox(
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                activeColor: Theme.of(context).primaryColor,
                value: orderController.isDmTipSave,
                onChanged: (bool? isChecked) => orderController.toggleDmTipSave(),
              ),
              title: Text('save_for_later'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
              contentPadding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              dense: true,
              horizontalTitleGap: 0,
            ),
            SizedBox(height: orderController.selectedTips == AppConstants.tips.length-1 ? Dimensions.paddingSizeDefault : 0),

            orderController.selectedTips == AppConstants.tips.length-1 ? Row(children: [
              Expanded(
                child: CustomTextField(
                  titleText: 'enter_amount'.tr,
                  controller: _tipController,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.number,
                  onSubmit: (value) {
                    if(value.isNotEmpty){
                      if(double.parse(value) >= 0){
                        orderController.addTips(double.parse(value));
                      }else{
                        showCustomSnackBar('tips_can_not_be_negative'.tr);
                      }
                    }else{
                      orderController.addTips(0.0);
                    }
                  },
                  onChanged: (String value) {
                    if(value.isNotEmpty){
                      if(double.parse(value) >= 0) {
                        orderController.addTips(double.parse(value));
                      }else{
                        showCustomSnackBar('tips_can_not_be_negative'.tr);
                      }
                    }else{
                      orderController.addTips(0.0);
                    }
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              InkWell(
                onTap: (){
                  orderController.updateTips(0);
                  orderController.showTipsField();
                  orderController.addTips(0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: const Icon(Icons.clear),
                ),
              ),

            ]) : const SizedBox(),
          ]),
        ) : const SizedBox.shrink(),

        SizedBox(height: (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Dimensions.paddingSizeExtraSmall : 0),



      ]),
    );
  }





  ///bottom Sction
  Widget bottomSection(OrderController orderController, double total,
      double subTotal, double discount, CouponController couponController, bool taxIncluded, double tax,
      double deliveryCharge, RestaurantController restaurantController, LocationController locationController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? maxCodOrderAmount, int subscriptionQty){
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('choose_payment_method'.tr, style: robotoMedium),

              InkWell(
                onTap: (){
                  if(ResponsiveHelper.isDesktop(context)){
                    Get.dialog(Dialog(child: PaymentMethodBottomSheet(
                      isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                      isWalletActive: _isWalletActive,
                    )));
                  }else{
                    showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (con) => PaymentMethodBottomSheet(
                        isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                        isWalletActive: _isWalletActive
                      ),
                    );
                  }
                },
                child: Image.asset(Images.paymentSelect, height: 24, width: 24),
              ),
            ]),

            const Divider(),

            (_isCashOnDeliveryActive! || _isDigitalPaymentActive! || _isWalletActive) ?  Row(children: [
              Image.asset(
                orderController.paymentMethodIndex == 0 ? Images.cashOnDelivery : orderController.paymentMethodIndex == 1
                    ? Images.digitalPayment : Images.wallet,
                width: 20, height: 20,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Text(
                  orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'.tr
                      : orderController.paymentMethodIndex == 1 ? 'digital_payment'.tr : 'wallet_payment'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
              ),
              PriceConverter.convertAnimationPrice(
                total,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ),
              // Text(
              //   PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
              //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              // ),
            ]) : Text('no_payment_method_available'.tr, style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error)),
          ]),
        ),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('additional_note'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CustomTextField(
              controller: _noteController,
              titleText: 'ex_please_provide_extra_napkin'.tr,
              maxLines: 3,
              inputType: TextInputType.multiline,
              inputAction: TextInputAction.done,
              capitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),


            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('item_price'.tr, style: robotoMedium),
              Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('discount'.tr, style: robotoRegular),
              Row(children: [
                Text('(-) ', style: robotoRegular),
                PriceConverter.convertAnimationPrice(discount, textStyle: robotoRegular)
              ]),
              // Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            (couponController.discount! > 0 || couponController.freeDelivery) ? Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('coupon_discount'.tr, style: robotoRegular),
                (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Text(
                  'free_delivery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                ) : Row(children: [
                  Text('(-) ', style: robotoRegular),
                  Text(
                    PriceConverter.convertPrice(couponController.discount),
                    style: robotoRegular, textDirection: TextDirection.ltr,
                  )
                ]),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]) : const SizedBox(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text('${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''}', style: robotoRegular),
                Text('($_taxPercent%)', style: robotoRegular, textDirection: TextDirection.ltr),
              ]),
              Row(children: [
                Text('(+) ', style: robotoRegular),
                Text(PriceConverter.convertPrice(tax), style: robotoRegular, textDirection: TextDirection.ltr),
              ]),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !orderController.subscriptionOrder) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('delivery_man_tips'.tr, style: robotoRegular),
                Row(children: [
                  Text('(+) ', style: robotoRegular),
                  PriceConverter.convertAnimationPrice(orderController.tips, textStyle: robotoRegular)
                ]),
                // Text('(+) ${PriceConverter.convertPrice(orderController.tips)}', style: robotoRegular, textDirection: TextDirection.ltr),
              ],
            ) : const SizedBox.shrink(),
            SizedBox(height: orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !orderController.subscriptionOrder ? Dimensions.paddingSizeSmall : 0.0),

            orderController.orderType != 'take_away' ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('delivery_fee'.tr, style: robotoRegular),
              orderController.distance == -1 ? Text(
                'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
              ) : (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? Text(
                'free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
              ) : Row(children: [
                Text('(+) ', style: robotoRegular),
                Text(
                  PriceConverter.convertPrice(deliveryCharge), style: robotoRegular, textDirection: TextDirection.ltr,
                )
              ]),
            ]) : const SizedBox(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
            ),

            ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'total_amount'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ),
              PriceConverter.convertAnimationPrice(
                total,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ),

              // Text(
              //   PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
              //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              // ),
            ]) : const SizedBox(),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            CheckoutCondition(orderController: orderController),
          ]),
        ),

        ResponsiveHelper.isDesktop(context) ? Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: _orderPlaceButton(
            orderController, restaurantController, locationController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount, subscriptionQty
          ),
        ) : const SizedBox(),
      ]),
    );
  }


  void _callback(bool isSuccess, String message, String orderID, double amount) async {
    if(isSuccess) {
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      if(widget.fromCart) {
        Get.find<CartController>().clearCartList();
      }
      Get.find<OrderController>().stopLoader();
      if(Get.find<OrderController>().paymentMethodIndex == 0 || Get.find<OrderController>().paymentMethodIndex == 2) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
        double total = ((amount / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
        Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
      }else {
       if(GetPlatform.isWeb) {
         Get.back();
         String? hostname = html.window.location.hostname;
         String protocol = html.window.location.protocol;
         String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&customer_id=${Get.find<UserController>()
             .userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&amount=$amount&status=';
         html.window.open(selectedUrl,"_self");
       } else{
         Get.offNamed(RouteHelper.getPaymentRoute(
           OrderModel(id: int.parse(orderID), userId: Get.find<UserController>().userInfoModel!.id, orderAmount: amount, restaurant: Get.find<RestaurantController>().restaurant)),
         );
       }
      }
      Get.find<OrderController>().clearPrevData();
      Get.find<OrderController>().updateTips(-1);
      Get.find<CouponController>().removeCouponData(false);
    }else {
      showCustomSnackBar(message);
    }
  }

  ///place Order Button
  Widget _orderPlaceButton(OrderController orderController, RestaurantController restController, LocationController locationController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount, int subscriptionQty) {
      return Container(
        width: Dimensions.webMaxWidth,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: SafeArea(
          child: CustomButton(
              buttonText: 'confirm_order'.tr, radius: Dimensions.radiusDefault,
              isLoading: orderController.isLoading, onPressed: () {
            bool isAvailable = true;
            DateTime scheduleStartDate = DateTime.now();
            DateTime scheduleEndDate = DateTime.now();
            if(orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
              isAvailable = false;
            }else {
              DateTime date = orderController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
              DateTime startTime = orderController.timeSlots![orderController.selectedTimeSlot!].startTime!;
              DateTime endTime = orderController.timeSlots![orderController.selectedTimeSlot!].endTime!;
              scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
              scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
              for (CartModel cart in _cartList) {
                if (!DateConverter.isAvailable(
                  cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
                  time: restController.restaurant!.scheduleOrder! ? scheduleStartDate : null,
                ) && !DateConverter.isAvailable(
                  cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
                  time: restController.restaurant!.scheduleOrder! ? scheduleEndDate : null,
                )) {
                  isAvailable = false;
                  break;
                }
              }
            }

            bool datePicked = false;
            for(DateTime? time in orderController.selectedDays) {
              if(time != null) {
                datePicked = true;
                break;
              }
            }

            if(Get.find<OrderController>().isDmTipSave && orderController.selectedTips != AppConstants.tips.length - 1) {
              Get.find<AuthController>().saveDmTipIndex(Get.find<OrderController>().selectedTips.toString());
            }

            if(!_isCashOnDeliveryActive! && !_isDigitalPaymentActive! && !_isWalletActive) {
              showCustomSnackBar('no_payment_method_is_enabled'.tr);
            }else if(orderAmount < restController.restaurant!.minimumOrder!) {
              showCustomSnackBar('${'minimum_order_amount_is'.tr} ${restController.restaurant!.minimumOrder}');
            }else if(orderController.subscriptionOrder && orderController.subscriptionRange == null) {
              showCustomSnackBar('select_a_date_range_for_subscription'.tr);
            }else if(orderController.subscriptionOrder && !datePicked && orderController.subscriptionType == 'daily') {
              showCustomSnackBar('choose_time'.tr);
            }else if(orderController.subscriptionOrder && !datePicked) {
              showCustomSnackBar('select_at_least_one_day_for_subscription'.tr);
            }else if((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed)) {
              showCustomSnackBar('restaurant_is_closed'.tr);
            }else if(orderController.paymentMethodIndex == 0 && Get.find<SplashController>().configModel!.cashOnDelivery! && maxCodOrderAmount != null && (total > maxCodOrderAmount)){
              showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
            } else if (orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
              if(restController.restaurant!.scheduleOrder! && !orderController.subscriptionOrder) {
                showCustomSnackBar('select_a_time'.tr);
              }else {
                showCustomSnackBar('restaurant_is_closed'.tr);
              }
            }else if (!isAvailable && !orderController.subscriptionOrder) {
              showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
            }else if (orderController.orderType != 'take_away' && orderController.distance == -1 && deliveryCharge == -1) {
              showCustomSnackBar('delivery_fee_not_set_yet'.tr);
            } else if(orderController.paymentMethodIndex == 2 && Get.find<UserController>().userInfoModel
                != null && Get.find<UserController>().userInfoModel!.walletBalance! < total) {
              showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
            }else {
              List<Cart> carts = [];
              for (int index = 0; index < _cartList.length; index++) {
                CartModel cart = _cartList[index];
                List<int?> addOnIdList = [];
                List<int?> addOnQtyList = [];
                List<OrderVariation> variations = [];
                for (var addOn in cart.addOnIds!) {
                  addOnIdList.add(addOn.id);
                  addOnQtyList.add(addOn.quantity);
                }
                if(cart.product!.variations != null){
                  for(int i=0; i<cart.product!.variations!.length; i++) {
                    if(cart.variations![i].contains(true)) {
                      variations.add(OrderVariation(name: cart.product!.variations![i].name, values: OrderVariationValue(label: [])));
                      for(int j=0; j<cart.product!.variations![i].variationValues!.length; j++) {
                        if(cart.variations![i][j]!) {
                          variations[variations.length-1].values!.label!.add(cart.product!.variations![i].variationValues![j].level);
                        }
                      }
                    }
                  }
                }
                carts.add(Cart(
                  cart.isCampaign! ? null : cart.product!.id, cart.isCampaign! ? cart.product!.id : null,
                  cart.discountedPrice.toString(), '', variations,
                  cart.quantity, addOnIdList, cart.addOns, addOnQtyList,
                ));
              }

              List<SubscriptionDays> days = [];
              for(int index=0; index<orderController.selectedDays.length; index++) {
                if(orderController.selectedDays[index] != null) {
                  days.add(SubscriptionDays(
                    day: orderController.subscriptionType == 'weekly' ? (index == 6 ? 0 : (index + 1)).toString()
                        : orderController.subscriptionType == 'monthly' ? (index + 1).toString() : index.toString(),
                    time: DateConverter.dateToTime(orderController.selectedDays[index]!),
                  ));
                }
              }
              AddressModel finalAddress =  address[orderController.addressIndex];
              orderController.placeOrder(PlaceOrderBody(
                cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
                couponDiscountTitle: Get.find<CouponController>().discount! > 0 ? Get.find<CouponController>().coupon!.title : null,
                scheduleAt: !restController.restaurant!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
                    && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleStartDate),
                orderAmount: total, orderNote: _noteController.text, orderType: orderController.orderType,
                paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                    : orderController.paymentMethodIndex == 1 ? 'digital_payment' : orderController.paymentMethodIndex == 2
                    ? 'wallet' : 'digital_payment',
                couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                    && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                restaurantId: _cartList[0].product!.restaurantId,
                address: finalAddress.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude, addressType: finalAddress.addressType,
                contactPersonName: finalAddress.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
                    '${Get.find<UserController>().userInfoModel!.lName}',
                contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
                discountAmount: discount, taxAmount: tax, road: _streetNumberController.text.trim(),
                cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                house: _houseController.text.trim(), floor: _floorController.text.trim(),
                dmTips: (orderController.orderType == 'take_away' || orderController.subscriptionOrder || orderController.selectedTips == 0) ? '' : orderController.tips.toString(),
                subscriptionOrder: orderController.subscriptionOrder ? '1' : '0',
                subscriptionType: orderController.subscriptionType, subscriptionQuantity: subscriptionQty.toString(),
                subscriptionDays: days,
                subscriptionStartAt: orderController.subscriptionOrder ? DateConverter.dateToDateAndTime(orderController.subscriptionRange!.start) : '',
                subscriptionEndAt: orderController.subscriptionOrder ? DateConverter.dateToDateAndTime(orderController.subscriptionRange!.end) : '',
                unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
                deliveryInstruction: orderController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[orderController.selectedInstruction] : '',
              ), _callback, total);
            }
          }),
        ),
    );
  }
}

















