import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/controller/wallet_controller.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/base/not_logged_in_screen.dart';
import 'package:efood_multivendor/view/base/title_widget.dart';
import 'package:efood_multivendor/view/screens/wallet/widget/history_item.dart';
import 'package:efood_multivendor/view/screens/wallet/widget/wallet_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WalletScreen extends StatefulWidget {
  final bool fromWallet;
  const WalletScreen({Key? key, required this.fromWallet}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()){
      Get.find<UserController>().getUserInfo();

      Get.find<WalletController>().getWalletTransactionList('1', false, widget.fromWallet);

      Get.find<WalletController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && Get.find<WalletController>().transactionList != null
            && !Get.find<WalletController>().isLoading) {
          int pageSize = (Get.find<WalletController>().popularPageSize! / 10).ceil();
          if (Get.find<WalletController>().offset < pageSize) {
            Get.find<WalletController>().setOffset(Get.find<WalletController>().offset + 1);
            debugPrint('end of the page');
            Get.find<WalletController>().showBottomLoader();
            Get.find<WalletController>().getWalletTransactionList(Get.find<WalletController>().offset.toString(), false, widget.fromWallet);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBar(title: widget.fromWallet ? 'wallet'.tr : 'loyalty_points'.tr,isBackButtonExist: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (!widget.fromWallet && isLoggedIn && !ResponsiveHelper.isDesktop(context)
      && Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text('convert_to_wallet_money'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
        onPressed: (){
          Get.dialog(
            Dialog(backgroundColor: Colors.transparent, child: WalletBottomSheet(
              fromWallet: widget.fromWallet, amount: Get.find<UserController>().userInfoModel!.loyaltyPoint == null ? '0' : Get.find<UserController>().userInfoModel!.loyaltyPoint.toString(),
            )),
          );
        },
      ) : null,
      body: GetBuilder<UserController>(
        builder: (userController) {
          return isLoggedIn ? userController.userInfoModel != null ? SafeArea(
            child: RefreshIndicator(
              onRefresh: () async{
                 Get.find<WalletController>().getWalletTransactionList('1', true, widget.fromWallet);
                 Get.find<UserController>().getUserInfo();
              },
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: GetBuilder<WalletController>(
                      builder: (walletController) {
                        return Column(children: [

                           Stack(
                            children: [
                              Container(
                                padding: widget.fromWallet ? const EdgeInsets.all(Dimensions.paddingSizeOverLarge) : const EdgeInsets.only(top: 40, left: Dimensions.paddingSizeOverLarge, right: Dimensions.paddingSizeOverLarge, bottom: Dimensions.paddingSizeOverLarge),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: widget.fromWallet ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withOpacity(0.2),
                                ),
                                child:  Row(mainAxisAlignment: widget.fromWallet ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

                                  Image.asset( widget.fromWallet ? Images.wallet : Images.loyal , height: 60, width: 60, color: widget.fromWallet ? Theme.of(context).cardColor : null),
                                  const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                                  widget.fromWallet ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('wallet_amount'.tr,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),

                                      Text(
                                        PriceConverter.convertPrice(userController.userInfoModel!.walletBalance), textDirection: TextDirection.ltr,
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                                      ),
                                    ])
                                      : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                                        Text(
                                          '${'loyalty_points'.tr} !',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeSmall),

                                        Text(
                                          userController.userInfoModel!.loyaltyPoint == null ? '0' : userController.userInfoModel!.loyaltyPoint.toString(),
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
                                          textDirection: TextDirection.ltr,
                                        ),
                                    ],)
                                ]),
                              ),

                              (ResponsiveHelper.isDesktop(context) && !widget.fromWallet
                              && Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? Positioned(
                                top: 30, right: 20,
                                child: InkWell(
                                  onTap: (){
                                    Get.dialog(
                                      Dialog(backgroundColor: Colors.transparent, child: WalletBottomSheet(
                                        fromWallet: widget.fromWallet, amount: Get.find<UserController>().userInfoModel!.loyaltyPoint == null ? '0' : Get.find<UserController>().userInfoModel!.loyaltyPoint.toString(),
                                      )),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                                    child:  Text('convert_to_wallet_money'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                                  ),
                                ),
                              ) : const SizedBox(),
                              // widget.fromWallet ? const SizedBox.shrink() : Positioned(
                              //   top: 10,right: 10,
                              //   child: InkWell(
                              //     onTap: (){
                              //       ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                              //           WalletBottomSheet(fromWallet: widget.fromWallet)
                              //       ) : Get.dialog(
                              //         Dialog(child: WalletBottomSheet(fromWallet: widget.fromWallet)),
                              //       );
                              //     },
                              //     child: Row(
                              //       children: [
                              //         Text(
                              //           'convert_to_currency'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                              //             color: widget.fromWallet ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color),
                              //         ),
                              //         Icon(Icons.keyboard_arrow_down_outlined,size: 16, color: widget.fromWallet ? Theme.of(context).cardColor
                              //             : Theme.of(context).textTheme.bodyLarge!.color)
                              //       ],
                              //     ),
                              //   ),
                              // )
                            ],
                          ) ,


                          Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeOverLarge),
                              child: TitleWidget(title: 'transaction_history'.tr),
                            ),
                            walletController.transactionList != null ? walletController.transactionList!.isNotEmpty ? GridView.builder(
                              key: UniqueKey(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 50,
                                mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.45,
                                crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                              ),
                              physics:  const NeverScrollableScrollPhysics(),
                              shrinkWrap:  true,
                              itemCount: walletController.transactionList!.length ,
                              padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
                              itemBuilder: (context, index) {
                                return HistoryItem(index: index,fromWallet: widget.fromWallet, data: walletController.transactionList );
                              },
                            ) : NoDataScreen(text: 'no_data_found'.tr) : WalletShimmer(walletController: walletController),

                            walletController.isLoading ? const Center(child: Padding(
                              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: CircularProgressIndicator(),
                            )) : const SizedBox(),
                          ])
                        ]);
                      }
                    ),
                  ),
                ),
              ),
            ),
          ) : const Center(child: CircularProgressIndicator()) : NotLoggedInScreen(callBack: (value){
            initCall();
            setState(() {});
          });
        }
      ),
    );
  }
}
class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  const WalletShimmer({Key? key, required this.walletController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault), child: Divider(color: Theme.of(context).disabledColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}