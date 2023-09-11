import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetView extends StatelessWidget {
  const BottomSheetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius : const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
          topRight : Radius.circular(Dimensions.paddingSizeExtraLarge),
        ),
        // boxShadow: [BoxShadow(color: Colors.grey[200]!, offset: const Offset(0, -5), blurRadius: 10)],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
          borderRadius : const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
            topRight : Radius.circular(Dimensions.paddingSizeExtraLarge),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              height: 3, width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
            child: Row(children: [
              const Icon(Icons.error_outline, size: 16),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text('how_it_works'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), textAlign: TextAlign.center),
            ]),
          ),

          ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppConstants.dataList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(5) ,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.grey[400]!, blurRadius: 5)]
                      ),
                      child: Text('${index+1}'),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text(AppConstants.dataList[index], style: robotoRegular),

                  ]),
                );
              })
        ]),
      ),
    );
  }
}
