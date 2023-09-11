import 'package:efood_multivendor_driver/controller/splash_controller.dart';
import 'package:efood_multivendor_driver/data/api/api_checker.dart';
import 'package:efood_multivendor_driver/data/model/body/record_location_body.dart';
import 'package:efood_multivendor_driver/data/model/body/update_status_body.dart';
import 'package:efood_multivendor_driver/data/model/response/ignore_model.dart';
import 'package:efood_multivendor_driver/data/model/response/order_cancellation_body.dart';
import 'package:efood_multivendor_driver/data/model/response/order_details_model.dart';
import 'package:efood_multivendor_driver/data/model/response/order_model.dart';
import 'package:efood_multivendor_driver/data/repository/order_repo.dart';
import 'package:efood_multivendor_driver/view/base/custom_snackbar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class OrderController extends GetxController implements GetxService {
  final OrderRepo orderRepo;
  OrderController({required this.orderRepo});

  List<OrderModel>? _allOrderList;
  List<OrderModel>? _currentOrderList;
  List<OrderModel>? _deliveredOrderList;
  List<OrderModel>? _completedOrderList;
  List<OrderModel>? _latestOrderList;
  List<OrderDetailsModel>? _orderDetailsModel;
  List<IgnoreModel> _ignoredRequests = [];
  bool _isLoading = false;
  Position _position = const Position(longitude: 0, latitude: 0, timestamp: null, accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
  Placemark _placeMark = Placemark(name: 'Unknown', subAdministrativeArea: 'Location', isoCountryCode: 'Found');
  String _otp = '';
  bool _paginate = false;
  int? _pageSize;
  List<int> _offsetList = [];
  int _offset = 1;
  OrderModel? _orderModel;
  List<CancellationData>? _orderCancelReasons;
  String? _cancelReason = '';

  List<OrderModel>? get allOrderList => _allOrderList;
  List<OrderModel>? get currentOrderList => _currentOrderList;
  List<OrderModel>? get deliveredOrderList => _deliveredOrderList;
  List<OrderModel>? get completedOrderList => _completedOrderList;
  List<OrderModel>? get latestOrderList => _latestOrderList;
  List<OrderDetailsModel>? get orderDetailsModel => _orderDetailsModel;
  bool get isLoading => _isLoading;
  Position get position => _position;
  Placemark get placeMark => _placeMark;
  String get address => '${_placeMark.name} ${_placeMark.subAdministrativeArea} ${_placeMark.isoCountryCode}';
  String get otp => _otp;
  bool get paginate => _paginate;
  int? get pageSize => _pageSize;
  int get offset => _offset;
  OrderModel? get orderModel => _orderModel;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;
  String? get cancelReason => _cancelReason;

  void setOrderCancelReason(String? reason){
    _cancelReason = reason;
    update();
  }

  Future<void> getOrderCancelReasons()async {
    Response response = await orderRepo.getCancelReasons();
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody = OrderCancellationBody.fromJson(response.body);
      _orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        _orderCancelReasons!.add(element);
      }

    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getAllOrders() async {
    Response response = await orderRepo.getAllOrders();
    if(response.statusCode == 200) {
      _allOrderList = [];
      response.body.forEach((order) => _allOrderList!.add(OrderModel.fromJson(order)));
      _deliveredOrderList = [];
      for (var order in _allOrderList!) {
        if(order.orderStatus == 'delivered'){
          _deliveredOrderList!.add(order);
        }
      }
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getCompletedOrders(int offset) async {
    if(offset == 1) {
      _offsetList = [];
      _offset = 1;
      _completedOrderList = null;
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      Response response = await orderRepo.getCompletedOrderList(offset);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _completedOrderList = [];
        }
        _completedOrderList!.addAll(PaginatedOrderModel.fromJson(response.body).orders!);
        _pageSize = PaginatedOrderModel.fromJson(response.body).totalSize;
        _paginate = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_paginate) {
        _paginate = false;
        update();
      }
    }
  }

  void showBottomLoader() {
    _paginate = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  Future<void> getCurrentOrders() async {
    Response response = await orderRepo.getCurrentOrders();
    if(response.statusCode == 200) {
      _currentOrderList = [];
      response.body.forEach((order) => _currentOrderList!.add(OrderModel.fromJson(order)));
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getOrderWithId(int? orderId) async {
    Response response = await orderRepo.getOrderWithId(orderId);
    if(response.statusCode == 200) {
      _orderModel = OrderModel.fromJson(response.body);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getLatestOrders() async {
    Response response = await orderRepo.getLatestOrders();
    if(response.statusCode == 200) {
      _latestOrderList = [];
      List<int?> ignoredIdList = [];
      for (var ignore in _ignoredRequests) {
        ignoredIdList.add(ignore.id);
      }
      response.body.forEach((order) {
        if(!ignoredIdList.contains(OrderModel.fromJson(order).id)) {
          _latestOrderList!.add(OrderModel.fromJson(order));
        }
      });
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> recordLocation(RecordLocationBody recordLocationBody) async {
    Response response = await orderRepo.recordLocation(recordLocationBody);
    if(response.statusCode == 200) {

    }else {
      ApiChecker.checkApi(response);
    }
  }

  Future<bool> updateOrderStatus(int? orderId, String status, {bool back = false,  String? reason}) async {
    _isLoading = true;
    update();
    UpdateStatusBody updateStatusBody = UpdateStatusBody(
      orderId: orderId, status: status,
      otp: status == 'delivered' ? _otp : null, reason: reason,
    );
    Response response = await orderRepo.updateOrderStatus(updateStatusBody);
    Get.back();
    bool isSuccess;
    if(response.statusCode == 200) {
      if(back) {
        Get.back();
      }
      getCurrentOrders();
      showCustomSnackBar(response.body['message'], isError: false);
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<void> updatePaymentStatus(int index, String status) async {
    _isLoading = true;
    update();
    UpdateStatusBody updateStatusBody = UpdateStatusBody(orderId: _currentOrderList![index].id, status: status);
    Response response = await orderRepo.updatePaymentStatus(updateStatusBody);
    if(response.statusCode == 200) {
      _currentOrderList![index].paymentStatus = status;
      showCustomSnackBar(response.body['message'], isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> getOrderDetails(int? orderID) async {
    _orderDetailsModel = null;
    Response response = await orderRepo.getOrderDetails(orderID);
    if(response.statusCode == 200) {
      _orderDetailsModel = [];
      response.body.forEach((orderDetails) => _orderDetailsModel!.add(OrderDetailsModel.fromJson(orderDetails)));
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<bool> acceptOrder(int? orderID, int index, OrderModel orderModel) async {
    _isLoading = true;
    update();
    Response response = await orderRepo.acceptOrder(orderID);
    Get.back();
    bool isSuccess;
    if(response.statusCode == 200) {
      _latestOrderList!.removeAt(index);
      _currentOrderList!.add(orderModel);
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

  void getIgnoreList() {
    _ignoredRequests = [];
    _ignoredRequests.addAll(orderRepo.getIgnoreList());
  }

  void ignoreOrder(int index) {
    _ignoredRequests.add(IgnoreModel(id: _latestOrderList![index].id, time: DateTime.now()));
    _latestOrderList!.removeAt(index);
    orderRepo.setIgnoreList(_ignoredRequests);
    update();
  }

  void removeFromIgnoreList() {
    List<IgnoreModel> tempList = [];
    tempList.addAll(_ignoredRequests);
    for(int index=0; index<tempList.length; index++) {
      if(Get.find<SplashController>().currentTime.difference(tempList[index].time!).inMinutes > 10) {
        tempList.removeAt(index);
      }
    }
    _ignoredRequests = [];
    _ignoredRequests.addAll(tempList);
    orderRepo.setIgnoreList(_ignoredRequests);
  }
  
  Future<void> getCurrentLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    if(!GetPlatform.isWeb) {
      try {
        List<Placemark> placeMarks = await placemarkFromCoordinates(currentPosition.latitude, currentPosition.longitude);
        _placeMark = placeMarks.first;
      }catch(_) {}
    }
    _position = currentPosition;
    update();
  }

  void setOtp(String otp) {
    _otp = otp;
    if(otp != '') {
      update();
    }
  }

}