import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookiesView extends StatefulWidget {


  const CookiesView({Key? key}) : super(key: key);

  @override
  State<CookiesView> createState() => _CookiesViewState();
}


class _CookiesViewState extends State<CookiesView> {


  // SplashController splashController = Get.put(SplashController(splashRepo: null));

  @override
  Widget build(BuildContext context) {
    bool isAccepted = false;

    double padding = (MediaQuery.of(context).size.width - Dimensions.webMaxWidth) / 2;
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(Get.isDarkMode ? 1 : 0.8)),
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: ResponsiveHelper.isDesktop(context) ? padding : Dimensions.paddingSizeDefault,
      ),
      child: Padding(padding:  EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: Text(
              'This is dummy cookies text',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.white70),
              maxLines: 10, textAlign: TextAlign.justify, overflow: TextOverflow.ellipsis,
            ),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.end, children: [

            TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50,30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: (){
                  Get.find<SplashController>().saveCookiesData(false);
                   Get.find<SplashController>().cookiesStatusChange(Get.find<SplashController>().configModel!.cookiesText ?? 'This is dummy cookies text');
                }, child:  Text(
              'no_thanks'.tr,
              style: robotoRegular.copyWith(color: Colors.white70,fontSize: Dimensions.fontSizeSmall),
            )),


            SizedBox(width: ResponsiveHelper.isDesktop(context)?Dimensions.paddingSizeExtraLarge:Dimensions.paddingSizeLarge,),

            TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(80,35),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {

                  Get.find<SplashController>().saveCookiesData(true);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("savedCookiesData",true);
                 print("onpresss12 ${ prefs.getBool('savedCookiesData')}");
                  Get.find<SplashController>().cookiesStatusChange(Get.find<SplashController>().configModel!.cookiesText ?? 'This is dummy cookies text');


                },
                child:  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: 5),
                  child: Center(
                    child: Text(
                      'yes_accept'.tr, style: robotoRegular.copyWith(color: Colors.white70,fontSize: Dimensions.fontSizeSmall),
                    ),
                  ),
                )),

          ])

        ]),
      ),
    )
     ;
  }
}
