import 'package:chatapp_trial/screens/home.dart';
import 'package:chatapp_trial/screens/login.dart';
import 'package:chatapp_trial/services/auth_service.dart';
import 'package:chatapp_trial/services/preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: GetMaterialApp(
        home: FutureBuilder(
          future: Preferences().loginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                // print(snapshot.data);
                return snapshot.data ? Home() : Login();
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
