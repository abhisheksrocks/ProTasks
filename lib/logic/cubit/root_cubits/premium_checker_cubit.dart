import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'premium_checker_state.dart';

class PremiumCheckerCubit extends HydratedCubit<PremiumCheckerState> {
  PremiumCheckerCubit({
    required this.loginCubit,
  }) : super(PremiumCheckerState(
          currentPremiumState: CurrentPremiumState.freeUser,
          premiumTill: DateTimeExtensions.invalid,
        )) {
    initialize();
  }

  void changeBack() {
    if (state.currentPremiumState != CurrentPremiumState.freeUser) {
      _premiumToFreeCancelableOperation?.cancel();
      _premiumToFreeCancelableOperation = CancelableOperation.fromFuture(
        Future.delayed(state.premiumTill.difference(DateTime.now())),
      );
      _premiumToFreeCancelableOperation?.value.then((_) {
        Fluttertoast.showToast(msg: "Your premium membership ended");
        changeState(toPremium: false);
      });
    }
  }

  final LoginCubit loginCubit;

  CancelableOperation? _nextUpdateCancelableOperation;
  CancelableOperation? _premiumToFreeCancelableOperation;
  StreamSubscription? _loginStreamSubscription;

  void performActionBasedOnLoginState({required LoginState loginState}) {
    if (loginState.currentLoginState == CurrentLoginState.loggedIn) {
      checkIfFreeIsForced();
    } else {
      _nextUpdateCancelableOperation?.cancel();
    }
  }

  void initialize() {
    changeBack();
    _loginStreamSubscription?.cancel();
    _loginStreamSubscription = loginCubit.stream.listen((loginState) {
      performActionBasedOnLoginState(loginState: loginState);
    });
    print("PremiumCheckerCubit here");
    performActionBasedOnLoginState(loginState: loginCubit.state);
  }

  void checkIfFreeIsForced() async {
    _nextUpdateCancelableOperation?.cancel();
    await FirebaseRConfigHandler.fetchAndActivate();
    if (FirebaseRConfigHandler.forceFree) {
      emit(PremiumCheckerState(
        currentPremiumState: CurrentPremiumState.freeUser,
        premiumTill: state.premiumTill == DateTimeExtensions.invalid
            ? DateTimeExtensions.invalid
            : state.premiumTill.add(FirebaseRConfigHandler.minimumFetchTimeout),
      ));
    }
    _nextUpdateCancelableOperation = CancelableOperation.fromFuture(
        Future.delayed(FirebaseRConfigHandler.minimumFetchTimeout));
    _nextUpdateCancelableOperation?.value.then((_) async {
      checkIfFreeIsForced();
    });
  }

  void changeState({bool? toPremium}) {
    if (FirebaseRConfigHandler.forceFree) {
      if (state.currentPremiumState != CurrentPremiumState.pseudoProUser) {
        emit(
          PremiumCheckerState(
            currentPremiumState: CurrentPremiumState.freeUser,
            premiumTill: state.premiumTill,
          ),
        );
      }
      return;
    }
    if (toPremium != null) {
      emit(PremiumCheckerState(
        currentPremiumState: toPremium
            ? CurrentPremiumState.pseudoProUser
            : CurrentPremiumState.freeUser,
        premiumTill: toPremium
            ? DateTime.now().add(Duration(days: 1))
            : DateTimeExtensions.invalid,
      ));
    } else {
      if (state.currentPremiumState != CurrentPremiumState.freeUser) {
        emit(PremiumCheckerState(
          currentPremiumState: CurrentPremiumState.freeUser,
          premiumTill: DateTimeExtensions.invalid,
        ));
      } else {
        emit(PremiumCheckerState(
          currentPremiumState: CurrentPremiumState.pseudoProUser,
          premiumTill: DateTime.now().add(Duration(days: 1)),
        ));
      }
    }
    changeBack();
  }

  Future<void> close() {
    _premiumToFreeCancelableOperation?.cancel();
    _nextUpdateCancelableOperation?.cancel();
    _loginStreamSubscription?.cancel();
    return super.close();
  }

  @override
  PremiumCheckerState? fromJson(Map<String, dynamic> json) {
    return PremiumCheckerState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(PremiumCheckerState state) {
    return state.toMap();
  }
}
