import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:protasks/logic/package_info_handler.dart';

class FirebaseAuthFunctions {
  static FirebaseAuth get _instance => FirebaseAuth.instance;

  static User? get getCurrentUser {
    return _instance.currentUser;
  }

  static Future<UserCredential> signInWithCredential({
    required AuthCredential credential,
  }) async {
    // try {
    UserCredential userCredentialToReturn =
        await _instance.signInWithCredential(credential);
    print("signInWithCredential updating LoginCubit.userCredential");
    LoginCubit.userCredential = userCredentialToReturn;
    Fluttertoast.showToast(
        msg: 'Logged in as ${userCredentialToReturn.user!.email}');
    return userCredentialToReturn;
    // } on FirebaseAuthException catch (exception) {}
  }

  static Future<void> sendEmailLinkToSignIn({
    required String email,
  }) async {
    return await _instance.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        // TODO: CHANGE THE URL, BASED ON APP
        url: PackageInfoHandler.isDeveloperVersion
            ? FirebaseRConfigHandler.signInHostDeveloper
            : FirebaseRConfigHandler.signInHostRelease,
        handleCodeInApp: true,
        // androidPackageName: 'com.application.todoapp',
        androidPackageName: PackageInfoHandler.packageName,
        androidMinimumVersion: FirebaseRConfigHandler.leastRecommendedVersion,
        androidInstallApp: true,
        iOSBundleId: PackageInfoHandler.packageName,
      ),
    );
  }

  static Future<UserCredential?> signInWithEmailAndLink({
    required String email,
    required String link,
  }) async {
    try {
      UserCredential _credentialToReturn = await _instance.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
      print("signInWithEmailAndLink updating LoginCubit.userCredential");
      LoginCubit.userCredential = _credentialToReturn;
      Fluttertoast.showToast(msg: 'Logged in as $email');
      return _credentialToReturn;
    } catch (exception) {
      Fluttertoast.showToast(msg: "Couldn't login! Please try again");
    }
  }

  static Future<void> signOut() async {
    return await _instance.signOut();
  }
}
