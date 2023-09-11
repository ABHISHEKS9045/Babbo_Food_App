import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/auth/widget/registration_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class SuccessWidget extends StatelessWidget {
  const SuccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Center(
          child: Container(
            width: Dimensions.webMaxWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

              authController.businessIndex == 1 ? RegistrationStepperWidget(status: authController.businessPlanStatus) : const SizedBox(height: Dimensions.paddingSizeLarge),
              SizedBox(height: context.height * 0.2),

              Image.asset(Images.checked, height: 90,width: 90),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('congratulations'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'your_registration_has_been_completed_successfully'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center, softWrap: true,
              ),

            ]),
          ),
        );
      }
    );
  }
}
