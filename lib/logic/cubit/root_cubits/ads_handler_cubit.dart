import 'dart:async';

import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/premium_checker_cubit.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:protasks/logic/package_info_handler.dart';

part 'ads_handler_state.dart';

class AdsHandlerCubit extends HydratedCubit<AdsHandlerStats> {
  final PremiumCheckerCubit premiumCheckerCubit;
  final LoginCubit loginCubit;

  String _freeToProRewardedAdsId = PackageInfoHandler.isDeveloperVersion
      ? RewardedAd.testAdUnitId
      : "ca-app-pub-9235113364712793/1488589023";
  String _defaultInterstitialAdsId = PackageInfoHandler.isDeveloperVersion
      ? InterstitialAd.testAdUnitId
      : "ca-app-pub-9235113364712793/2812746150";

  AdsHandlerCubit({
    required this.loginCubit,
    required this.premiumCheckerCubit,
  }) : super(AdsHandlerStats(
          adsNotShownBecausePro: 0,
          currentStep: 0,
          adsShown: 0,
        )) {
    initialize();
  }

  RewardedAd? _freeToProRewardedAd;
  InterstitialAd? _defaultInterstitialAd;

  StreamSubscription? _loginCubitStreamSubscription;

  // CancelableOperation? _cancelableOperation;

  StreamSubscription? _internetStreamSubscription;

  InternetConnectionChecker _internetConnectionChecker =
      InternetConnectionChecker()..checkInterval = Duration(seconds: 2);

  Future<bool> createAds() async {
    if (_freeToProRewardedAd == null || _defaultInterstitialAd == null) {
      if (await _internetConnectionChecker.connectionStatus ==
          InternetConnectionStatus.connected) {
        _internetStreamSubscription?.cancel();
        _createFreeToProRewardedAds();
        _createDefaultInterstitialAds();
        return true;
      }
      await _internetConnectionChecker.onStatusChange
          .distinct((previous, next) {
        return next != InternetConnectionStatus.connected;
      }).first;
      _createFreeToProRewardedAds();
      _createDefaultInterstitialAds();
      return true;
    }
    return true;
  }

  bool functionAlreadyActive = false; // Kind of a lock

  void performActionBasedOnLoginState() async {
    if (functionAlreadyActive) {
      return;
    }
    CurrentLoginState _currentLoginState = loginCubit.state.currentLoginState;
    if (_currentLoginState == CurrentLoginState.loggedIn) {
      if (_freeToProRewardedAd == null || _defaultInterstitialAd == null) {
        functionAlreadyActive = true;
        await createAds();
        functionAlreadyActive = false;

        // _cancelableOperation?.cancel();

        // _cancelableOperation = CancelableOperation.fromFuture(
        //   Future.delayed(
        //     Duration(seconds: 15),
        //   ),
        // );

        // _cancelableOperation?.value.then((_) {
        //   performActionBasedOnLoginState();
        // });
      } else {
        // showFreeToProRewardedAd();
        showDefaultInterstitialAd();
      }
    } else {
      emit(AdsHandlerStats(
        adsNotShownBecausePro: 0,
        currentStep: 0,
        adsShown: 0,
      ));
    }
  }

  void initialize() {
    _loginCubitStreamSubscription = loginCubit.stream.listen((loginCubitState) {
      performActionBasedOnLoginState();
    });
    performActionBasedOnLoginState();
    // _premiumCubitStreamSubscription =
    //     premiumCheckerCubit.stream.listen((premiumCheckerState) {
    //       if(premiumCheckerState.currentPremiumState == CurrentPremiumState.freeUser){

    //       }
    //     });
  }

  void showDefaultInterstitialAd() {
    print("showDefaultInterstitialAd");
    if (premiumCheckerCubit.state.currentPremiumState ==
        CurrentPremiumState.pseudoProUser) {
      emit(
        AdsHandlerStats(
          adsNotShownBecausePro: state.adsNotShownBecausePro + 1,
          currentStep: state.currentStep,
          adsShown: state.adsShown,
        ),
      );
    } else {
      if (_defaultInterstitialAd == null) {
        print('Warning: attempt to show rewarded before loaded.');
        return;
      }
      _defaultInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          emit(AdsHandlerStats(
            adsNotShownBecausePro: state.adsNotShownBecausePro,
            currentStep: state.currentStep,
            adsShown: state.adsShown + 1,
          ));
          print('ad onAdShowedFullScreenContent.');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          performActionBasedOnLoginState();
          // _createDefaultInterstitialAds();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          performActionBasedOnLoginState();
          // _createDefaultInterstitialAds();
        },
      );
      _defaultInterstitialAd!.show();
      _defaultInterstitialAd = null;
    }
  }

  void showFreeToProRewardedAd() {
    if (premiumCheckerCubit.state.currentPremiumState ==
        CurrentPremiumState.pseudoProUser) {
      emit(
        AdsHandlerStats(
          adsNotShownBecausePro: state.adsNotShownBecausePro + 1,
          currentStep: 0,
          adsShown: state.adsShown,
        ),
      );
    } else {
      if (_freeToProRewardedAd == null) {
        print('Warning: attempt to show rewarded before loaded.');
        return;
      }
      _freeToProRewardedAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {
          emit(AdsHandlerStats(
            adsNotShownBecausePro: state.adsNotShownBecausePro,
            currentStep: state.currentStep,
            adsShown: state.adsShown + 1,
          ));
          print('ad onAdShowedFullScreenContent.');
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          _createFreeToProRewardedAds();
          // _createDefaultInterstitialAds();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _createFreeToProRewardedAds();
        },
      );

      _freeToProRewardedAd!.show(
        onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
          print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
          if (state.currentStep + 1 >= FirebaseRConfigHandler.freeToProAds) {
            premiumCheckerCubit.changeState(toPremium: true);
            emit(AdsHandlerStats(
              adsNotShownBecausePro: state.adsNotShownBecausePro,
              currentStep: 0,
              adsShown: state.adsShown,
            ));
          } else {
            emit(AdsHandlerStats(
              adsNotShownBecausePro: state.adsNotShownBecausePro,
              currentStep: state.currentStep + 1,
              adsShown: state.adsShown,
            ));
          }
        },
      );
      _freeToProRewardedAd = null;
    }
  }

  void checkAndMakePro() {
    if (state.currentStep >= FirebaseRConfigHandler.freeToProAds) {
      premiumCheckerCubit.changeState(
        toPremium: true,
      );
    }
  }

  void _createFreeToProRewardedAds() {
    print("_createFreeToProRewardedAds called");
    if (_freeToProRewardedAd == null) {
      RewardedAd.load(
        adUnitId: _freeToProRewardedAdsId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _freeToProRewardedAd = ad;
          },
          onAdFailedToLoad: (error) {
            print("RewardedAd onAdFailedToLoad: $error");
          },
        ),
      );
    }
  }

  void _createDefaultInterstitialAds() {
    print("_createDefaultInterstitialAds called");
    if (_defaultInterstitialAd == null) {
      InterstitialAd.load(
        adUnitId: _defaultInterstitialAdsId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print("_defaultInterstitialAd instantiated");
            _defaultInterstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            print("InterstitialAd onAdFailedToLoad: $error");
          },
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _loginCubitStreamSubscription?.cancel();
    return super.close();
  }

  @override
  AdsHandlerStats? fromJson(Map<String, dynamic> json) {
    return AdsHandlerStats.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(AdsHandlerStats state) {
    return state.toMap();
  }
}
