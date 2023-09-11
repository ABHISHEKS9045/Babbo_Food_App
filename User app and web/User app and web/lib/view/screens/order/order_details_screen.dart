import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/notification_body.dart';
import 'package:efood_multivendor/data/model/response/conversation_model.dart';
import 'package:efood_multivendor/data/model/response/order_details_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/review_model.dart';
import 'package:efood_multivendor/data/model/response/subscription_schedule_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:efood_multivendor/view/screens/chat/widget/image_dialog.dart';
import 'package:efood_multivendor/view/screens/order/widget/cancellation_dialogue.dart';
import 'package:efood_multivendor/view/screens/order/widget/delivery_details.dart';
import 'package:efood_multivendor/view/screens/order/widget/log_dialog.dart';
import 'package:efood_multivendor/view/screens/order/widget/order_product_widget.dart';
import 'package:efood_multivendor/view/screens/order/widget/subscription_pause_dialog.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/review_dialog.dart';
import 'package:efood_multivendor/view/screens/review/rate_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  const OrderDetailsScreen({Key? key, required this.orderModel, required this.orderId}) : super(key: key);

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {

  void _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), widget.orderModel, false);
    if(widget.orderModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    Get.find<OrderController>().getOrderCancelReasons();
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
    if(Get.find<OrderController>().trackModel != null){
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderId.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderId.toString());
    }else if(state == AppLifecycleState.paused){
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    Get.find<OrderController>().cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.orderModel == null) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return true;
        } else {
          Get.back();
          return true;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
          double? deliveryCharge = 0;
          double itemsPrice = 0;
          double? discount = 0;
          double? couponDiscount = 0;
          double? tax = 0;
          double addOns = 0;
          double? dmTips = 0;
          bool showChatPermission = true;
          bool? taxIncluded = false;
          OrderModel? order = orderController.trackModel;
          bool subscription = false;
          bool pending = false, accepted = false, confirmed = false, processing = false, pickedUp = false, delivered = false, cancelled = false, delivery = false, takeAway = false, cod = false, digitalPay = false;
          bool ongoing = false;
          bool pastOrder = false;
          List<String> schedules = [];
          if(orderController.orderDetails != null && order != null) {
            subscription = order.subscription != null;

            pending = order.orderStatus == AppConstants.pending;
            accepted = order.orderStatus == AppConstants.accepted;
            confirmed = order.orderStatus == AppConstants.confirmed;
            processing = order.orderStatus == AppConstants.processing;
            pickedUp = order.orderStatus == AppConstants.pickedUp;
            delivered = order.orderStatus == AppConstants.delivered;
            cancelled = order.orderStatus == AppConstants.cancelled;
            delivery = order.orderType == 'delivery';
            takeAway = order.orderType == 'take_away';
            cod = order.paymentMethod == 'cash_on_delivery';
            digitalPay = order.paymentMethod == 'digital_payment';

            if(subscription) {
              if(order.subscription!.type == 'weekly') {
                List<String> weekDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
                for(SubscriptionScheduleModel schedule in orderController.schedules!) {
                  schedules.add('${weekDays[schedule.day!].tr} (${DateConverter.convertTimeToTime(schedule.time!)})');
                }
              }else if(order.subscription!.type == 'monthly') {
                for(SubscriptionScheduleModel schedule in orderController.schedules!) {
                  schedules.add('${'day_capital'.tr} ${schedule.day} (${DateConverter.convertTimeToTime(schedule.time!)})');
                }
              }else {
                schedules.add(DateConverter.convertTimeToTime(orderController.schedules![0].time!));
              }
            }
            if(delivery) {
              deliveryCharge = order.deliveryCharge;
              dmTips = order.dmTips;
            }
            couponDiscount = order.couponDiscountAmount;
            discount = order.restaurantDiscountAmount;
            tax = order.totalTaxAmount;
            taxIncluded = order.taxStatus;
            for(OrderDetailsModel orderDetails in orderController.orderDetails!) {
              for(AddOn addOn in orderDetails.addOns!) {
                addOns = addOns + (addOn.price! * addOn.quantity!);
              }
              itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
            }
            if(order.restaurant != null) {
              if (order.restaurant!.restaurantModel == 'commission') {
                showChatPermission = true;
              } else if (order.restaurant!.restaurantSubscription != null &&
                  order.restaurant!.restaurantSubscription!.chat == 1) {
                showChatPermission = true;
              } else {
                showChatPermission = false;
              }
            }

            ongoing = (order.orderStatus != 'delivered' && order.orderStatus != 'failed'
                && order.orderStatus != 'refund_requested' && order.orderStatus != 'refunded'
                && order.orderStatus != 'refund_request_canceled');

            pastOrder = (order.orderStatus == 'delivered' || order.orderStatus == 'failed'
                || order.orderStatus == 'refund_requested' || order.orderStatus == 'refunded'
                || order.orderStatus == 'refund_request_canceled' ||order.orderStatus == 'canceled' );

          }
          double subTotal = itemsPrice + addOns;
          double total = itemsPrice + addOns - discount! + (taxIncluded! ? 0 : tax!) + deliveryCharge! - couponDiscount! + dmTips!;

        return Scaffold(
            appBar: CustomAppBar(title: subscription ? 'subscription_details'.tr : 'order_details'.tr, onBackPressed: () {
              if(widget.orderModel == null) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              }else {
                Get.back();
              }
            }),
            body: SafeArea(
              child: (order != null && orderController.orderDetails != null) ? Column(children: [

              Expanded(child: Scrollbar(child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                // padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  DateConverter.isBeforeTime(order.scheduleAt) ? (!cancelled && ongoing && !subscription) ? Column(children: [

                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(order.orderStatus == 'pending' ? Images.pendingOrderDetails : (order.orderStatus == 'confirmed' || order.orderStatus == 'processing' || order.orderStatus == 'handover')
                        ? Images.preparingFoodOrderDetails : Images.animateDeliveryMan, fit: BoxFit.contain, height: 180)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text('your_food_will_delivered_within'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [

                        Text(
                          DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt) < 5 ? '1 - 5'
                              : '${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)-5} '
                              '- ${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)}',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text('min'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  ]) : const SizedBox() : const SizedBox(),

                  (pastOrder) ? CustomImage(image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantCoverPhotoUrl}/${order.restaurant!.coverPhoto}', height: 160, width: double.infinity)
                      : const SizedBox(),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('general_info'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Row(children: [
                        Text('${subscription ? 'subscription_id'.tr : 'order_id'.tr}:', style: robotoRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(order.id.toString(), style: robotoMedium),
                        const Expanded(child: SizedBox()),

                        const Icon(Icons.watch_later, size: 17),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          DateConverter.dateTimeStringToDateTime(order.createdAt!),
                          style: robotoRegular,
                        ),
                      ]),
                      const Divider(height: Dimensions.paddingSizeLarge),

                      order.scheduled == 1 ? Row(children: [
                        Text('${'scheduled_at'.tr}:', style: robotoRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(DateConverter.dateTimeStringToDateTime(order.scheduleAt!), style: robotoMedium),
                      ]) : const SizedBox(),
                      order.scheduled == 1 ? const Divider(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                      Get.find<SplashController>().configModel!.orderDeliveryVerification! ? Row(children: [
                        Text('${'delivery_verification_code'.tr}:', style: robotoRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(order.otp!, style: robotoMedium),
                      ]) : const SizedBox(),
                      Get.find<SplashController>().configModel!.orderDeliveryVerification! ?const Divider(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                      Row(children: [
                        Text(order.orderType!.tr, style: robotoMedium),
                        const Expanded(child: SizedBox()),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            cod ? 'cash_on_delivery'.tr : order.paymentMethod == 'wallet'
                                ? 'wallet_payment'.tr : 'digital_payment'.tr,
                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                          ),
                        ),
                      ]),
                      const Divider(height: Dimensions.paddingSizeLarge),

                      subscription ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Row(children: [
                          Text('${'subscription_date'.tr}:', style: robotoRegular),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            '${DateConverter.stringDateTimeToDate(order.subscription!.startAt!)} '
                                '- ${DateConverter.stringDateTimeToDate(order.subscription!.endAt!)}',
                            style: robotoMedium,
                          ),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Row(children: [
                          Text('${'subscription_type'.tr}:', style: robotoRegular),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            order.subscription!.type!.tr,
                            style: robotoMedium,
                          ),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text('${'subscription_schedule'.tr}:', style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        SizedBox(height: 30, child: ListView.builder(
                          itemCount: schedules.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(
                                  schedules[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular,
                                ),
                              ]),
                            );
                          },
                        )),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(children: [
                          Expanded(child: CustomButton(
                            buttonText: 'delivery_log'.tr,
                            height: 35,
                            onPressed: () => Get.dialog(LogDialog(subscriptionID: order.subscriptionId, isDelivery: true)),
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: CustomButton(
                            buttonText: 'pause_log'.tr,
                            height: 35,
                            onPressed: () => Get.dialog(LogDialog(subscriptionID: order.subscriptionId, isDelivery: false)),
                          )),
                        ]),

                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        const Divider(height: Dimensions.paddingSizeLarge),
                      ]) : const SizedBox(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        child: Row(children: [
                          Text('${'item'.tr}:', style: robotoRegular),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            orderController.orderDetails!.length.toString(),
                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                          ),
                          const Expanded(child: SizedBox()),
                          Container(height: 7, width: 7, decoration: BoxDecoration(
                            color: (subscription ? order.subscription!.status == 'canceled' : (order.orderStatus == 'failed' || cancelled || order.orderStatus == 'refund_request_canceled'))
                                ? Colors.red : order.orderStatus == 'refund_requested' ? Colors.yellow : Colors.green ,
                            shape: BoxShape.circle,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            delivered ? '${'delivered_at'.tr} ${DateConverter.dateTimeStringToDateTime(order.delivered!)}'
                                : subscription ? order.subscription!.status!.tr : order.orderStatus!.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ]),
                      ),
                      // const Divider(height: Dimensions.paddingSizeLarge),

                      Column(children: [
                        const Divider(height: Dimensions.paddingSizeLarge),

                        Row(children: [
                          Text('${'cutlery'.tr}: ', style: robotoRegular),
                          const Expanded(child: SizedBox()),

                          Text(
                            order.cutlery! ? 'yes'.tr : 'no'.tr,
                            style: robotoRegular,
                          ),
                        ]),
                      ]),

                      order.unavailableItemNote != null ? Column(
                        children: [
                          const Divider(height: Dimensions.paddingSizeLarge),
                          Row(children: [
                            Text('${'if_item_is_not_available'.tr}: ', style: robotoMedium),

                            Text(
                              order.unavailableItemNote!.tr,
                              style: robotoRegular,
                            ),
                          ]),
                        ],
                      ) : const SizedBox(),

                      order.deliveryInstruction != null ? Column(children: [
                        const Divider(height: Dimensions.paddingSizeLarge),

                        Row(children: [
                          Text('${'delivery_instruction'.tr}: ', style: robotoMedium),

                          Text(
                            order.deliveryInstruction!.tr,
                            style: robotoRegular,
                          ),
                        ]),
                      ]) : const SizedBox(),
                      SizedBox(height: order.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

                      cancelled ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Divider(height: Dimensions.paddingSizeLarge),
                        Text('${'cancellation_reason'.tr}:', style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        InkWell(
                          onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.cancellationReason), fromOrderDetails: true)),
                          child: Text(
                            order.cancellationReason ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                          ),
                        ),

                      ]) : const SizedBox(),

                      cancelled && order.cancellationNote != null && order.cancellationNote != '' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Divider(height: Dimensions.paddingSizeLarge),

                        Text('${'cancellation_note'.tr}:', style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        InkWell(
                          onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.cancellationNote), fromOrderDetails: true)),
                          child: Text(
                            order.cancellationNote ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                          ),
                        ),

                      ]) : const SizedBox(),

                      (order.orderStatus == 'refund_requested' || order.orderStatus == 'refund_request_canceled') ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        const Divider(height: Dimensions.paddingSizeLarge),
                        order.orderStatus == 'refund_requested' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          RichText(text: TextSpan(children: [
                            TextSpan(text: '${'refund_note'.tr}:', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                            TextSpan(text: '(${(order.refund != null) ? order.refund!.customerReason : ''})', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                          ])),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          (order.refund != null && order.refund!.customerNote != null) ? InkWell(
                            onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.refund!.customerNote), fromOrderDetails: true)),
                            child: Text(
                              '${order.refund!.customerNote}', maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                            ),
                          ) : const SizedBox(),
                          SizedBox(height: (order.refund != null && order.refund!.image != null) ? Dimensions.paddingSizeSmall : 0),

                          (order.refund != null && order.refund!.image != null && order.refund!.image!.isNotEmpty) ? InkWell(
                            onTap: () => showDialog(context: context, builder: (context) {
                              return ImageDialog(imageUrl: '${Get.find<SplashController>().configModel!.baseUrls!.refundImageUrl}/${order.refund!.image!.isNotEmpty ? order.refund!.image![0] : ''}');
                            }),
                            child: CustomImage(
                              height: 40, width: 40, fit: BoxFit.cover,
                              image: order.refund != null ? '${Get.find<SplashController>().configModel!.baseUrls!.refundImageUrl}/${order.refund!.image!.isNotEmpty ? order.refund!.image![0] : ''}' : '',
                            ),
                          ) : const SizedBox(),
                        ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Divider(height: Dimensions.paddingSizeLarge),

                          Text('${'refund_cancellation_note'.tr}:', style: robotoMedium),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          InkWell(
                            onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.refund!.adminNote), fromOrderDetails: true)),
                            child: Text(
                              '${order.refund != null ? order.refund!.adminNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                            ),
                          ),

                        ]),
                      ]) : const SizedBox(),

                      (order.orderNote  != null && order.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Divider(height: Dimensions.paddingSizeLarge),

                        Text('additional_note'.tr, style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          width: Dimensions.webMaxWidth,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                          ),
                          child: Text(
                            order.orderNote!,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ]) : const SizedBox(),
                    ]),
                  ),


                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Text('item_info'.tr, style: robotoMedium),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderController.orderDetails!.length,
                      itemBuilder: (context, index) {
                        return OrderProductWidget(order: order, orderDetails: orderController.orderDetails![index]);
                      },
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('delivery_details'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      DeliveryDetails(from: true, address: order.restaurant?.address ?? ''),
                      const Divider(height: Dimensions.paddingSizeLarge),

                      DeliveryDetails(from: false, address: order.deliveryAddress?.address ?? ''),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('restaurant_details'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      order.restaurant != null ? Row(children: [
                        ClipOval(child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantImageUrl}/${order.restaurant!.logo}',
                          height: 35, width: 35, fit: BoxFit.cover,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            order.restaurant!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                          Text(
                            order.restaurant!.address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                        ])),

                        (takeAway && (pending || accepted || confirmed || processing || order.orderStatus == 'handover'
                        || pickedUp)) ? TextButton.icon(
                          onPressed: () async {
                            String url ='https://www.google.com/maps/dir/?api=1&destination=${order.restaurant!.latitude}'
                                ',${order.restaurant!.longitude}&mode=d';
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url, mode: LaunchMode.externalApplication);
                            }else {
                              showCustomSnackBar('unable_to_launch_google_map'.tr);
                            }
                          },
                          icon: const Icon(Icons.directions), label: Text('direction'.tr),
                        ) : const SizedBox(),

                        (showChatPermission && !delivered && order.orderStatus != 'failed' && !cancelled && order.orderStatus != 'refunded') ? InkWell(
                          onTap: () async {
                            orderController.cancelTimer();
                            await Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBody(orderId: order.id, restaurantId: order.restaurant!.vendorId),
                              user: User(id: order.restaurant!.vendorId, fName: order.restaurant!.name, lName: '', image: order.restaurant!.logo),
                            ));
                            orderController.callTrackOrderApi(orderModel: order, orderId: order.id.toString());
                          },
                          child: Image.asset(Images.chatImageOrderDetails, height: 25, width: 25, fit: BoxFit.cover),
                        ) : const SizedBox(),

                        (!subscription && Get.find<SplashController>().configModel!.refundStatus! && delivered && orderController.orderDetails![0].itemCampaignId == null)
                        ? InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(order.id.toString())),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeSmall),
                            child: Text('request_for_refund'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                          ),
                        ) : const SizedBox(),

                      ]) : Center(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Text(
                          'no_restaurant_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                      )),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  order.deliveryMan != null ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('delivery_man_details'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                       Row(children: [
                        ClipOval(child: CustomImage(
                          image: '${ Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${order.deliveryMan!.image}',
                          height: 35, width: 35, fit: BoxFit.cover,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)
                          ),
                          RatingBar(
                            rating: order.deliveryMan!.avgRating, size: 10,
                            ratingCount: order.deliveryMan!.ratingCount,
                          ),
                        ])),

                        InkWell(
                          onTap: () async {
                            orderController.cancelTimer();
                            await Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBody(deliverymanId: order.deliveryMan!.id, orderId: int.parse(order.id.toString())),
                              user: User(id: order.deliveryMan!.id, fName: order.deliveryMan!.fName, lName: order.deliveryMan!.lName, image: order.deliveryMan!.image),
                            ));
                            orderController.callTrackOrderApi(orderModel: order, orderId: order.id.toString());
                          },
                          child: Image.asset(Images.chatImageOrderDetails, height: 25, width: 25, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        InkWell(
                          onTap: () async {
                            if(await canLaunchUrlString('tel:${order.deliveryMan!.phone}')) {
                              launchUrlString('tel:${order.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                            }else {
                              showCustomSnackBar('${'can_not_launch'.tr} ${order.deliveryMan!.phone}');
                            }

                          },
                          child: Image.asset(Images.callImageOrderDetails, height: 25, width: 25, fit: BoxFit.cover),
                        ),

                      ]),
                    ]),
                  ) : const SizedBox(),
                  SizedBox(height: order.deliveryMan != null ? Dimensions.paddingSizeLarge : 0),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('payment_method'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(children: [

                        Image.asset(
                          order.paymentMethod == 'cash_on_delivery' ? Images.cashOnDelivery : order.paymentMethod == 'wallet' ? Images.wallet : Images.digitalPayment,
                          width: 20, height: 20,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: Text(
                            order.paymentMethod == 'cash_on_delivery' ? 'cash'.tr
                                : order.paymentMethod == 'wallet' ? 'wallet'.tr : 'digital'.tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                        ),

                      ]),
                    ]),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(children: [

                      // Total
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('item_price'.tr, style: robotoRegular),
                        Text(PriceConverter.convertPrice(itemsPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('addons'.tr, style: robotoRegular),
                        Text('(+) ${PriceConverter.convertPrice(addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                      ]),

                      Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),

                      !subscription ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${'subtotal'.tr} ${taxIncluded ? 'tax_included'.tr : ''}', style: robotoMedium),
                        Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
                      ]) : const SizedBox(),
                      SizedBox(height: !subscription ? Dimensions.paddingSizeSmall : 0),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('discount'.tr, style: robotoRegular),
                        Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('coupon_discount'.tr, style: robotoRegular),
                        Text(
                          '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                          style: robotoRegular, textDirection: TextDirection.ltr,
                        ),
                      ]) : const SizedBox(),
                      SizedBox(height: couponDiscount > 0 ? Dimensions.paddingSizeSmall : 0),

                      !taxIncluded ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('vat_tax'.tr, style: robotoRegular),
                        Text('(+) ${PriceConverter.convertPrice(tax)}', style: robotoRegular, textDirection: TextDirection.ltr),
                      ]) : const SizedBox(),
                      SizedBox(height: taxIncluded ? 0 : Dimensions.paddingSizeSmall),

                      (!subscription && order.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('delivery_man_tips'.tr, style: robotoRegular),
                          Text('(+) ${PriceConverter.convertPrice(dmTips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                        ],
                      ) : const SizedBox(),
                      SizedBox(height: (order.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? 10 : 0),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('delivery_fee'.tr, style: robotoRegular),
                        deliveryCharge > 0 ? Text(
                          '(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr,
                        ) : Text('free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                      ]),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                      ),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(subscription ? 'subtotal'.tr : 'total_amount'.tr, style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                        )),
                        Text(
                          PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                        ),
                      ]),

                      subscription ? Column(children: [
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('subscription_order_count'.tr, style: robotoMedium),
                          Text(order.subscription!.quantity.toString(), style: robotoMedium),
                        ]),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(
                            'total_amount'.tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                          ),
                          Text(
                            PriceConverter.convertPrice(total * order.subscription!.quantity!), textDirection: TextDirection.ltr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                          ),
                        ]),
                      ]) : const SizedBox(),
                    ]),
                  ),




                ]))),
              ))),

                !orderController.showCancelled ? Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth + 20,
                    child: Row(children: [
                      ((!subscription || (order.subscription!.status != 'canceled' && order.subscription!.status != 'completed')) && ((pending && !digitalPay) || accepted || confirmed
                      || processing || order.orderStatus == 'handover'|| pickedUp)) ? Expanded(
                        child: CustomButton(
                          buttonText: subscription ? 'track_subscription'.tr : 'track_order'.tr,
                          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          onPressed: () async {
                            orderController.cancelTimer();
                            await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id));
                            orderController.callTrackOrderApi(orderModel: order, orderId: widget.orderId.toString());
                          },
                        ),
                      ) : const SizedBox(),

                      (pending && order.paymentStatus == 'unpaid' && digitalPay && Get.find<SplashController>().configModel!.cashOnDelivery!) ?
                      Expanded(
                        child: CustomButton(
                          buttonText: 'switch_to_cash_on_delivery'.tr,
                          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          onPressed: () {
                            Get.dialog(ConfirmationDialog(
                                icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                                onYesPressed: () {
                                  double maxCodOrderAmount = Get.find<LocationController>().getUserAddress()!.zoneData!.firstWhere((data) => data.id == order.restaurant!.zoneId).maxCodOrderAmount
                                      ?? 0;

                                  if(maxCodOrderAmount > total){
                                    orderController.switchToCOD(order.id.toString()).then((isSuccess) {
                                      Get.back();
                                      if(isSuccess) {
                                        Get.back();
                                      }
                                    });
                                  }else{
                                    if(Get.isDialogOpen!) {
                                      Get.back();
                                    }
                                    showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                                  }
                                }
                            ));
                          },
                        ),
                      ): const SizedBox(),

                      (subscription ? (order.subscription!.status == 'active' || order.subscription!.status == 'paused')
                      : (pending)) ? Expanded(child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: TextButton(
                          style: TextButton.styleFrom(minimumSize: const Size(1, 50), shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            side: BorderSide(width: 2, color: Theme.of(context).disabledColor),
                          )),
                          onPressed: () {
                            if(subscription) {
                              Get.dialog(SubscriptionPauseDialog(subscriptionID: order.subscriptionId, isPause: false));
                            }else {
                              orderController.setOrderCancelReason('');
                              Get.dialog(CancellationDialogue(orderId: order.id));
                            }
                          },
                          child: Text(subscription ? 'cancel_subscription'.tr : 'cancel_order'.tr, style: robotoBold.copyWith(
                            color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault,
                          )),
                        ),
                      )) : const SizedBox(),

                    ]),
                  ),
                ) : Center(
                  child: Container(
                    width: Dimensions.webMaxWidth,
                    height: 50,
                    margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Text('order_cancelled'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  ),
                ),

                !orderController.showCancelled && subscription && (order.subscription!.status == 'active' || order.subscription!.status == 'paused') ? CustomButton(
                  buttonText: 'pause_subscription'.tr,
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  onPressed: () async {
                    Get.dialog(SubscriptionPauseDialog(subscriptionID: order.subscriptionId, isPause: true));
                  },
                ) : const SizedBox(),

              Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    child: !orderController.isLoading ? Row(
                      children: [
                        (!subscription && delivered && orderController.orderDetails![0].itemCampaignId == null) ? Expanded(
                          child: CustomButton(
                            buttonText: 'review'.tr,
                            onPressed: () async {
                              List<OrderDetailsModel> orderDetailsList = [];
                              List<int?> orderDetailsIdList = [];
                              for (var orderDetail in orderController.orderDetails!) {
                                if(!orderDetailsIdList.contains(orderDetail.foodDetails!.id)) {
                                  orderDetailsList.add(orderDetail);
                                  orderDetailsIdList.add(orderDetail.foodDetails!.id);
                                }
                              }
                              orderController.cancelTimer();
                              await Get.toNamed(RouteHelper.getReviewRoute(), arguments: RateReviewScreen(
                                orderDetailsList: orderDetailsList, deliveryMan: order.deliveryMan,
                              ));
                              orderController.callTrackOrderApi(orderModel: order, orderId: widget.orderId.toString());
                            },
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: cancelled || order.orderStatus == 'failed' ? 0 : Dimensions.paddingSizeSmall),

                        !subscription && Get.find<SplashController>().configModel!.repeatOrderOption! && (delivered || cancelled || order.orderStatus == 'failed' || order.orderStatus == 'refund_request_canceled')
                        ? Expanded(
                          child: CustomButton(
                            buttonText: 'reorder'.tr,
                            onPressed: () => orderController.reOrder(orderController.orderDetails!, order.restaurant!.zoneId),
                          ),
                        ) : const SizedBox(),
                      ],
                    ) : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),


              Builder(
                builder: (context) {
                  return ((order.orderStatus == 'failed' || cancelled) && !cod && Get.find<SplashController>().configModel!.cashOnDelivery!) ? Center(
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: CustomButton(
                        buttonText: 'switch_to_cash_on_delivery'.tr,
                        onPressed: () {
                          Get.dialog(ConfirmationDialog(
                            icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                            onYesPressed: () {
                              double? maxCodOrderAmount = Get.find<LocationController>().getUserAddress()!.zoneData!.firstWhere((data) => data.id == order.restaurant!.zoneId).maxCodOrderAmount;

                              if(maxCodOrderAmount == null || maxCodOrderAmount > total){
                                orderController.switchToCOD(order.id.toString()).then((isSuccess) {
                                  Get.back();
                                  if(isSuccess) {
                                    Get.back();
                                  }
                                });
                              }else{
                                if(Get.isDialogOpen!) {
                                  Get.back();
                                }
                                showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                              }
                            }
                          ));
                        },
                      ),
                    ),
                  ) : const SizedBox();
                }
              ),



          ]) : const Center(child: CircularProgressIndicator()),
            )

        );
      }),
    );
  }
}