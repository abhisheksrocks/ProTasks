import 'package:protasks/logic/my_navigator.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'cubit/root_cubits/login_cubit.dart';
import 'firebase_auth_functions.dart';

class FirebaseDLinkHandler {
  FirebaseDLinkHandler._();

  static Future<void> handleDynamicLinks() async {
    // https://www.youtube.com/watch?v=aBrRJqrQTpQ for more help

    // ON APP START BY LINK
    final PendingDynamicLinkData? _pendingDynamicLinkData =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (_pendingDynamicLinkData != null) {
      _handleDeepLinks(_pendingDynamicLinkData);
    }

    // ON APP RESUMED ON LINK
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (linkData) async {
        if (linkData != null) {
          _handleDeepLinks(linkData);
        }
      },
      onError: (error) async {
        print("FirebaseDynamicLinks.instance.onLink error: $error");
      },
    );
  }

  static Future<void> _handleDeepLinks(PendingDynamicLinkData data) async {
    Uri deepLink = data.link;
    print("_handleDeepLinks deepLink: $deepLink");
    if (deepLink.pathSegments.contains('auth')) {
      if (LoginCubit.loginEmail != null) {
        if (await FirebaseAuthFunctions.signInWithEmailAndLink(
              email: LoginCubit.loginEmail!,
              link: deepLink.toString(),
            ) !=
            null) {
          Navigator.of(MyNavigator.context!)
              .pushNamedAndRemoveUntil(AppRouter.dashboard, (route) => true);
        }
      } else {
        Fluttertoast.showToast(msg: "Error logging in!");
      }
    }
  }
}
