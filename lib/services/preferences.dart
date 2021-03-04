import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  void setLogin() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setBool('loggedIn', true);
  }

  void setLogout() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setBool('loggedIn', false);
  }

  Future<bool> loginStatus() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getBool('loggedIn') ?? false;
  }
}
