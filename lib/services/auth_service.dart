import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  UserCredential _userInfo;

  UserCredential get userData => _userInfo;

  loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      _userInfo = await FirebaseAuth.instance.signInWithCredential(credential);
      FirebaseFirestore.instance.collection("users").get().then((users) {
        if (!users.docs.contains(_userInfo.user.email)) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(_userInfo.user.email)
              .set({"email": _userInfo.user.email, "uid": _userInfo.user.uid});
        }
      });
      notifyListeners();
    } catch (e) {
      Get.rawSnackbar(message: e.toString());
    }
  }

  googleSignOut() async {
    await GoogleSignIn().signOut();
  }

  normalSignup(String email, String password) async {
    try {
      _userInfo = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      FirebaseFirestore.instance.collection("users").get().then((users) {
        if (!users.docs.contains(_userInfo.user.email)) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(_userInfo.user.email)
              .set({"email": _userInfo.user.email, "uid": _userInfo.user.uid});
        }
      });
    } on FirebaseAuthException catch (e) {
      Get.rawSnackbar(message: e.code, duration: Duration(seconds: 5));
      return false;
    } catch (e) {
      Get.rawSnackbar(message: e.toString(), duration: Duration(seconds: 5));
      return false;
    }
    return true;
  }

  normalLogin(String email, String password) async {
    try {
      _userInfo = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.rawSnackbar(message: e.code, duration: Duration(seconds: 5));
      return false;
    } catch (e) {
      Get.rawSnackbar(message: e.toString(), duration: Duration(seconds: 5));
      return false;
    }
    return true;
  }
}
