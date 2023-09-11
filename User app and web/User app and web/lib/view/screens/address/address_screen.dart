import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/base/not_logged_in_screen.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_confirmation_dialogue.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<LocationController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return GetBuilder<LocationController>(
      builder: (locationController) {
        return Scaffold (
          appBar: CustomAppBar(title: 'my_address'.tr),
          floatingActionButton:  !isLoggedIn ? null : (locationController.addressList != null
            && locationController.addressList!.isEmpty) ? null : FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
              child: Icon(Icons.add, color: Theme.of(context).cardColor),
          ),

          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: Theme.of(context).primaryColor,
          //   onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
          //   child: Icon(Icons.add, color: Theme.of(context).cardColor),
          // ),
          floatingActionButtonLocation: ResponsiveHelper.isDesktop(context) ? FloatingActionButtonLocation.centerFloat : null,
          body: Container(
            height: context.height,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(Images.city), alignment: Alignment.bottomCenter)),
            child: isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
              return locationController.addressList != null ? locationController.addressList!.isNotEmpty ? RefreshIndicator(
                onRefresh: () async {
                  await locationController.getAddressList();
                },
                child: Scrollbar(child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemCount: locationController.addressList!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return AddressWidget(
                          address: locationController.addressList![index], fromAddress: true,
                          onTap: () {
                            Get.toNamed(RouteHelper.getMapRoute(
                              locationController.addressList![index], 'address',
                            ));
                          },
                          onEditPressed: () {
                            Get.toNamed(RouteHelper.getEditAddressRoute(locationController.addressList![index]));
                          },
                          onRemovePressed: () {
                            if(Get.isSnackbarOpen) {
                              Get.back();
                            }
                            Get.dialog(AddressConfirmDialogue(
                                icon: Images.locationConfirm,
                                title: 'are_you_sure'.tr,
                                description: 'you_want_to_delete_this_location'.tr,
                                onYesPressed: () {
                                  locationController.deleteUserAddressByID(locationController.addressList![index].id, index).then((response) {
                                    Get.back();
                                    showCustomSnackBar(response.message, isError: !response.isSuccess);
                                  });
                                }),
                            );
                          },
                        );
                      },
                    ),
                  )),
                )),
              ) : NoDataScreen(text: 'no_saved_address_found'.tr, fromAddress: true) : const Center(child: CircularProgressIndicator());
            }) : NotLoggedInScreen(callBack: (value){
              initCall();
              setState(() {});
            }),
          ),
        );
      }
    );
  }
}
