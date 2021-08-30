import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthHandler {
  static Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      signInOption: SignInOption.standard,
    ).signIn();

    if (googleUser != null) {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential _userCredentialToReturn =
          await FirebaseAuthFunctions.signInWithCredential(
        credential: credential,
      );
      return _userCredentialToReturn;
    }
  }

  static Future<void> signInWithEmailOnly({required String email}) async {
    try {
      await FirebaseAuthFunctions.sendEmailLinkToSignIn(email: email);
      Fluttertoast.showToast(msg: "Check $email's inbox");
    } catch (exception) {
      print("signInWithEmailOnly exception: $exception");
      Fluttertoast.showToast(msg: "Error occured! Check your network");
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuthFunctions.signOut();
      Fluttertoast.showToast(msg: "Sign out successful!");
    } catch (exception) {
      print("authHandler signOut exception: $exception");
      Fluttertoast.showToast(msg: "Error occured. Please try again.");
    }
  }
}
