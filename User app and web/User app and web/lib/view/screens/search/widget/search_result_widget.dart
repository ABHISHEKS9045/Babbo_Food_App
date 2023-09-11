import 'package:efood_multivendor/controller/search_controller.dart' as search;
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/search/widget/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  const SearchResultWidget({Key? key, required this.searchText}) : super(key: key);

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      GetBuilder<search.SearchController>(builder: (searchController) {
        bool isNull = true;
        int length = 0;
        if(searchController.isRestaurant) {
          isNull = searchController.searchRestList == null;
          if(!isNull) {
            length = searchController.searchRestList!.length;
          }
        }else {
          isNull = searchController.searchProductList == null;
          if(!isNull) {
            length = searchController.searchProductList!.length;
          }
        }
        return isNull ? const SizedBox() : Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [
            Text(
              length.toString(),
              style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              'results_found'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        )));
      }),

      Center(child: Container(
        width: Dimensions.webMaxWidth,
        color: Theme.of(context).cardColor,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).disabledColor,
          unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
          labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
          tabs: [
            Tab(text: 'food'.tr),
            Tab(text: 'restaurants'.tr),
          ],
        ),
      )),

      Expanded(child: NotificationListener(
        onNotification: (dynamic scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            Get.find<search.SearchController>().setRestaurant(_tabController!.index == 1);
            Get.find<search.SearchController>().searchData(widget.searchText);
          }
          return false;
        },
        child: TabBarView(
          controller: _tabController,
          children: const [
            ItemView(isRestaurant: false),
            ItemView(isRestaurant: true),
          ],
        ),
      )),

    ]);
  }
}
