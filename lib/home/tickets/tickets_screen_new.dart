import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:heyto/app/setup.dart';
import 'package:heyto/helpers/quick_help.dart';
import 'package:heyto/home/tickets/tickets_ads_screen.dart';
import 'package:heyto/models/UserModel.dart';
import 'package:heyto/ui/container_with_corner.dart';
import 'package:heyto/ui/text_with_tap.dart';
import 'package:heyto/app/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iban/iban.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../../app/config.dart';
import '../../auth/phone_verify_screen.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_cloud.dart';
import '../../models/PaymentsModel.dart';
import '../../models/WithdrawModel.dart';
import '../../models/others/in_app_model.dart';
import '../../ui/app_bar.dart';
import '../../ui/button_rounded.dart';

// ignore: must_be_immutable
class TicketsScreen extends StatefulWidget {
  static String route = '/tickets';

  UserModel? currentUser;
  TicketsScreen({this.currentUser});

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {


  TextEditingController payoonerEmailController = TextEditingController();
  TextEditingController moneyToTransferController = TextEditingController();
  TextEditingController ibanTextEditingController = TextEditingController();
  TextEditingController accountNameTextEditingController =
  TextEditingController();
  TextEditingController bankNameTextEditingController = TextEditingController();

  double numberOfDiamonds = 0;
  double? totalMoney;
  double? minQuantityToWithdraw;
  double widthOfContainer = 350;

  int? paymentType = 0;
  ProductDetails? product;

  int tabTypeGoogleOrApple = 0;
  int tabTypeCreditCard = 1;
  int tabTypePayPal = 2;
  int tabPosition = 0;
  String payBtnText = "continue".tr();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  List<ProductDetails> _products = [];
  InAppPurchaseModel? _inAppPurchaseModel;

  List<String> _kProductIds = <String>[
    Config.credit200,
    Config.credit1000,
    Config.credit100,
    Config.credit500,
    Config.credit2000,
    Config.credit5000,
    Config.credit10000,
  ];

  List<InAppPurchaseModel> getInAppList() {
    List<InAppPurchaseModel> inAppPurchaseList = [];

    for (ProductDetails productDetails in _products) {
      if (productDetails.id == Config.credit200) {
        InAppPurchaseModel credits200 = InAppPurchaseModel(
            id: Config.credit200,
            coins: 200,
            price: productDetails.price,
            image: "assets/images/ticket-star.png",
            type: InAppPurchaseModel.typePopular,
            productDetails: productDetails,
            currency: productDetails.currencyCode,
            currencySymbol: productDetails.currencySymbol);

        if (!inAppPurchaseList.contains(Config.credit200)) {
          inAppPurchaseList.add(credits200);
        }
      }

      if (productDetails.id == Config.credit1000) {
        InAppPurchaseModel credits1000 = InAppPurchaseModel(
            id: Config.credit1000,
            coins: 1000,
            price: productDetails.price,
            image: "assets/images/ticket-star.png",
            type: InAppPurchaseModel.typeHot,
            productDetails: productDetails,
            currency: productDetails.currencyCode,
            currencySymbol: productDetails.currencySymbol);

        if (!inAppPurchaseList.contains(Config.credit1000)) {
          inAppPurchaseList.add(credits1000);
        }
      }

      if (productDetails.id == Config.credit100) {
        InAppPurchaseModel credits100 = InAppPurchaseModel(
            id: Config.credit100,
            coins: 100,
            price: productDetails.price,
            image: "assets/images/ticket-star.png",
            type: InAppPurchaseModel.typeNormal,
            productDetails: productDetails,
            currency: productDetails.currencyCode,
            currencySymbol: productDetails.currencySymbol);

        if (!inAppPurchaseList.contains(Config.credit100)) {
          inAppPurchaseList.add(credits100);
        }
      }

      if (productDetails.id == Config.credit500) {
        InAppPurchaseModel credits500 = InAppPurchaseModel(
            id: Config.credit500,
            coins: 500,
            price: productDetails.price,
            image: "assets/images/ticket-star.png",
            type: InAppPurchaseModel.typeNormal,
            productDetails: productDetails,
            currency: productDetails.currencyCode,
            currencySymbol: productDetails.currencySymbol);

        if (!inAppPurchaseList.contains(Config.credit500)) {
          inAppPurchaseList.add(credits500);
        }
      }

      if (productDetails.id == Config.credit2000) {
        InAppPurchaseModel credits2100 = InAppPurchaseModel(
            id: Config.credit2000,
            coins: 2000,
            price: productDetails.price,
            discount: "22,09",
            image: "assets/images/ticket-star.png",
            type: InAppPurchaseModel.typeNormal,
            productDetails: productDetails,
            currency: productDetails.currencyCode,
            currencySymbol: productDetails.currencySymbol);

        if (!inAppPurchaseList.contains(Config.credit2000)) {
          inAppPurchaseList.add(credits2100);
        }
      }

      if (productDetails.id == Config.credit5000) {
        InAppPurchaseModel credits5250 = InAppPurchaseModel(
            id: Config.credit5000,
            coins: 5000,
            price: productDetails.price,
            discount: "57,79",
            image: "assets/images/ticket-star.png",
            type: InAppPurchaseModel.typeNormal,
            productDetails: productDetails,
            currency: productDetails.currencyCode,
            currencySymbol: productDetails.currencySymbol);

        if (!inAppPurchaseList.contains(Config.credit5000)) {
          inAppPurchaseList.add(credits5250);
        }
      }

      if (productDetails.id == Config.credit10000) {
        InAppPurchaseModel credits10500 = InAppPurchaseModel(
            id: Config.credit10000,
            coins: 10000,
            price: productDetails.price,
            discount: "110,29",
            image: "assets/images/ticket-star.png",
            type: InAppPurchaseModel.typeNormal,
            productDetails: productDetails,
            currency: productDetails.currencyCode,
            currencySymbol: productDetails.currencySymbol);

        if (!inAppPurchaseList.contains(Config.credit10000)) {
          inAppPurchaseList.add(credits10500);
        }
      }
    }

    return inAppPurchaseList;
  }

  void update() => setState(() {});

  @override
  void dispose() {
    _disposePayment();
    super.dispose();
  }

  _disposePayment() {
    if (QuickHelp.isIOSPlatform()) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
  }

  @override
  void initState() {
    _initPayment();
    super.initState();
  }

  _initPayment() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
      print("InAppPurchase initState: $error");
    });
    //getUser();
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (QuickHelp.isIOSPlatform()) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(IOSPaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse =
    await _inAppPurchase.queryProductDetails(_kProductIds.toSet());

    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchasePending = false;
      _loading = false;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.canceled) {
          QuickHelp.hideLoadingDialog(context);


          QuickHelp.showAppNotificationAdvanced(
            context: context,
            user: widget.currentUser,
            title: "in_app_purchases.purchase_cancelled_title".tr(),
            message: "in_app_purchases.purchase_cancelled".tr(),
          );
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _addPurchaseToUserAccount(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  _purchaseProduct(ProductDetails productDetails) async {
    if (QuickHelp.isAndroidPlatform()) {
      QuickHelp.showLoadingDialog(context);
    }

    _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
        autoConsume: true)
        .onError((error, stackTrace) {
      print("InAppPurchase error: $error");

      if (error is PlatformException &&
          error.code == "storekit_duplicate_product_object") {
        QuickHelp.showAppNotification(context: context,
          title: "in_app_purchases.purchase_pending_error".tr(),);
      }
      return false;
    });
  }

  _initPayPalPayment() {
    print(product!.title);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {

    ParseResponse response = await QuickCloudCode.verifyPayment(
        productSku: purchaseDetails.productID,
        purchaseToken: purchaseDetails.verificationData.serverVerificationData);
    if(response.success){
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
    QuickHelp.showAppNotification(context:context, title: "in_app_purchases.invalid_purchase".tr());
    QuickHelp.hideLoadingDialog(context);
  }

  _addPurchaseToUserAccount(PurchaseDetails purchaseDetails) async {
    print("InAppPurchase addToUser: ${purchaseDetails.productID}");

    _inAppPurchase.completePurchase(purchaseDetails);

    if (QuickHelp.isAndroidPlatform()) {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
      _inAppPurchase
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

      await androidAddition.consumePurchase(purchaseDetails);
    }

    if(widget.currentUser != null){

      widget.currentUser?.setPremium = _inAppPurchaseModel!.getPeriod()!;

      ParseResponse parseResponse = await widget.currentUser!.save();
      if(parseResponse.success){
        widget.currentUser = parseResponse.results!.first as UserModel;
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(context:context,
          user: widget.currentUser,
          title: "in_app_purchases.subs_purchased".tr(),
          message: "in_app_purchases.subs_added_to_account".tr(),
          isError: false,
        );

        registerPayment(purchaseDetails, _inAppPurchaseModel!.productDetails!);
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotification(context:context, title: parseResponse.error!.message);
      }

    } else {

      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotification(context:context, title: "in_app_purchases.error_found".tr());
    }
  }

  void registerPayment(PurchaseDetails purchaseDetails, ProductDetails productDetails) async {

    // Save all payment information
    PaymentsModel paymentsModel = PaymentsModel();
    paymentsModel.setAuthor = widget.currentUser!;
    paymentsModel.setAuthorId = widget.currentUser!.objectId!;
    paymentsModel.setPaymentType = PaymentsModel.paymentTypeSubscription;

    paymentsModel.setId = productDetails.id;
    paymentsModel.setTitle = productDetails.title;
    paymentsModel.setTransactionId = purchaseDetails.purchaseID!;
    paymentsModel.setCurrency = productDetails.currencyCode.toUpperCase();
    paymentsModel.setPrice = productDetails.price;
    paymentsModel.setMethod = QuickHelp.isAndroidPlatform()? "Google Play" : QuickHelp.isIOSPlatform() ? "App Store" : "";
    paymentsModel.setStatus = PaymentsModel.paymentStatusCompleted;

    await paymentsModel.save();
  }

  void handleError(IAPError error) {

    QuickHelp.hideLoadingDialog(context);
    QuickHelp.showAppNotification(context:context, title: error.message);

    setState(() {
      _purchasePending = false;
    });
  }

  showPendingUI() {

    QuickHelp.showLoadingDialog(context);
    print("InAppPurchase showPendingUI");
  }

  @override
  Widget build(BuildContext context) {

    numberOfDiamonds = widget.currentUser!.getDiamonds!.toDouble() * (widthOfContainer / Setup.diamondsNeededToRedeem);
    totalMoney = QuickHelp.convertDiamondsToMoney(widget.currentUser!.getDiamonds!);
    minQuantityToWithdraw = QuickHelp.convertDiamondsToMoney(Setup.diamondsNeededToRedeem);

    return ToolBar(
      leftButtonWidget: IconButton(
        onPressed: ()=> QuickHelp.goBackToPreviousPage(context, result: widget.currentUser),
        icon: SvgPicture.asset("assets/svg/close_round.svg", color: kGrayColor,),
      ),
      rightButtonIcon: Icons.payments_outlined,
      rightIconColor: Colors.white,
      rightButtonPress: (){
        _showEditPaymentAccountsBottomSheet();
      },
      extendBodyBehindAppBar: true,
      iconHeight: 30,
      iconWidth: 30,
      backgroundColor: kTransparentColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              balanceCard(),
              tabs(),
              Divider(),
              getBody(),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                Visibility(
                  visible: _isAvailable && !_loading,
                  child: ButtonRounded(
                    text: payBtnText,
                    height: 50,
                    marginLeft: 20,
                    marginRight: 20,
                    borderRadius: 10,
                    marginBottom: 20,
                    color: kPrimaryColor,
                    fontSize: 16,
                    textColor: Colors.white,
                    onTap: () => _payBtnTap(),
                  ),
                ),
                termsAndPrivacyMobile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _payBtnTap() {
    if (tabPosition == tabTypeGoogleOrApple) {
      _purchaseProduct(product!);
    } else if (tabPosition == tabTypeCreditCard) {
      if (Setup.isStripePaymentsEnabled) {

        _initStripePayment(_inAppPurchaseModel!);
      } else {
        _initPayPalPayment();
      }
    } else if (tabPosition == tabTypePayPal) {
      _initPayPalPayment();
    }
  }

  Widget balanceCard(){
    return Container(
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .27,
            color: navyBlue1,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "tickets.total_balance".tr(),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: lightNavyBlue),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.currentUser!.getCredits.toString(),
                          style: GoogleFonts.mulish(
                              textStyle: Theme.of(context).textTheme.headline4,
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                              color: kSecondaryColor),
                        ),
                        TextWithTap(
                            "tickets.coins".tr(),
                            fontSize: 35,
                            marginLeft: 10,
                            fontWeight: FontWeight.w500,
                            color: kPrimaryColor.withAlpha(200)
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "tickets.eq".tr(),
                          style: GoogleFonts.mulish(
                              textStyle: Theme.of(context).textTheme.headline4,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: lightNavyBlue),
                        ),
                        TextWithTap(
                          "${Setup.withdrawCurrencySymbol} ${QuickHelp.convertDiamondsToMoney(widget.currentUser!.getDiamonds!).toStringAsFixed(2).toString()}",
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          marginLeft: 5,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ContainerCorner(
                          width: 120,
                          borderColor: Colors.white,
                          borderWidth: 1,
                          radiusBottomLeft: 12,
                          radiusBottomRight: 12,
                          radiusTopLeft: 12,
                          radiusTopRight: 12,
                          marginLeft: 5,
                          marginRight: 5,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text("tickets.reward".tr(),
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          onTap: () async {
                            _disposePayment();

                            UserModel? result = await QuickHelp.goToNavigatorScreenForResult(context, TicketsAdsScreen(currentUser: widget.currentUser ), route: TicketsAdsScreen.route);

                            if(result != null){
                              _initPayment();
                            }
                          },
                        ),
                        ContainerCorner(
                            width: 120,
                            borderColor: Colors.white,
                            borderWidth: 1,
                            radiusBottomLeft: 12,
                            radiusBottomRight: 12,
                            radiusTopLeft: 12,
                            radiusTopRight: 12,
                            marginLeft: 5,
                            marginRight: 5,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                                Text("tickets.withdraw".tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ), onTap: () async {
                          checkWithdraw();
                        },)
                      ],
                    )
                  ],
                ),
                Positioned(
                  left: -170,
                  top: -170,
                  child: CircleAvatar(
                    radius: 130,
                    backgroundColor: lightBlue2,
                  ),
                ),
                Positioned(
                  left: -160,
                  top: -190,
                  child: CircleAvatar(
                    radius: 130,
                    backgroundColor: lightBlue1,
                  ),
                ),
                Positioned(
                  right: -170,
                  bottom: -170,
                  child: CircleAvatar(
                    radius: 130,
                    backgroundColor: kSecondaryColor,
                  ),
                ),
                Positioned(
                  right: -160,
                  bottom: -190,
                  child: CircleAvatar(
                    radius: 130,
                    backgroundColor: kPrimaryColor,
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget tabs() {
    return DefaultTabController(
        length: getAllowedPaymentsMethods().length,
        child: TabBar(
          isScrollable: true,
          labelColor: QuickHelp.isDarkMode(context) ? kGrayColor : Colors.black,
          unselectedLabelColor: kColorsGrey600,
          automaticIndicatorColorAdjustment: true,
          indicatorColor: kGreenColor,
          indicatorPadding: EdgeInsets.only(bottom: -8),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: getAllowedPaymentsMethods(),
          onTap: (position) => _tabTap(position),
        ));
  }

  _tabTap(int tab) {
    tabPosition = tab;

    setState(() {
      if (tab == tabTypeGoogleOrApple) {
        payBtnText = "continue".tr();
      } else if (tab == tabTypeCreditCard) {
        if (Setup.isStripePaymentsEnabled) {
          payBtnText = "payment_screen.pay_with_credit_card".tr();
        } else {
          payBtnText = "payment_screen.pay_with_paypal".tr();
        }
      } else if (tab == tabTypePayPal) {
        payBtnText = "payment_screen.pay_with_paypal".tr();
      }
    });
  }

  termsAndPrivacyMobile({Color? color}){

    return ContainerCorner(
      child: Column(
        children: [
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                    style: TextStyle(
                        color: color != null? color : QuickHelp.isDarkMode(context)
                            ? Colors.white
                            : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    text: "auth.privacy_policy".tr(),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        QuickHelp.goToWebPage(context,
                            pageType: QuickHelp.pageTypePrivacy,
                            pageUrl: Config.privacyPolicyUrl);
                      }),
                TextSpan(
                    style: TextStyle(
                        color: color != null? color : QuickHelp.isDarkMode(context)
                            ? Colors.white
                            : Colors.black,
                        fontSize: 12),
                    text:" - "),
                TextSpan(
                    style: TextStyle(
                        color: color != null? color : QuickHelp.isDarkMode(context)
                            ? Colors.white
                            : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    text: "auth.terms_of_use".tr(),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        QuickHelp.goToWebPage(context,
                            pageType: QuickHelp.pageTypeTerms,
                            pageUrl: Config.termsOfUseUrl);
                      }),
              ])),
        ],
      ),
      width: 350,
      marginBottom: 10,
    );
  }

  Widget getBody() {
    if (_purchasePending) {}

    if (_loading) {
      return QuickHelp.appLoading();
    } else if (_isAvailable && _products.isNotEmpty) {
      if (_queryProductError == null) {

        return productList();

      } else {
        return QuickActions.noContentFound("in_app_purchases.error_found".tr(),
            _queryProductError!, "assets/svg/ticket_icon.svg");
      }
    } else {
      return QuickActions.noContentFound(
          "in_app_purchases.no_product_found_title".tr(),
          "", "assets/svg/ticket_icon.svg");
    }
  }

  Widget productList() {

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        height: 320,
        child: Wrap(
          runSpacing: 10,
          spacing: 10,
          children: List.generate(getInAppList().length, (index) {
            ProductDetails productDetails = _products[index];
            _inAppPurchaseModel = getInAppList()[index];

            if (product == null) {
              product = productDetails;
            }
            return GestureDetector(
              onTap: () {
                _updateProduct(productDetails);
              },
              child: Stack(
                children: [
                  ContainerCorner(
                    width: 120,
                    borderWidth: product!.id == productDetails.id ? 2.5 : 1,
                    marginTop: 10,
                    borderRadius: 12,
                    borderColor: product!.id == productDetails.id
                        ? kGreenColor
                        : kColorsGrey300,
                    color: kTransparentColor,
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextWithTap(
                            _getCreditText(productDetails),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            marginTop: 15,
                            textAlign: TextAlign.center,
                          ),
                          TextWithTap(
                            "user_credits".tr(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                          /*TextWithTap(
                            "${"10.00"} ${product!.currencyCode}",
                            color: kColorsGrey600,
                            decoration: TextDecoration.lineThrough,
                          ),*/
                          TextWithTap(
                            "${productDetails.price} ${product!.currencyCode}",
                            color: kGreenColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            marginBottom: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ContainerCorner(
                    color: kTransparentColor,
                    borderColor: kTransparentColor,
                    //marginLeft: index == 0 ? 15 : 10,
                    width: 120,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Visibility(
                            visible: _getPromoText(productDetails).isNotEmpty,
                            child: ContainerCorner(
                              marginBottom: 20,
                              borderRadius: 4,
                              borderColor: kTransparentColor,
                              color: kGreenColor,
                              child: TextWithTap(
                                _getPromoText(productDetails),
                                color: Colors.white,
                                fontSize: 9,
                                marginBottom: 3,
                                marginTop: 3,
                                marginRight: 5,
                                marginLeft: 5,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Visibility(
                              visible: product!.id == productDetails.id
                                  ? true
                                  : false,
                              child: ContainerCorner(
                                color: kTransparentColor,
                                borderColor: kTransparentColor,
                                marginLeft: 20,
                                child: SvgPicture.asset(
                                  "assets/svg/ic_floating_action_ok.svg",
                                  width: 24,
                                  height: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
          ),
        ),
      ),
    );
  }

  String _getPromoText(ProductDetails productDetails) {
    if (productDetails.id == Config.credit500) {
      return "payment_screen.in_app_popular".tr();
    } else if (productDetails.id == Config.credit1000) {
      return "payment_screen.in_app_best_value".tr();
    }
    return "";
  }

  String _getCreditText(ProductDetails productDetails) {
    if (productDetails.id == Config.credit100) {
      return "100";
    } else if (productDetails.id == Config.credit200) {
      return "200";
    } else if (productDetails.id == Config.credit500) {
      return "500";
    } else if (productDetails.id == Config.credit1000) {
      return "1000";
    } else if (productDetails.id == Config.credit2000) {
      return "2000";
    } else if (productDetails.id == Config.credit5000) {
      return "5000";
    }  else if (productDetails.id == Config.credit10000) {
      return "10000";
    }
    return "";
  }

  List<Widget> getAllowedPaymentsMethods() {
    Widget googleOrApple =
    singleTab(getGoogleOrAppleName(), getGoogleOrApple());
    Widget stripe = singleTab("payment_screen.credit_card".tr(),
        "assets/svg/ic_generic_credit_card.svg");
    Widget paypal = singleTab("payment_screen.pay_pal".tr(),
        "assets/svg/ic_generic_provider_paypal.svg");

    List<Widget> paymentsEnabled = [googleOrApple];

    if (Setup.isStripePaymentsEnabled) {
      paymentsEnabled.add(stripe);
    }
    if (Setup.isPayPalPaymentsEnabled) {
      paymentsEnabled.add(paypal);
    }
    return paymentsEnabled;
  }

  String getGoogleOrAppleName() {
    if (QuickHelp.isIOSPlatform()) {
      return "payment_screen.apple_pay".tr();
    } else if (QuickHelp.isAndroidPlatform()) {
      return "payment_screen.google_play".tr();
    }
    return "";
  }

  String getGoogleOrApple() {
    if (QuickHelp.isIOSPlatform()) {
      return "assets/svg/ic_apple_logo.svg";
    } else if (QuickHelp.isAndroidPlatform()) {
      return "assets/svg/ic_generic_provider_google_play.svg";
    }
    return "";
  }

  Widget singleTab(String text, String asset) {
    return Tab(
      iconMargin: EdgeInsets.only(bottom: 10, top: 18),
      text: text,
      icon: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      ),
    );
  }

  _updateProduct(ProductDetails productDetails) {
    setState(() {
      product = productDetails;
      print("Product selected: ${productDetails.id}");
    });
  }

  _initStripePayment(InAppPurchaseModel inAppPurchaseModel) {

    QuickActions.initPaymentMobileForm(context: context,
        inAppPurchaseModel: inAppPurchaseModel,
        currentUser: widget.currentUser!,);
  }

  _showEditPaymentAccountsBottomSheet() {
    return showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.001),
              child: GestureDetector(
                onTap: () {},
                child: DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.1,
                  maxChildSize: 1.0,
                  builder: (_, controller) {
                    return StatefulBuilder(builder: (context, setState) {
                      return Container(
                          decoration: BoxDecoration(
                            color: QuickHelp.isDarkMode(context)
                                ? kContentColorLightTheme
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                          ),
                          child: ContainerCorner(
                              color: kTransparentColor,
                              child: Column(
                                children: [
                                  Center(
                                    child: ContainerCorner(
                                      color: kGrayColor,
                                      width: 40,
                                      height: 3,
                                      marginBottom: 20,
                                      marginTop: 5,
                                    ),
                                  ),
                                  Center(
                                      child: Column(
                                        children: [
                                          TextWithTap(
                                            "get_money.payment_account".tr(),
                                            color: QuickHelp.isDarkMode(context)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          ContainerCorner(
                                            color: kTransparentColor,
                                            borderColor: kGrayColor,
                                            height: 60,
                                            borderRadius: 10,
                                            marginLeft: 20,
                                            marginRight: 20,
                                            marginTop: 40,
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      content: Column(
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/svg/Payoneer-Logo.wine.svg",
                                                            height: 70,
                                                            width: 70,
                                                          ),
                                                          TextWithTap(
                                                            "get_money.payoneer_email"
                                                                .tr(),
                                                            textAlign:
                                                            TextAlign.center,
                                                            marginTop: 20,
                                                          ),
                                                          SizedBox(
                                                            height: 25,
                                                          ),
                                                          TextField(
                                                            autocorrect: false,
                                                            keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                            maxLines: null,
                                                            controller:
                                                            payoonerEmailController,
                                                            decoration:
                                                            InputDecoration(
                                                              hintText: widget
                                                                  .currentUser!
                                                                  .getPayEmail !=
                                                                  null
                                                                  ? widget
                                                                  .currentUser!
                                                                  .getPayEmail
                                                                  : "get_money.your_email"
                                                                  .tr(),
                                                              border:
                                                              InputBorder.none,
                                                            ),
                                                          ),
                                                          Divider(
                                                            color: kGrayColor,
                                                          ),
                                                          SizedBox(
                                                            height: 35,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              ContainerCorner(
                                                                child: TextButton(
                                                                  child:
                                                                  TextWithTap(
                                                                    "cancel"
                                                                        .tr()
                                                                        .toUpperCase(),
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize: 14,
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                color: kRedColor1,
                                                                borderRadius: 10,
                                                                marginLeft: 5,
                                                                width: 125,
                                                              ),
                                                              ContainerCorner(
                                                                child: TextButton(
                                                                  child:
                                                                  TextWithTap(
                                                                    "get_money.connect_"
                                                                        .tr()
                                                                        .toUpperCase(),
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize: 14,
                                                                  ),
                                                                  onPressed: () {
                                                                    if (payoonerEmailController
                                                                        .text
                                                                        .isEmpty) {
                                                                      showDialog(
                                                                          context:
                                                                          context,
                                                                          builder:
                                                                              (BuildContext
                                                                          context) {
                                                                            return AlertDialog(
                                                                              content:
                                                                              Column(
                                                                                mainAxisSize:
                                                                                MainAxisSize.min,
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    "assets/svg/sad.svg",
                                                                                    height: 70,
                                                                                    width: 70,
                                                                                  ),
                                                                                  TextWithTap(
                                                                                    "get_money.empty_email".tr(),
                                                                                    textAlign: TextAlign.center,
                                                                                    color: Colors.red,
                                                                                    marginTop: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 35,
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      ContainerCorner(
                                                                                        child: TextButton(
                                                                                          child: TextWithTap(
                                                                                            "cancel".tr().toUpperCase(),
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop();
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                        ),
                                                                                        color: kRedColor1,
                                                                                        borderRadius: 10,
                                                                                        marginLeft: 5,
                                                                                        width: 125,
                                                                                      ),
                                                                                      ContainerCorner(
                                                                                        child: TextButton(
                                                                                          child: TextWithTap(
                                                                                            "get_money.try_again".tr().toUpperCase(),
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                          onPressed: () => Navigator.of(context).pop(),
                                                                                        ),
                                                                                        color: kGreenColor,
                                                                                        borderRadius: 10,
                                                                                        marginRight: 5,
                                                                                        width: 125,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: 20),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          });
                                                                    } else {
                                                                      checkEmailAndSave(
                                                                          payoonerEmailController
                                                                              .text,
                                                                          "payoneer");
                                                                    }
                                                                  },
                                                                ),
                                                                color: kGreenColor,
                                                                borderRadius: 10,
                                                                marginRight: 5,
                                                                width: 125,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 20),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/svg/Payoneer-Logo.wine.svg",
                                                  height: 40,
                                                  width: 40,
                                                ),
                                                TextWithTap(
                                                  widget.currentUser!.getPayEmail !=
                                                      null
                                                      ? "get_money.connected_".tr()
                                                      : "get_money.off_".tr(),
                                                  color: kGrayColor,
                                                  marginRight: 10,
                                                )
                                              ],
                                            ),
                                          ),
                                          ContainerCorner(
                                            color: kTransparentColor,
                                            borderColor: kGrayColor,
                                            height: 60,
                                            borderRadius: 10,
                                            marginLeft: 20,
                                            marginRight: 20,
                                            marginTop: 40,
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      content:
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                          MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.money,
                                                              color: Colors
                                                                  .greenAccent,
                                                            ),
                                                            TextWithTap(
                                                              "get_money.insert_iban"
                                                                  .tr(),
                                                              textAlign:
                                                              TextAlign.center,
                                                              marginTop: 20,
                                                            ),
                                                            SizedBox(
                                                              height: 25,
                                                            ),
                                                            TextField(
                                                              autocorrect: false,
                                                              keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                              maxLines: null,
                                                              controller:
                                                              accountNameTextEditingController,
                                                              decoration:
                                                              InputDecoration(
                                                                hintText: widget.currentUser!
                                                                    .getAccountName !=
                                                                    null
                                                                    ? widget
                                                                    .currentUser!
                                                                    .getAccountName
                                                                    : "get_money.type_account_name"
                                                                    .tr(),
                                                                border: InputBorder
                                                                    .none,
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: kGrayColor,
                                                            ),
                                                            TextField(
                                                              autocorrect: false,
                                                              keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                              maxLines: null,
                                                              controller:
                                                              bankNameTextEditingController,
                                                              decoration:
                                                              InputDecoration(
                                                                hintText: widget.currentUser!
                                                                    .getBankName !=
                                                                    null
                                                                    ? widget
                                                                    .currentUser!
                                                                    .getBankName
                                                                    : "get_money.type_bank_name"
                                                                    .tr(),
                                                                border: InputBorder
                                                                    .none,
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: kGrayColor,
                                                            ),
                                                            TextField(
                                                              autocorrect: false,
                                                              keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                              maxLines: null,
                                                              controller:
                                                              ibanTextEditingController,
                                                              decoration:
                                                              InputDecoration(
                                                                hintText: widget.currentUser!.getIban !=
                                                                    null
                                                                    ? widget
                                                                    .currentUser!
                                                                    .getIban
                                                                    : "get_money.type_iban"
                                                                    .tr(),
                                                                border: InputBorder
                                                                    .none,
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: kGrayColor,
                                                            ),
                                                            SizedBox(
                                                              height: 35,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                ContainerCorner(
                                                                  child: TextButton(
                                                                    child:
                                                                    TextWithTap(
                                                                      "cancel"
                                                                          .tr()
                                                                          .toUpperCase(),
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize: 14,
                                                                    ),
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                          context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                  color: kRedColor1,
                                                                  borderRadius: 10,
                                                                  marginLeft: 5,
                                                                  width: 125,
                                                                ),
                                                                ContainerCorner(
                                                                  child: TextButton(
                                                                    child:
                                                                    TextWithTap(
                                                                      "get_money.connect_"
                                                                          .tr()
                                                                          .toUpperCase(),
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize: 14,
                                                                    ),
                                                                    onPressed: () {
                                                                      if (ibanTextEditingController.text.isEmpty ||
                                                                          bankNameTextEditingController
                                                                              .text
                                                                              .isEmpty ||
                                                                          accountNameTextEditingController
                                                                              .text
                                                                              .isEmpty) {
                                                                        showDialog(
                                                                            context:
                                                                            context,
                                                                            builder:
                                                                                (BuildContext
                                                                            context) {
                                                                              return AlertDialog(
                                                                                content:
                                                                                Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    SvgPicture.asset(
                                                                                      "assets/svg/sad.svg",
                                                                                      height: 70,
                                                                                      width: 70,
                                                                                    ),
                                                                                    TextWithTap(
                                                                                      "get_money.empty_iban".tr(),
                                                                                      textAlign: TextAlign.center,
                                                                                      color: Colors.red,
                                                                                      marginTop: 20,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 35,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        ContainerCorner(
                                                                                          child: TextButton(
                                                                                            child: TextWithTap(
                                                                                              "cancel".tr().toUpperCase(),
                                                                                              color: Colors.white,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              fontSize: 14,
                                                                                            ),
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                          ),
                                                                                          color: kRedColor1,
                                                                                          borderRadius: 10,
                                                                                          marginLeft: 5,
                                                                                          width: 125,
                                                                                        ),
                                                                                        ContainerCorner(
                                                                                          child: TextButton(
                                                                                            child: TextWithTap(
                                                                                              "get_money.try_again".tr().toUpperCase(),
                                                                                              color: Colors.white,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              fontSize: 14,
                                                                                            ),
                                                                                            onPressed: () => Navigator.of(context).pop(),
                                                                                          ),
                                                                                          color: kGreenColor,
                                                                                          borderRadius: 10,
                                                                                          marginRight: 5,
                                                                                          width: 125,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 20),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            });
                                                                      } else {
                                                                        checkIbanAndSave(
                                                                            ibanTextEditingController
                                                                                .text,
                                                                            accountNameTextEditingController
                                                                                .text,
                                                                            bankNameTextEditingController
                                                                                .text);
                                                                      }
                                                                    },
                                                                  ),
                                                                  color:
                                                                  kGreenColor,
                                                                  borderRadius: 10,
                                                                  marginRight: 5,
                                                                  width: 125,
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextWithTap(
                                                  "get_money.iban_"
                                                      .tr()
                                                      .toUpperCase(),
                                                  color:
                                                  QuickHelp.isDarkMode(context)
                                                      ? Colors.white
                                                      : Colors.black,
                                                  marginRight: 20,
                                                  fontWeight: FontWeight.w700,
                                                  marginLeft: 20,
                                                  fontSize: 20,
                                                ),
                                                TextWithTap(
                                                  widget.currentUser!.getIban !=
                                                      null
                                                      ? "get_money.connected_".tr()
                                                      : "get_money.off_".tr(),
                                                  color: kGrayColor,
                                                  marginRight: 10,
                                                )
                                              ],
                                            ),
                                          ),
                                          TextWithTap(
                                            "get_money.Instructions_"
                                                .tr()
                                                .toUpperCase(),
                                            color: kPrimaryColor,
                                            marginTop: 40,
                                            onTap: () {
                                              QuickHelp.goToWebPage(context,
                                                  pageType: QuickHelp.pageTypeInstructions, pageUrl: Config.helpCenterUrl);
                                            },
                                          ),
                                        ],
                                      )),
                                ],
                              )));
                    });
                  },
                ),
              ),
            ),
          );
        });
  }

  bool _validateEmail(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  checkEmailAndSave(String email, String type) {
    if (_validateEmail(email)) {
      createPayoneerEmail(email);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/svg/sad.svg",
                    height: 70,
                    width: 70,
                  ),
                  TextWithTap(
                    "account_settings.invalid_email".tr(),
                    textAlign: TextAlign.center,
                    color: Colors.red,
                    marginTop: 20,
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "cancel".tr().toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                        color: kRedColor1,
                        borderRadius: 10,
                        marginLeft: 5,
                        width: 125,
                      ),
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "get_money.try_again".tr().toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        color: kGreenColor,
                        borderRadius: 10,
                        marginRight: 5,
                        width: 125,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          });
    }
  }

  checkIbanAndSave(String iban, String accountName, String bankName) {
    if (isValid(iban)) {
      createIban(iban, accountName, bankName);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/svg/sad.svg",
                    height: 70,
                    width: 70,
                  ),
                  TextWithTap(
                    "get_money.invalid_iban".tr(),
                    textAlign: TextAlign.center,
                    color: Colors.red,
                    marginTop: 20,
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "cancel".tr().toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                        color: kRedColor1,
                        borderRadius: 10,
                        marginLeft: 5,
                        width: 125,
                      ),
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "get_money.try_again".tr().toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        color: kGreenColor,
                        borderRadius: 10,
                        marginRight: 5,
                        width: 125,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          });
    }
  }

  void createIban(String iban, String accountName, String bankName) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setIban = iban;
    widget.currentUser!.setAccountName = accountName;
    widget.currentUser!.setBankName = bankName;

    ParseResponse response = await widget.currentUser!.save();

    if (response.success) {
      widget.currentUser = response.results!.first! as UserModel;

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "updated_".tr(),
        message: "tickets.bank_account_updated".tr(),
        isError: false,
        user: widget.currentUser,
      );

      QuickHelp.hideLoadingDialog(context);
      Navigator.of(context).pop();
      Navigator.of(context).pop();

    } else {

      QuickHelp.hideLoadingDialog(context);
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "try_again_later".tr());
    }
  }

  void createPayoneerEmail(String email) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setPayEmail = email;

    ParseResponse response = await widget.currentUser!.save();

    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "updated_".tr(),
        message: "tickets.payoneer_updated".tr(),
        isError: false,
        user: widget.currentUser,
      );

    } else {
      QuickHelp.hideLoadingDialog(context);
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "try_again_later".tr());
    }
  }

  Future<void> checkWithdraw() async {

    if(widget.currentUser!.getPhoneNumberFull!.isEmpty){

      UserModel? result = await QuickHelp.goToNavigatorScreenForResult(context, PhoneVerifyScreen(currentUser: widget.currentUser), route: PhoneVerifyScreen.route);

      if(result != null){
        widget.currentUser = result;

        QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "tickets.withdraw".tr(),
          message: "tickets.phone_number_verified".tr(),
          isError: false,
          user: widget.currentUser,
        );
      }
      return;
    }

    if (widget.currentUser!.getPayEmail != null ||
        widget.currentUser!.getIban != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/svg/ic_coin_with_star.svg",
                    height: 70,
                    width: 70,
                  ),
                  TextWithTap(
                    "get_money.how_much".tr(namedArgs: {
                      "money": totalMoney.toString()
                    }),
                    textAlign: TextAlign.center,
                    marginTop: 20,
                  ),
                  TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    maxLines: null,
                    controller: moneyToTransferController,
                    decoration: InputDecoration(
                      hintText: "get_money.transfer_".tr(),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(
                    color: kGrayColor,
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "cancel".tr().toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        color: kRedColor1,
                        borderRadius: 10,
                        marginLeft: 5,
                        width: 125,
                      ),
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "confirm_".tr().toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () {
                            if (moneyToTransferController
                                .text.isEmpty) {
                              showDialog(
                                  context: context,
                                  builder:
                                      (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svg/sad.svg",
                                            height: 70,
                                            width: 70,
                                          ),
                                          TextWithTap(
                                            "get_money.empty_field"
                                                .tr(),
                                            textAlign: TextAlign
                                                .center,
                                            color: Colors.red,
                                            marginTop: 20,
                                          ),
                                          SizedBox(
                                            height: 35,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              ContainerCorner(
                                                child:
                                                TextButton(
                                                  child:
                                                  TextWithTap(
                                                    "cancel"
                                                        .tr()
                                                        .toUpperCase(),
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize:
                                                    14,
                                                  ),
                                                  onPressed:
                                                      () {
                                                    Navigator.of(
                                                        context)
                                                        .pop();
                                                    Navigator.of(
                                                        context)
                                                        .pop();
                                                  },
                                                ),
                                                color:
                                                kRedColor1,
                                                borderRadius:
                                                10,
                                                marginLeft: 5,
                                                width: 125,
                                              ),
                                              ContainerCorner(
                                                child:
                                                TextButton(
                                                  child:
                                                  TextWithTap(
                                                    "get_money.try_again"
                                                        .tr()
                                                        .toUpperCase(),
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize:
                                                    14,
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(),
                                                ),
                                                color:
                                                kGreenColor,
                                                borderRadius:
                                                10,
                                                marginRight: 5,
                                                width: 125,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    );
                                  });
                            } else if (double.parse(
                                moneyToTransferController
                                    .text) >
                                double.parse(totalMoney!
                                    .toStringAsFixed(0))) {
                              showDialog(
                                  context: context,
                                  builder:
                                      (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svg/sad.svg",
                                            height: 70,
                                            width: 70,
                                          ),
                                          TextWithTap(
                                            "get_money.not_enough"
                                                .tr(namedArgs: {
                                              "money": totalMoney!
                                                  .toStringAsFixed(
                                                  0)
                                            }),
                                            textAlign: TextAlign
                                                .center,
                                            color: Colors.red,
                                            marginTop: 20,
                                          ),
                                          SizedBox(
                                            height: 35,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              ContainerCorner(
                                                child:
                                                TextButton(
                                                  child:
                                                  TextWithTap(
                                                    "cancel"
                                                        .tr()
                                                        .toUpperCase(),
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize:
                                                    14,
                                                  ),
                                                  onPressed:
                                                      () {
                                                    Navigator.of(
                                                        context)
                                                        .pop();
                                                    Navigator.of(
                                                        context)
                                                        .pop();
                                                  },
                                                ),
                                                color:
                                                kRedColor1,
                                                borderRadius:
                                                10,
                                                marginLeft: 5,
                                                width: 125,
                                              ),
                                              ContainerCorner(
                                                child:
                                                TextButton(
                                                  child:
                                                  TextWithTap(
                                                    "get_money.try_again"
                                                        .tr()
                                                        .toUpperCase(),
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize:
                                                    14,
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(),
                                                ),
                                                color:
                                                kGreenColor,
                                                borderRadius:
                                                10,
                                                marginRight: 5,
                                                width: 125,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    );
                                  });
                            } else if (double.parse(
                                moneyToTransferController
                                    .text) <
                                minQuantityToWithdraw!) {
                              showDialog(
                                  context: context,
                                  builder:
                                      (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svg/sad.svg",
                                            height: 70,
                                            width: 70,
                                          ),
                                          TextWithTap(
                                            "get_money.less_quantity"
                                                .tr(namedArgs: {
                                              "amount":
                                              minQuantityToWithdraw
                                                  .toString()
                                            }),
                                            textAlign: TextAlign
                                                .center,
                                            color: Colors.red,
                                            marginTop: 20,
                                          ),
                                          SizedBox(
                                            height: 35,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              ContainerCorner(
                                                child:
                                                TextButton(
                                                  child:
                                                  TextWithTap(
                                                    "cancel"
                                                        .tr()
                                                        .toUpperCase(),
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize:
                                                    14,
                                                  ),
                                                  onPressed:
                                                      () {
                                                    Navigator.of(
                                                        context)
                                                        .pop();
                                                    Navigator.of(
                                                        context)
                                                        .pop();
                                                  },
                                                ),
                                                color:
                                                kRedColor1,
                                                borderRadius:
                                                10,
                                                marginLeft: 5,
                                                width: 125,
                                              ),
                                              ContainerCorner(
                                                child:
                                                TextButton(
                                                  child:
                                                  TextWithTap(
                                                    "get_money.try_again"
                                                        .tr()
                                                        .toUpperCase(),
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize:
                                                    14,
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(),
                                                ),
                                                color:
                                                kGreenColor,
                                                borderRadius:
                                                10,
                                                marginRight: 5,
                                                marginLeft: 10,
                                                width: 125,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    );
                                  });
                            } else {
                              _showListOfPaymentsMode();
                            }
                          },
                        ),
                        color: kGreenColor,
                        borderRadius: 10,
                        marginRight: 5,
                        width: 125,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/svg/sad.svg",
                    height: 70,
                    width: 70,
                  ),
                  TextWithTap(
                    "get_money.bank_account".tr(),
                    textAlign: TextAlign.center,
                    color: Colors.red,
                    marginTop: 20,
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "cancel".tr().toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        color: kRedColor1,
                        borderRadius: 10,
                        marginLeft: 5,
                        width: 125,
                      ),
                      ContainerCorner(
                        child: TextButton(
                          child: TextWithTap(
                            "get_money.set_bank"
                                .tr()
                                .toUpperCase(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showEditPaymentAccountsBottomSheet();
                          },
                        ),
                        color: kGreenColor,
                        borderRadius: 10,
                        marginRight: 5,
                        width: 125,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          });
    }
  }

  _showListOfPaymentsMode() {
    return showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.001),
              child: GestureDetector(
                onTap: () {},
                child: DraggableScrollableSheet(
                  initialChildSize: 0.40,
                  minChildSize: 0.1,
                  maxChildSize: 1.0,
                  builder: (_, controller) {
                    return StatefulBuilder(builder: (context, setState) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0),
                          ),
                        ),
                        child: Scaffold(
                            backgroundColor: kTransparentColor,
                            appBar: AppBar(
                              backgroundColor: kTransparentColor,
                              centerTitle: true,
                              title: TextWithTap(
                                "get_money.select_payment".tr(),
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            body: Column(
                              children: [
                                if (widget.currentUser!.getPayEmail != null)
                                  ContainerCorner(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        withdrawMoney(
                                            double.parse(
                                                moneyToTransferController.text),
                                            widget.currentUser!.getPayEmail!,
                                            WithdrawModel.PAYONEER);
                                      },
                                      child: Row(
                                        children: [
                                          ContainerCorner(
                                            height: 20,
                                            width: 20,
                                            borderRadius: 50,
                                            borderColor: kRedColor1,
                                          ),
                                          SvgPicture.asset(
                                            "assets/svg/Payoneer-Logo.wine.svg",
                                            height: 50,
                                            width: 50,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (widget.currentUser!.getIban != null)
                                  ContainerCorner(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        withdrawMoney(
                                            double.parse(
                                                moneyToTransferController.text),
                                            "IBAN",
                                            WithdrawModel.IBAN);
                                      },
                                      child: Row(
                                        children: [
                                          ContainerCorner(
                                            height: 20,
                                            width: 20,
                                            borderRadius: 50,
                                            borderColor: kRedColor1,
                                          ),
                                          TextWithTap(
                                            "get_money.iban_"
                                                .tr()
                                                .toUpperCase(),
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            marginLeft: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                Visibility(
                                  visible: widget.currentUser!.getIban ==
                                      null &&
                                      widget.currentUser!.getPayEmail == null,
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/sad.svg",
                                        height: 70,
                                        width: 70,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showEditPaymentAccountsBottomSheet();
                                        },
                                        child: TextWithTap(
                                          "get_money.payment_account".tr(),
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      );
                    });
                  },
                ),
              ),
            ),
          );
        });
  }

  withdrawMoney(double money, String email, String method) async {
    QuickHelp.showLoadingDialog(context);

    int diamonds = QuickHelp.convertMoneyToDiamonds(money).toInt();

    WithdrawModel withdraw = WithdrawModel();

    withdraw.setAuthor = widget.currentUser!;
    withdraw.setStatus = WithdrawModel.PENDING;
    withdraw.setEmail = email;

    withdraw.setCompleted = false;
    withdraw.setMethod = method;
    withdraw.setDiamonds = diamonds;
    withdraw.setCredit = money;
    withdraw.setCurrency = Setup.withdrawCurrencyCode;

    if (method == WithdrawModel.IBAN) {
      withdraw.setIBAN = widget.currentUser!.getIban!;
      withdraw.setAccountName = widget.currentUser!.getAccountName!;
      withdraw.setBankName = widget.currentUser!.getBankName!;
    }

    widget.currentUser!.removeDiamonds = diamonds;
    await widget.currentUser!.save().then((value) async {
      ParseResponse response = await withdraw.save();

      if (response.success) {
        moneyToTransferController.clear();

        setState(() {
          widget.currentUser = value.results!.first! as UserModel;
        });
        QuickHelp.hideLoadingDialog(context, result: widget.currentUser);
        Navigator.of(context).pop(widget.currentUser);

        QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "tickets.withdraw".tr(),
          message: "tickets.withdraw_success".tr(namedArgs: {"account" :"${Config.primaryCurrencySymbol} $money "}),
          isError: false,
          user: widget.currentUser,
        );

      } else {

        QuickHelp.hideLoadingDialog(context, result: widget.currentUser);
        Navigator.of(context).pop(widget.currentUser);

        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr());
      }
    });
  }
}



class IOSPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {

    print("InAppPurchase: $transaction");
    return true;
  }

  @override
  bool shouldShowPriceConsent() {

    print("InAppPurchase: shouldShowPriceConsent");
    return false;
  }
}
