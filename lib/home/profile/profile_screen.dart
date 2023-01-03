import 'package:flutter/services.dart';
import 'package:heyto/app/config.dart';
import 'package:heyto/app/setup.dart';
import 'package:heyto/helpers/quick_actions.dart';
import 'package:heyto/helpers/quick_help.dart';
import 'package:heyto/helpers/responsive.dart';
import 'package:heyto/home/profile/edit_profile_screen.dart';
import 'package:heyto/home/profile/profile_details_screen.dart';
import 'package:heyto/home/settings/settings_screen.dart';
import 'package:heyto/home/tickets/tickets_screen.dart';
import 'package:heyto/models/UserModel.dart';
import 'package:heyto/ui/app_bar_center_logo.dart';
import 'package:heyto/ui/button_with_gradient.dart';
import 'package:heyto/ui/container_with_corner.dart';
import 'package:heyto/ui/text_with_tap.dart';
import 'package:heyto/app/colors.dart';
import 'package:heyto/utils/sizeConstant.dart';
import 'package:heyto/widgets/need_resume.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../app/constants.dart';
import '../../auth/welcome_screen.dart';
import '../../services/dynamic_link_service.dart';
import '../settings/delete_account_screen.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  static String route = '/home/profile';

  UserModel? currentUser;

  ProfileScreen({this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ResumableState<ProfileScreen> {
  DynamicLinkService _dynamicLinkService = DynamicLinkService();

  @override
  void initState() {
    verifyUserFilledDatas();
    super.initState();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onPause() {
    super.onPause();
  }

  String getBirthDay(UserModel currentUser) {
    if (currentUser.getBirthday != null) {
      return ", ${QuickHelp.getAgeFromDate(currentUser.getBirthday!)}";
    } else {
      return "";
    }
  }

  List userInformations = [];

  List userInformationsNeeded = [
    "avater1",
    "avater2",
    "avater3",
    "avater4",
    "avater5",
    "avater6",
    "bank_name",
    "iban",
    "payyooner_email",
    "bio",
    // "gender",
    // "role",
    "about",
    "age",
    "job",
    // "company",
    // "school",
    "living",
    "account_name",
    "birthday"
  ];

  verifyUserFilledDatas() {
    if (widget.currentUser!.getAvatar1 != null) {
      userInformations.add("avater1");
    }
    if (widget.currentUser!.getAvatar2 != null) {
      userInformations.add("avater2");
    }
    if (widget.currentUser!.getAvatar3 != null) {
      userInformations.add("avater3");
    }
    if (widget.currentUser!.getAvatar4 != null) {
      userInformations.add("avater4");
    }
    if (widget.currentUser!.getAvatar5 != null) {
      userInformations.add("avater5");
    }
    if (widget.currentUser!.getAvatar6 != null) {
      userInformations.add("avater6");
    }
    if (widget.currentUser!.getBankName != null) {
      userInformations.add("bank_name");
    }
    if (widget.currentUser!.getAccountName != null) {
      userInformations.add("account_name");
    }
    if (widget.currentUser!.getIban != null) {
      userInformations.add("iban");
    }
    if (widget.currentUser!.getPayEmail != null) {
      userInformations.add("payyooner_email");
    }
    if (widget.currentUser!.getBio != "welcome_bio".tr()) {
      userInformations.add("bio");
    }
    if (widget.currentUser!.getGender != null) {
      userInformations.add("gender");
    }
    if (widget.currentUser!.getUserRole != null) {
      userInformations.add("role");
    }
    if (widget.currentUser!.getAboutYou != null &&
        widget.currentUser!.getAboutYou != "welcome_bio".tr()) {
      userInformations.add("about");
    }
    if (widget.currentUser!.getAge != null) {
      userInformations.add("age");
    }
    if (widget.currentUser!.getJobTitle != null) {
      userInformations.add("job");
    }
    if (widget.currentUser!.getCompanyName != null) {
      userInformations.add("company");
    }
    if (widget.currentUser!.getSchool != null) {
      userInformations.add("school");
    }
    if (widget.currentUser!.getLiving != null) {
      userInformations.add("living");
    }
    if (widget.currentUser!.getLiving != null) {
      userInformations.add("living");
    }
    if (widget.currentUser!.getBirthday != null) {
      userInformations.add("birthday");
    }
  }

  @override
  Widget build(BuildContext context) {
    QuickHelp.setWebPageTitle(context, "page_title.profile_title".tr());
    print("Dados ${userInformations.length.toDouble()}");
    print("Dados Geral ${userInformationsNeeded.length.toDouble()}");

    return ToolBarCenterLogo(
      logoName: 'ic_logo.png',
      isShowLeading: false,

      logoWidth: 80,
      iconHeight: 24,
      iconWidth: 24,
      // leftIconColor: QuickHelp.getColorToolbarIcons(),
      rightIconColor: QuickHelp.getColorToolbarIcons(),
      // leftButtonAsset: "ic_nav_profile_settings.svg",
      rightButtonAsset: "ic_nav_edit_profile.svg",
      // leftButtonPress: () {
      //   QuickHelp.goToNavigatorScreen(
      //       context,
      //       SettingsScreen(
      //         currentUser: widget.currentUser!,
      //       ),
      //       route: SettingsScreen.route);
      // },
      rightButtonPress: () async {
        UserModel? userModel = await QuickHelp.goToNavigatorScreenForResult(
            context,
            EditProfileScreen(
              currentUser: widget.currentUser,
            ),
            route: EditProfileScreen.route);

        if (userModel != null) {
          setState(() {
            widget.currentUser = userModel;
          });
        }
      },

      child: SafeArea(
          child:
              SingleChildScrollView(child: profileWidget(widget.currentUser!))),
    );
  }

  String percentageModifier(double value) {
    final roundedValue = value.ceil().toInt().toString();
    return '$roundedValue %';
  }

  double percent = 0.0;

  Widget profileWidget(UserModel currentUser) {
    final slider = SleekCircularSlider(
      min: 0,
      max: userInformationsNeeded.length.toDouble(),
      initialValue: userInformations.length.toDouble(),
      appearance: CircularSliderAppearance(
        customWidths: CustomSliderWidths(
          progressBarWidth: 5.0,
        ),
        spinnerMode: false,
        startAngle: 100.0,
        angleRange: 360.0,
        size: 175.0,
        customColors: CustomSliderColors(
          trackColor: kPhotosGrayColor,
          hideShadow: true,
          progressBarColors: [kSecondaryColor, kPrimaryColor],
        ),
      ),
      innerWidget: (value) {
        return ContainerCorner(
          //height: 100,
          marginTop: 150,
          marginLeft: 70,
          marginRight: 70,
          borderRadius: 10,
          colors: [kSecondaryColor, kPrimaryColor],
          child: Center(
            child: TextWithTap(
              percentageModifier((userInformations.length * 100) /
                  userInformationsNeeded.length),
              color: Colors.white,
            ),
          ),
        );
      },
    );
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                // onTap: () => QuickHelp.goToNavigatorScreen(
                //     context,
                //     ProfileDetailsScreen(
                //       currentUser: currentUser,
                //     ),
                //     route: ProfileDetailsScreen.route),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      margin: EdgeInsets.only(
                          top: 10, bottom: 10, left: 30, right: 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: QuickActions.avatarWidget(currentUser),
                    ),
                    slider,
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${currentUser.getFullName!}",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "${getBirthDay(currentUser)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ContainerCorner(
          //   onTap: () {
          //     if (Setup.isPaymentsDisabledOnWeb) return;
          //     QuickHelp.goToNavigatorScreen(
          //         context,
          //         TicketsScreen(
          //           currentUser: widget.currentUser,
          //         ),
          //         route: TicketsScreen.route);
          //   },
          //   borderRadius: 10.0,
          //   colors: [
          //     kProfileStarsColorPrimary,
          //     kProfileStarsColorSecondary,
          //   ],
          //   height: 72,
          //   marginLeft: 10.0,
          //   marginRight: 10.0,
          //   width: Responsive.isTablet(context) ||
          //           Responsive.isWebOrDeskTop(context)
          //       ? 400
          //       : null,
          //   child: Column(
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Container(
          //             width: 67,
          //             height: 25,
          //             margin: EdgeInsets.only(top: 12),
          //             alignment: Alignment.topCenter,
          //             child: Image.asset("assets/images/ic_logo.png"),
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Padding(
          //             padding: EdgeInsets.only(
          //               top: 10,
          //             ),
          //             child: Text(
          //               "profile_tab.profile_stars",
          //               style: TextStyle(
          //                 fontSize: 15,
          //                 color: kWarninngColor,
          //               ),
          //             ).tr(),
          //           )
          //         ],
          //       ),
          //       Padding(
          //         padding: EdgeInsets.only(top: 10.0),
          //         child: Text(
          //           "profile_tab.unli_like_more",
          //           style: TextStyle(fontSize: 12, color: Colors.white),
          //         ).tr(),
          //       )
          //     ],
          //   ),
          // ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     SvgPicture.asset(
          //       "assets/svg/add.svg",
          //       color: QuickHelp.getColorStandard(),
          //     ),
          //     ContainerCorner(
          //       marginTop: 10,
          //       marginBottom: 10,
          //       child: RichText(
          //           textAlign: TextAlign.center,
          //           text: TextSpan(children: [
          //             TextSpan(
          //               style: TextStyle(
          //                 fontSize: 14,
          //                 color: QuickHelp.getColorStandard(),
          //               ),
          //               text: "profile_tab.by_adding_f".tr(),
          //             ),
          //             TextSpan(
          //               style: TextStyle(
          //                   color: QuickHelp.getColorStandard(),
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.bold),
          //               text: "profile_tab.earn_tickets_amount".tr(namedArgs: {
          //                 "tickets": Setup.freeTicketsToInvite.toString()
          //               }),
          //             )
          //           ])),
          //     ),
          //     ContainerCorner(
          //       borderRadius: 10,
          //       height: 35,
          //       marginBottom: 10,
          //       marginLeft: 30,
          //       marginRight: 30,
          //       width: Responsive.isTablet(context) ||
          //               Responsive.isWebOrDeskTop(context)
          //           ? 400
          //           : null,
          //       color: kDisabledColor,
          //       child: Row(
          //         children: [
          //           ButtonWithGradient(
          //             marginRight: 3,
          //             onTap: createLink,
          //             height: 35,
          //             activeBoxShadow: false,
          //             text: widget.currentUser!.getInviteUrl != null
          //                 ? "copy_".tr()
          //                 : "show_".tr(),
          //             topLeftBorder: 10.0,
          //             bottomLeftBorder: 10.0,
          //             width: 70,
          //             fontWeight: FontWeight.w700,
          //             fontSize: 13,
          //             beginColor: kPrimaryColor,
          //             endColor: kSecondaryColor,
          //           ),
          //           Flexible(
          //             child: Text(
          //               widget.currentUser!.getInviteUrl != null
          //                   ? widget.currentUser!.getInviteUrl!
          //                   : "profile_screen.invite_url_hidden".tr(),
          //               style: TextStyle(
          //                 color: kDisabledGrayColor,
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info("assets/svg/sex.svg",
                    QuickHelp.getSexualityListWithName(widget.currentUser!)),
                info(
                    "assets/svg/country.svg", widget.currentUser!.getLocation!),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    "edit_profile.about_".tr(),
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 10, right: 8),
                  child: Text(
                    widget.currentUser!.getAboutYou!,
                    style: TextStyle(
                      color: kDisabledGrayColor,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                if (!isNullEmptyOrFalse(widget.currentUser!.getPassions) &&
                    widget.currentUser!.getPassions![0] != "none") ...[
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      "edit_profile.passions_section".tr(),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                    ),
                    child: passionsStepWidget(),
                  ),
                ],
              ],
            ),
          ),
          Spacing.height(75),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ButtonWithGradient(
                  marginLeft: 5,
                  marginRight: 5,
                  beginColor: kRedColor1,
                  endColor: kRedColor1,
                  text: 'logout'.tr(),
                  fontSize: 14,
                  borderRadius: 10,
                  setShadowToBottom: true,
                  shadowColor: kRedColor1,
                  blurRadius: 5,
                  spreadRadius: 1,
                  activeBoxShadow: true,
                  shadowColorOpacity: 0.2,
                  textColor: Colors.white,
                  onTap: () => showAlert(),
                ),
              ),
              Expanded(
                child: ButtonWithGradient(
                  marginLeft: 5,
                  marginRight: 5,
                  beginColor: Colors.white,
                  endColor: Colors.white,
                  setShadowToBottom: true,
                  shadowColor: kGreyColor1,
                  blurRadius: 5,
                  spreadRadius: 1,
                  activeBoxShadow: true,
                  shadowColorOpacity: 0.4,
                  text: "settings.delete_acc".tr(),
                  fontSize: 14,
                  borderRadius: 10,
                  textColor: Colors.red,
                  onTap: () => QuickHelp.goToNavigatorScreen(
                      context,
                      DeleteAccountScreen(
                        currentUser: widget.currentUser,
                      ),
                      route: DeleteAccountScreen.route),
                  marginTop: 15,
                  marginBottom: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding info(String icon, String text) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 7,
          ),
          SizedBox(width: 15, height: 15, child: SvgPicture.asset(icon)),
          SizedBox(
            width: 7,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF879099),
            ),
          ),
        ],
      ),
    );
  }

  Widget passionsStepWidget() {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: SingleChildScrollView(
        //controller: _scrollController,
        child: Wrap(
          spacing: 10.0, // gap between adjacent chips
          runSpacing: 10.0,
          alignment: WrapAlignment.start,
          //crossAxisAlignment: WrapCrossAlignment.center,
          children:
              List.generate(widget.currentUser!.getPassions!.length, (index) {
            return ContainerCorner(
              borderRadius: 70,
              height: 32,
              colors: [kPrimaryColor, kSecondaryColor],
              borderColor: kPrimaryColor,
              borderWidth: 1,
              child: Padding(
                padding: EdgeInsets.only(top: 6),
                child: TextWithTap(
                    QuickHelp.getPassions(
                        widget.currentUser!.getPassions![index]),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    marginLeft: 14,
                    marginRight: 14,
                    textAlign: TextAlign.center,
                    color: Colors.white),
              ),
            );
          }),
        ),
      ),
    );
  }

  showAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: Responsive.isMobile(context) ? null : 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      child: SvgPicture.asset(
                        "assets/svg/sad.svg",
                        color: kPhotosGrayColorReverse,
                      ),
                    ),
                  ),
                  Text(
                    "logout_acc_ask".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  ButtonWithGradient(
                    borderRadius: 100,
                    text: "logout".tr(),
                    marginLeft: 15,
                    marginRight: 15,
                    height: 50,
                    beginColor: kRedColor1,
                    endColor: kRedColor1,
                    onTap: () => doUserLogout(widget.currentUser),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
  }

  void doUserLogout(UserModel? userModel) async {
    QuickHelp.showLoadingDialog(context);

    userModel!.unset("installation");
    await userModel.save();
    widget.currentUser!.setOnlineStatus = false;
    var parseResponse = await widget.currentUser!.save();
    ParseResponse response = await userModel.logout(deleteLocalUserData: true);
    if (response.success) {
      QuickHelp.initInstallation(null, null);
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.goToNavigatorScreen(context, WelcomeScreen(),
          finish: true, back: false, route: WelcomeScreen.route);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotification(
          context: context, title: response.error!.message);
    }
  }

  createLink() async {
    if (QuickHelp.isWebPlatform()) {
      if (widget.currentUser!.getInviteUrl == null) {
        QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "profile_screen.dynamic_title_err".tr(),
          message: "profile_screen.dynamic_need_mobile".tr(),
          isError: null,
        );
      } else {
        Clipboard.setData(
          ClipboardData(
            text: widget.currentUser!.getInviteUrl,
          ),
        );
        QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "profile_screen.dynamic_title_copied".tr(),
          message: widget.currentUser!.getInviteUrl,
          isError: false,
        );
      }
    } else {
      QuickHelp.showLoadingDialog(context);

      Uri? uri = await _dynamicLinkService
          .createDynamicLink(widget.currentUser!.objectId);

      if (uri != null) {
        QuickHelp.hideLoadingDialog(context);
        Share.share(
            'profile.link_invite'.tr(
                namedArgs: {"link": uri.toString(), "app_name": Setup.appName}),
            subject: 'profile.download_invite'
                .tr(namedArgs: {"app_name": Setup.appName}));

        widget.currentUser!.setInviteUrl = uri.toString();
        ParseResponse parseResponse = await widget.currentUser!.save();

        if (parseResponse.success) {
          widget.currentUser = parseResponse.results!.first! as UserModel;

          setState(() {});
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "profile.app_could_not_gen_uri".tr(),
            user: widget.currentUser);
      }
    }
  }
}
