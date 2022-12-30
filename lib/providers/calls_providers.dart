import 'dart:async';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:heyto/app/config.dart';
import 'package:heyto/app/navigation_service.dart';
import 'package:heyto/helpers/quick_help.dart';
import 'package:heyto/home/calls/incomming_call_screen.dart';
import 'package:heyto/models/UserModel.dart';

import '../home/calls/video_call_screen.dart';
import '../home/calls/voice_call_screen.dart';

class CallsProvider extends ChangeNotifier {
  AgoraRtmClient? _client;
  AgoraRtmLocalInvitation? invitation;
  bool _isLogin = false;
  //BuildContext? _context;
  UserModel? _currentUser;
  bool isCallCanceled = false;
  bool isCallRinging = false;
  bool isCallRefused = false;
  bool isCallReceived = false;
  bool isStreamingOn = false;
  bool isCallRunning = false;
  Timer? countdownTimer;
  Duration myDuration = Duration(seconds: 30);

  int c = 0;

  AgoraRtmClient? getAgoraRtmClient() {
    if (_client != null) {
      _createClient();
    }

    return _client;
  }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      c = timer.tick;
      if (c == 30) {
        cancelTimer();
      }
    });
  }

  // Step 4
  void stopTimer() {
    countdownTimer!.cancel();
  }

  // Step 5
  void resetTimer() {
    stopTimer();
    myDuration = Duration(seconds: 30);
  }

  // Step 6
  void setCountDown() {
    final reduceSecondsBy = 1;
  }

  cancelTimer({bool isFromDismiss = false}) {
    if (!isFromDismiss) {
      Get.back();
    }
    countdownTimer!.cancel();
  }

  setCallRefused(bool callRefused) {
    isCallRefused = callRefused;
    //notifyListeners();
  }

  setCanceled(bool callCanceled) {
    isCallCanceled = callCanceled;
    //notifyListeners();
  }

  setCallAccepted(bool isCallReceived1) {
    isCallReceived = isCallReceived1;
    notifyListeners();
  }

  setCallRunning(bool isCallRun) {
    isCallRunning = isCallRun;
    notifyListeners();
  }

  setStreamingOn(bool isStreamed) {
    isStreamingOn = isStreamed;
    notifyListeners();
  }

  bool isAgoraUserLogged(UserModel? user) {
    _currentUser = user;

    if (!_isLogin) {
      _toggleLogin(user!);
    }
    return _isLogin;
  }

  void connectAgoraRtm() {
    _createClient();
  }

  void loginAgoraUser(UserModel? user) {
    _currentUser = user;

    _toggleLogin(user!);
  }

  void _createClient() async {
    _client = await AgoraRtmClient.createInstance(Config.agoraAppId);
    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _log("Peer msg: " + peerId + ", msg: " + (message.text));
    };
    _client?.onConnectionStateChanged = (int state, int reason) {
      _log('Connection state changed: ' +
          state.toString() +
          ', reason: ' +
          reason.toString());
      if (state == 5) {
        _client?.logout();
        _log('Logout.');
        _isLogin = false;
        notifyListeners();
      }
    };

    _client?.onLocalInvitationReceivedByPeer =
        (AgoraRtmLocalInvitation invite) {
      _log(
          'Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}');
      isCallRinging = true;
      //isCallRefused = false;
      //isCallCanceled = false;
      notifyListeners();
    };

    // Call MAKER

    _client?.onLocalInvitationRefused = (AgoraRtmLocalInvitation invite) {
      _log(
          'Local invitation Refused by peer: ${invite.calleeId}, content: ${invite.content}');
      isCallRefused = true;
      notifyListeners();
    };

    _client?.onLocalInvitationCanceled = (AgoraRtmLocalInvitation invite) {
      _log(
          'Local invitation Canceled by peer calle: ${invite.calleeId}, content: ${invite.content}');
      //isCallRefused = true;
      notifyListeners();
    };

    _client?.onLocalInvitationFailure =
        (AgoraRtmLocalInvitation invite, int error) {
      _log(
          'Local invitation Failure by peer: ${invite.calleeId}, content: ${invite.content}');
      //isCallRefused = true;
      //notifyListeners();
    };

    // Call RECEIVER

    _client?.onRemoteInvitationReceivedByPeer =
        (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation received by peer: ${invite.callerId}, content: ${invite.content}');
      // isCallReceived = true;
      initCallScreen(invite);
    };

    _client?.onRemoteInvitationCanceled = (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation Canceled by peer caller: ${invite.callerId}, content: ${invite.content}');
      isCallCanceled = true;
      if (isStreamingOn || isCallRunning) {
        cancelTimer();
      }

      notifyListeners();
    };
    _client?.onRemoteInvitationAccepted = (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation Canceled by peer caller: ${invite.callerId}, content: ${invite.content}');
      // isCallCanceled = true;
      notifyListeners();
    };

    _client?.onRemoteInvitationRefused = (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation Refused by peer: ${invite.callerId}, content: ${invite.content}');
      //isCallRefused = true;
      //notifyListeners();
    };

    _client?.onRemoteInvitationFailure =
        (AgoraRtmRemoteInvitation invite, int error) {
      _log(
          'Remote invitation Failure by peer: ${invite.callerId}, content: ${invite.content}');
      //isCallRefused = true;
      //notifyListeners();
    };
  }

  void _toggleLogin(UserModel? userModel) async {
    if (_isLogin) {
      try {
        await _client?.logout();
        _log('Logout success.');

        _isLogin = false;
        notifyListeners();
      } catch (errorCode) {
        _log('Logout error: ' + errorCode.toString());
      }
    } else {
      if (userModel!.objectId!.isEmpty) {
        _log('Please input your user id to login.');
        return;
      }

      try {
        await _client?.login(null, userModel.objectId!);
        _log('Login success: ' + userModel.objectId!);

        _isLogin = true;
        notifyListeners();
      } catch (errorCode) {
        _log('Login error: ' + errorCode.toString());
      }
    }
  }

  // Make call to other user
  void callUserInvitation(
      {required String calleeId,
      required String channel,
      required bool isVideo}) async {
    //isCallRinging = false;
    //isCallRefused = false;
    //isCallCanceled = false;

    try {
      invitation = AgoraRtmLocalInvitation(calleeId,
          content: isVideo ? "video" : "voice", channelId: channel);
      _log(invitation!.content ?? '');
      await _client?.sendLocalInvitation(invitation!.toJson());
      _log('Send local invitation success.');
      //notifyListeners();
    } catch (errorCode) {
      _log('Send local invitation error: ' + errorCode.toString());
    }
  }

  // Cancel call made to other user before pickup
  void cancelCallInvitation() {
    if (_client != null && invitation != null) {
      _client?.cancelLocalInvitation(invitation!.toJson());
    } else {
      _log("cancelCallInvitation _client null");
    }
  }

  // Accept a call invitation.
  void answerCall(final AgoraRtmRemoteInvitation invitation) {
    if (_client != null) {
      _client?.acceptRemoteInvitation(invitation.toJson());
    } else {
      _log("acceptRemoteInvitation _client null");
    }
  }

  // Refuse a call invitation.
  void refuseRemoteInvitation(AgoraRtmRemoteInvitation invitation) {
    if (_client != null) {
      _client?.refuseRemoteInvitation(invitation.toJson());
    } else {
      _log("refuseRemoteInvitation _client null");
    }
  }

  initCallScreen(AgoraRtmRemoteInvitation agoraRtmRemoteInvitation) async {
    isCallCanceled = false;
    print("Status of calling:==> $isCallRunning");

    QueryBuilder<UserModel> queryUser =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryUser.whereEqualTo(
        UserModel.keyObjectId, agoraRtmRemoteInvitation.callerId);

    ParseResponse parseResponse = await queryUser.query();
    if (parseResponse.success && parseResponse.results != null) {
      UserModel mUser = parseResponse.results!.first! as UserModel;
      if (isCallRunning) {
        startTimer();
        QuickHelp.showDialogWithButton(
            context: Get.context!,
            title: "Call",
            buttonText: 'live_streaming.finish_live'.tr(),
            buttonText1: 'No',
            message:
                'You got a call from ${mUser.getFullName}.  Do you want to Quit running call?',
            onPressed: () {
              // countdownTimer!.cancel();
              setCallAccepted(true);
              cancelTimer();
              // QuickHelp.goBackToPreviousPage(Get.context!);

              // answerCall(agoraRtmRemoteInvitation);
              // // await Future.delayed(Duration(seconds: 5));
              // if (agoraRtmRemoteInvitation.content! == "video") {
              //   QuickHelp.goToNavigatorScreen(
              //       NavigationService.navigatorKey.currentContext!,
              //       VideoCallScreen(
              //         mUser: mUser,
              //         currentUser: _currentUser,
              //         channel: agoraRtmRemoteInvitation.channelId!,
              //         isCaller: false,
              //       ),
              //       finish: true,
              //       back: false,
              //       fromCalling: true,
              //       route: VideoCallScreen.route);
              //   // Get.back();
              // } else {
              //   QuickHelp.goToNavigatorScreen(
              //       NavigationService.navigatorKey.currentContext!,
              //       VoiceCallScreen(
              //         mUser: mUser,
              //         currentUser: _currentUser,
              //         channel: agoraRtmRemoteInvitation.channelId!,
              //         isCaller: false,
              //       ),
              //       finish: true,
              //       back: false,
              //       fromCalling: true,
              //       route: VoiceCallScreen.route);
              // }

              QuickHelp.goToNavigatorScreen(
                NavigationService.navigatorKey.currentContext!,
                IncomingCallScreen(
                  mUser: mUser,
                  isFromOtherCall: true,
                  currentUser: _currentUser,
                  channel: agoraRtmRemoteInvitation.channelId!,
                  isVideoCall: agoraRtmRemoteInvitation.content! == "video"
                      ? true
                      : false,
                  agoraRtmRemoteInvitation: agoraRtmRemoteInvitation,
                ),
                route: IncomingCallScreen.route,
                back: true,
                finish: true,
                fromCalling: true,
              );
            },
            onPressed1: () {
              // cancelTimer();
              // QuickHelp.goBackToPreviousPage(Get.context!);
              cancelTimer(isFromDismiss: true);
              refuseRemoteInvitation(agoraRtmRemoteInvitation);
              cancelCallInvitation();
            });
      } else if (isStreamingOn) {
        startTimer();
        // Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
        var a = await QuickHelp.showDialogWithButton(
            context: Get.context!,
            title: "Call",
            buttonText: 'live_streaming.finish_live'.tr(),
            buttonText1: 'No',
            message:
                'You got a call from ${mUser.getFullName}.  Do you want to Quit Streaming?',
            onPressed: () {
              // countdownTimer!.cancel();
              setCallAccepted(true);
              setStreamingOn(false);
              cancelTimer();
              // QuickHelp.goBackToPreviousPage(Get.context!);
              QuickHelp.goToNavigatorScreen(
                  NavigationService.navigatorKey.currentContext!,
                  IncomingCallScreen(
                    mUser: mUser,
                    currentUser: _currentUser,
                    channel: agoraRtmRemoteInvitation.channelId!,
                    isVideoCall: agoraRtmRemoteInvitation.content! == "video"
                        ? true
                        : false,
                    agoraRtmRemoteInvitation: agoraRtmRemoteInvitation,
                  ),
                  route: IncomingCallScreen.route,
                  back: true,
                  finish: true,
                  fromCalling: true);
            },
            onPressed1: () {
              // cancelTimer();
              // QuickHelp.goBackToPreviousPage(Get.context!);
              cancelTimer(isFromDismiss: true);
              refuseRemoteInvitation(agoraRtmRemoteInvitation);
              cancelCallInvitation();
            });
        // if (countdownTimer!.) {
        //   cancelTimer(isFromDismiss: true);
        // }
      } else {
        QuickHelp.goToNavigatorScreen(
          NavigationService.navigatorKey.currentContext!,
          IncomingCallScreen(
            mUser: mUser,
            currentUser: _currentUser,
            channel: agoraRtmRemoteInvitation.channelId!,
            isVideoCall:
                agoraRtmRemoteInvitation.content! == "video" ? true : false,
            agoraRtmRemoteInvitation: agoraRtmRemoteInvitation,
          ),
          route: IncomingCallScreen.route,
        );
      }
    } else {
      _log("parseResponse error");
    }
  }

  _log(String string) {
    print("AgoraCall " + string);
  }
}
