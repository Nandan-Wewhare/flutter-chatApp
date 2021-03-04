import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<QueryDocumentSnapshot> searchResults = [];
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(hintText: 'Search User'),
            ),
            !_isLoading
                ? ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        searchResults.clear();
                        _isLoading = true;
                      });
                      FirebaseFirestore.instance
                          .collection("users")
                          .where("email",
                              isEqualTo: _searchController.text,
                              isNotEqualTo:
                                  FirebaseAuth.instance.currentUser.email)
                          .get()
                          .then((users) => setState(() {
                                searchResults = users.docs;
                                _isLoading = false;
                              }));
                    },
                    icon: Icon(Icons.search),
                    label: Text('Search'),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.4,
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(searchResults[index].data()["email"]),
                    trailing: IconButton(
                      // button to open chat room
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection(
                                "users/${FirebaseAuth.instance.currentUser.email}/chats")
                            .doc(searchResults[index].data()["email"])
                            .get()
                            .then((chat) {
                          if (!chat.exists) {
                            // if chat does not exist with the searched user
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser.email)
                                .collection("chats")
                                .doc(searchResults[index].data()["email"])
                                .set({
                              "id": uuid.v1(),
                              "owner": FirebaseAuth.instance.currentUser.email,
                              "to": searchResults[index].data()["email"]
                            });
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(searchResults[index].data()["email"])
                                .collection("chats")
                                .doc(FirebaseAuth.instance.currentUser.email)
                                .set({
                              "id": uuid.v1(),
                              "owner": searchResults[index].data()["email"],
                              "to": FirebaseAuth.instance.currentUser.email
                            });
                            Get.off(
                                ChatRoom(searchResults[index].data()["email"]));
                          } else {
                            Get.off(
                                ChatRoom(searchResults[index].data()["email"]));
                          }
                        });
                      },
                      icon: Icon(Icons.send),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
