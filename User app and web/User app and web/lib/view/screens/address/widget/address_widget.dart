import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;
  const AddressWidget({Key? key, required this.address, required this.fromAddress, this.onRemovePressed, this.onEditPressed,
    this.onTap, this.fromCheckout = false, this.isSelected = false, this.fromDashBoard = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeSmall),
          decoration: fromDashBoard ? BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: isSelected ? 1 : 0),
          ) : fromCheckout ? const BoxDecoration() : BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor, width: isSelected ? 0.5 : 0),
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                 Image.asset(
                   address!.addressType == 'home' ? Images.homeIcon : address!.addressType == 'office' ? Images.workIcon : Images.otherIcon,
                   height: ResponsiveHelper.isDesktop(context) ? 25 : 20, color: Theme.of(context).primaryColor,
                 ),
                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(
                    address!.addressType!.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                ]),
                //const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(
                  children: [
                    SizedBox(width: ResponsiveHelper.isDesktop(context) ? 35 : 25),
                    Expanded(
                      child: Text(
                        address!.address!,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              ]),
            ),


            // fromAddress ? IconButton(
            //   icon: Icon(Icons.delete, color: Colors.red, size: ResponsiveHelper.isDesktop(context) ? 35 : 25),
            //   onPressed: onRemovePressed as void Function()?,
            // ) : const SizedBox(),

            fromAddress ?
              InkWell(
                onTap: onRemovePressed as void Function()?,
                child: Image.asset(Images.deleteIcon, height: ResponsiveHelper.isDesktop(context) ? 35 : 25),
              )
            : const SizedBox(),

          ]),
        ),
      ),
    );
  }
}