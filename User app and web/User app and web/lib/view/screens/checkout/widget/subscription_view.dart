import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionView extends StatelessWidget {
  final OrderController orderController;
  const SubscriptionView({Key? key, required this.orderController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> weekDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text('subscription_date'.tr, style: robotoMedium),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      CustomDatePicker(
        hint: 'choose_subscription_date'.tr,
        range: orderController.subscriptionRange,
        onDatePicked: (DateTimeRange range) => orderController.setSubscriptionRange(range),
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('subscription_type'.tr, style: robotoMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [ BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 0.5, blurRadius: 0.5)],
          ),
          child: DropdownButton<String>(
            value: orderController.subscriptionType,
            underline: const SizedBox(),
            items: <String>['daily', 'weekly', 'monthly'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.tr),
              );
            }).toList(),
            onChanged: (value) => orderController.setSubscriptionType(value),
          ),
        ),
      ]),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      orderController.subscriptionType != 'daily' ? Text('days'.tr, style: robotoMedium) : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('subscription_schedule'.tr, style: robotoMedium),
        InkWell(
          onTap: () async {
            TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if(time != null) {
              orderController.addDay(0, time);
            }
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [ BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 0.5, blurRadius: 0.5)],
            ),
            child: Text(
              orderController.selectedDays[0] != null ? DateConverter.dateToTimeOnly(orderController.selectedDays[0]!) : 'choose_time'.tr,
              style: robotoRegular,
            ),
          ),
        ),
      ]),
      SizedBox(height: orderController.subscriptionType != 'daily' ? Dimensions.paddingSizeExtraSmall : 0),
      orderController.subscriptionType != 'daily' ? SizedBox(height: 50, child: ListView.builder(
        itemCount: orderController.subscriptionType == 'weekly' ? 7
            : orderController.subscriptionType == 'monthly' ? 31 : 0,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          bool isSelected = orderController.selectedDays[index] != null;

          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: InkWell(
              onTap: () async {
                if(orderController.selectedDays[index] != null) {
                  orderController.addDay(index, null);
                }else {
                  TimeOfDay? time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 0, minute: 0));
                  if(time != null) {
                    orderController.addDay(index, time);
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: isSelected ? null : Border.all(color: Theme.of(context).disabledColor, width: 2),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    orderController.subscriptionType == 'monthly' ? '${'day'.tr}: ${index + 1}'
                        : orderController.subscriptionType == 'weekly' ? weekDays[index].tr : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: isSelected ? Colors.white : Theme.of(context).hintColor),
                  ),
                  SizedBox(height: isSelected ? 2 : 0),
                  isSelected ? Text(
                    DateConverter.dateToTimeOnly(orderController.selectedDays[index]!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: isSelected ? Colors.white : Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                  ) : const SizedBox(),
                ]),
              ),
            ),
          );
        },
      )) : const SizedBox(),
    ]);
  }
}
