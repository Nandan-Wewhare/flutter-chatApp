import 'package:chatapp_trial/screens/login.dart';
import 'package:chatapp_trial/screens/search_screen.dart';
import 'package:chatapp_trial/services/app_methods.dart';
import 'package:chatapp_trial/services/auth_service.dart';
import 'package:chatapp_trial/services/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () => Get.to(() => SearchScreen()),
      ),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Chats'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(children: [
                CircleAvatar(
                  child: Image.network(FirebaseAuth
                          .instance.currentUser.photoURL ??
                      'https://firebase.flutter.dev/img/flutterfire_300x.png'),
                ),
                SizedBox(height: 10),
                Text(
                  FirebaseAuth.instance.currentUser.email,
                  style: TextStyle(color: Colors.grey),
                )
              ]),
            ),
            ListTile(
              title: Text('LOGOUT'),
              leading: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onTap: () async {
                AppMethods.showBusy(context, true);
                await AuthService().googleSignOut();
                AppMethods.showBusy(context, false);
                Get.off(() => Login());
                Preferences().setLogout();
              },
            )
          ],
        ),
      ),
      body: Center(
          child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser.email)
            .collection("chats")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1,
                );
              },
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data.docs[index].data()["to"]),
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  onTap: () {
                    Get.to(
                        () => ChatRoom(snapshot.data.docs[index].data()["to"]));
                  },
                );
              },
              itemCount: snapshot.data.docs.length,
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      )),
    );
  }
}
