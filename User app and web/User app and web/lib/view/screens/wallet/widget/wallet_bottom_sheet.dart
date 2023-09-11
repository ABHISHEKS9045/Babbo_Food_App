
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wallet_controller.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletBottomSheet extends StatefulWidget {
  final bool fromWallet;
  final String amount;
  const WalletBottomSheet({Key? key, required this.fromWallet, required this.amount}) : super(key: key);

  @override
  State<WalletBottomSheet> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends State<WalletBottomSheet> {

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    int? exchangePointRate = Get.find<SplashController>().configModel!.loyaltyPointExchangeRate;
    int? minimumExchangePoint = Get.find<SplashController>().configModel!.minimumPointToTransfer;
    _amountController.text = exchangePointRate.toString();

    return Stack(
      children: [

    Container(
      width: 550,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge), bottom: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Image.asset(Images.loyaltyIcon, height: 50, width: 50),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            '$exchangePointRate ${'points'.tr}= ${PriceConverter.convertPrice(1)}', textDirection: TextDirection.ltr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            '(${'from'.tr} ${widget.amount} ${'points'.tr})',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            'amount_can_be_convert_into_wallet_money'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), border: Border.all(color: Theme.of(context).primaryColor,width: 0.3)),
            child: CustomTextField(
              hintText: '0',
              controller: _amountController,
              inputType: TextInputType.phone,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          GetBuilder<WalletController>(
            builder: (walletController) {
              return !walletController.isLoading ? CustomButton(
                  width: 150,
                  radius: 100,
                  buttonText: 'convert'.tr,
                  onPressed: () {
                    if(_amountController.text.isEmpty) {
                      if(Get.isBottomSheetOpen!){
                        Get.back();
                      }
                      showCustomSnackBar('input_field_is_empty'.tr);
                    }else{
                      int amount = int.parse(_amountController.text.trim());

                      if(amount <minimumExchangePoint!){
                        if(Get.isBottomSheetOpen!){
                          Get.back();
                        }
                        showCustomSnackBar('${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                      } else {
                          walletController.pointToWallet(amount, widget.fromWallet);
                        }
                    }
                },
              ) : const Center(child: CircularProgressIndicator());
            }
          ),
        ]),
      ),
    ),
    Positioned(
      top: 10, right: 10,
      child: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.clear, size: 18),
      ),
    ),
    ],
    );
  }
}
