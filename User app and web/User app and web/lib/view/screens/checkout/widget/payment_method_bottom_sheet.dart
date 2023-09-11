import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_button_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  const PaymentMethodBottomSheet({Key? key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
          child: GetBuilder<OrderController>(
            builder: (orderController) {
              return Column(children: [

                !ResponsiveHelper.isDesktop(context) ? Container(
                  height: 4, width: 35,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                ) : const SizedBox(),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  IconButton(
                    onPressed: ()=> Get.back(),
                    icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
                  )
                ]),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                isCashOnDeliveryActive ? PaymentButtonNew(
                  icon: Images.cashOnDelivery,
                  title: 'cash_on_delivery'.tr,
                  isSelected: orderController.paymentMethodIndex == 0,
                  onTap: () {
                    orderController.setPaymentMethod(0);
                    Get.back();
                  },
                ) : const SizedBox(),
                SizedBox(height: isCashOnDeliveryActive ? Dimensions.paddingSizeSmall : 0),

                isDigitalPaymentActive ? PaymentButtonNew(
                  icon: Images.digitalPayment,
                  title: 'digital_payment'.tr,
                  isSelected: orderController.paymentMethodIndex == 1,
                  onTap: (){
                    orderController.setPaymentMethod(1);
                    Get.back();
                  },
                ) : const SizedBox(),
                SizedBox(height: isDigitalPaymentActive ? Dimensions.paddingSizeSmall : 0),

               isWalletActive ? PaymentButtonNew(
                  icon: Images.wallet,
                  title: 'wallet_payment'.tr,
                  isSelected: orderController.paymentMethodIndex == 2,
                  onTap: () {
                    orderController.setPaymentMethod(2);
                    Get.back();
                  },
                ) : const SizedBox(),
              ]);
            }
          ),
        ),
      ),
    );
  }
}
